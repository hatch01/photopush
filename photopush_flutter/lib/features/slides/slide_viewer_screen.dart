import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';
import 'slide_repository.dart';
import 'add_slide_sheet.dart';
import 'comment_editor_screen.dart';
import 'media_service.dart';
import '../../core/utils/order_key.dart';

import 'asset_thumbnail.dart';

class SlideViewerScreen extends ConsumerWidget {
  final Album album;

  const SlideViewerScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final slidesAsync = ref.watch(albumSlidesProvider(album.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(album.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final choice = await AddSlideSheet.show(context);
              if (choice != null && context.mounted) {
                final slides =
                    ref.read(albumSlidesProvider(album.id)).value ?? [];
                final String orderKey = slides.isEmpty
                    ? OrderKey.generateFirst()
                    : OrderKey.generateNext(slides.last.orderKey);

                if (choice == SlideChoice.comment) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentEditorScreen(
                        album: album,
                        orderKey: orderKey,
                      ),
                    ),
                  );
                } else if (choice == SlideChoice.photo) {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (pickedFile != null && context.mounted) {
                    // Show a simple loading indicator while processing
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final mediaService = ref.read(mediaServiceProvider);
                      final asset = await mediaService.importMedia(pickedFile);

                      final slideRepo = ref.read(slideRepositoryProvider);
                      await slideRepo.createPhotoSlide(
                        album.id,
                        asset.id,
                        orderKey,
                      );

                      ref.invalidate(albumSlidesProvider(album.id));
                    } finally {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close loading dialog
                      }
                    }
                  }
                }
              }
            },
          ),
        ],
      ),
      body: slidesAsync.when(
        data: (slides) {
          if (slides.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.emptyAlbumHelp,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          // Basic list for now, we will add the PageView (flick navigation) in the next steps
          return ListView.builder(
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return ListTile(
                leading: slide.kind == 'photo' && slide.assetId != null
                    ? AssetThumbnail(assetId: slide.assetId!)
                    : Icon(slide.kind == 'comment' ? Icons.notes : Icons.photo),
                title: Text(
                  slide.title.isEmpty ? l10n.untitledSlide : slide.title,
                ),
                subtitle: Text(
                  slide.kind == 'comment' ? (slide.commentText ?? '') : 'Photo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  if (slide.kind == 'comment') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentEditorScreen(
                          album: album,
                          slide: slide,
                          orderKey: slide.orderKey,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
