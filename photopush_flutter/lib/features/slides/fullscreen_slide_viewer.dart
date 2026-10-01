import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'slide_repository.dart';
import 'photo_slide_viewer.dart';
import 'comment_slide_viewer.dart';

class FullscreenSlideViewer extends ConsumerStatefulWidget {
  final Album album;
  final int initialIndex;

  const FullscreenSlideViewer({
    super.key,
    required this.album,
    required this.initialIndex,
  });

  @override
  ConsumerState<FullscreenSlideViewer> createState() =>
      _FullscreenSlideViewerState();
}

class _FullscreenSlideViewerState extends ConsumerState<FullscreenSlideViewer> {
  late final PageController _pageController;
  bool _immersiveMode = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

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
            ),
      body: slidesAsync.when(
        data: (slides) {
          if (slides.isEmpty) return const SizedBox.shrink();

          return PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
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
                  isImmersive: _immersiveMode,
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
