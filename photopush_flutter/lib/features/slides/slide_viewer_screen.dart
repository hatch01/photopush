import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';
import 'slide_repository.dart';
import 'add_slide_sheet.dart';
import 'comment_editor_screen.dart';
import 'media_service.dart';
import 'photo_slide_viewer.dart';
import 'comment_slide_viewer.dart';
import '../../core/utils/order_key.dart';

class SlideViewerScreen extends ConsumerStatefulWidget {
  final Album album;

  const SlideViewerScreen({super.key, required this.album});

  @override
  ConsumerState<SlideViewerScreen> createState() => _SlideViewerScreenState();
}

class _SlideViewerScreenState extends ConsumerState<SlideViewerScreen> {
  final PageController _pageController = PageController();
  bool _immersiveMode = false;

  void _toggleImmersive() {
    setState(() {
      _immersiveMode = !_immersiveMode;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slidesAsync = ref.watch(albumSlidesProvider(widget.album.id));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _immersiveMode
          ? null
          : AppBar(
              title: Text(widget.album.name),
              backgroundColor:
                  Theme.of(
                    context,
                  ).appBarTheme.backgroundColor?.withValues(alpha: 0.8) ??
                  Colors.black.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final choice = await AddSlideSheet.show(context);
                    if (choice != null && context.mounted) {
                      final slides =
                          ref
                              .read(albumSlidesProvider(widget.album.id))
                              .value ??
                          [];
                      final String orderKey = slides.isEmpty
                          ? OrderKey.generateFirst()
                          : OrderKey.generateNext(slides.last.orderKey);

                      if (choice == SlideChoice.comment) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentEditorScreen(
                              album: widget.album,
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
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            final mediaService = ref.read(mediaServiceProvider);
                            final asset = await mediaService.importMedia(
                              pickedFile,
                            );

                            final slideRepo = ref.read(slideRepositoryProvider);
                            await slideRepo.createPhotoSlide(
                              widget.album.id,
                              asset.id,
                              orderKey,
                            );

                            ref.invalidate(
                              albumSlidesProvider(widget.album.id),
                            );
                          } finally {
                            if (context.mounted) {
                              Navigator.of(context).pop();
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

          return PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            // The CDC requests looping (flick horizontal bouclage) RF-22
            // A simple way to do loop is to use a very large itemCount and modulo
            // For MVP we will just do standard pagination, or add the loop.
            // Let's stick to standard for now, will implement looping if specifically requested to be complex,
            // or just use PageView loop trick.
            itemBuilder: (context, index) {
              final slide = slides[index];
              if (slide.kind == 'photo') {
                return PhotoSlideViewer(
                  slide: slide,
                  onTap: _toggleImmersive,
                );
              } else {
                return CommentSlideViewer(
                  slide: slide,
                  onTap: _toggleImmersive,
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      // Buttons for editing will go here later as floating actions
      floatingActionButton: _immersiveMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Edit current slide (TODO)
              },
              child: const Icon(Icons.edit),
            ),
    );
  }
}
