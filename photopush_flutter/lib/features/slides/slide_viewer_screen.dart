import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';
import '../albums/album_repository.dart';
import 'slide_repository.dart';
import 'media_service.dart';
import 'asset_thumbnail.dart';
import 'fullscreen_slide_viewer.dart';
import '../../core/utils/order_key.dart';

class SlideViewerScreen extends ConsumerWidget {
  final Album album;

  const SlideViewerScreen({super.key, required this.album});

  Future<void> _addPhoto(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final slides = ref.read(albumSlidesProvider(album.id)).value ?? [];
        final String orderKey = slides.isEmpty
            ? OrderKey.generateFirst()
            : OrderKey.generateNext(slides.last.orderKey);

        final mediaService = ref.read(mediaServiceProvider);
        final asset = await mediaService.importMedia(pickedFile);

        final slideRepo = ref.read(slideRepositoryProvider);
        await slideRepo.createPhotoSlide(album.id, asset.id, orderKey);

        ref.invalidate(albumSlidesProvider(album.id));
        ref.invalidate(albumListProvider);
      } finally {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final slidesAsync = ref.watch(albumSlidesProvider(album.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(album.name),
      ),
      body: slidesAsync.when(
        data: (slides) {
          final photoSlides = slides
              .where((s) => s.kind == 'photo' && s.assetId != null)
              .toList();

          if (photoSlides.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.emptyAlbumHelp,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _addPhoto(context, ref),
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(l10n.addPhotoSlide),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(4.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: photoSlides.length,
            itemBuilder: (context, index) {
              final slide = photoSlides[index];

              return OpenContainer(
                closedElevation: 0,
                closedColor: Colors.transparent,
                openElevation: 0,
                openColor: Colors.black,
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                openBuilder: (context, _) => FullscreenSlideViewer(
                  album: album,
                  initialIndex: index,
                ),
                closedBuilder: (context, openContainer) => InkWell(
                  borderRadius: BorderRadius.circular(4.0),
                  onTap: openContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: AssetThumbnail(
                        assetId: slide.assetId!,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPhoto(context, ref),
        tooltip: l10n.addPhotoSlide,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
