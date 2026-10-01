import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'slide_repository.dart';
import 'photo_slide_viewer.dart';

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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _immersiveMode
          ? null
          : AppBar(
              title: Text(widget.album.name),
              backgroundColor: Colors.black.withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
      body: slidesAsync.when(
        data: (slides) {
          final photoSlides = slides
              .where((s) => s.kind == 'photo' && s.assetId != null)
              .toList();

          if (photoSlides.isEmpty) return const SizedBox.shrink();

          return PageView.builder(
            controller: _pageController,
            itemCount: photoSlides.length,
            itemBuilder: (context, index) {
              final slide = photoSlides[index];
              return PhotoSlideViewer(
                slide: slide,
                onTap: _toggleImmersive,
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
