import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';
import 'slide_repository.dart';
import 'photo_slide_viewer.dart';
import 'pin_settings_screen.dart';

class FullscreenSlideViewer extends ConsumerStatefulWidget {
  final Album album;
  final int initialIndex;
  final UuidValue? initialSlideId;

  const FullscreenSlideViewer({
    super.key,
    required this.album,
    this.initialIndex = 0,
    this.initialSlideId,
  });

  @override
  ConsumerState<FullscreenSlideViewer> createState() =>
      _FullscreenSlideViewerState();
}

class _FullscreenSlideViewerState extends ConsumerState<FullscreenSlideViewer> {
  late final PageController _pageController;
  bool _immersiveMode = false;
  bool _isZoomed = false;
  bool _isEditing = false;
  bool _initializedPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _toggleImmersive() {
    if (_isEditing) return; // Don't allow immersive mode toggle while editing
    setState(() {
      _immersiveMode = !_immersiveMode;
    });
  }

  void _onZoomChanged(bool isZoomed) {
    if (_isZoomed != isZoomed) {
      setState(() {
        _isZoomed = isZoomed;
      });
    }
  }

  void _navigateToSlide(UuidValue targetSlideId) {
    final slides = ref.read(albumSlidesProvider(widget.album.id)).value ?? [];
    final photoSlides = slides
        .where((s) => s.kind == 'photo' && s.assetId != null)
        .toList();
    final targetIndex = photoSlides.indexWhere((s) => s.id == targetSlideId);
    if (targetIndex != -1 && _pageController.hasClients) {
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _immersiveMode
          ? null
          : AppBar(
              title: Text(widget.album.name),
              backgroundColor: Colors.black.withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.tune),
                    tooltip: l10n.pinSettingsTitle,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PinSettingsScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),
      body: slidesAsync.when(
        data: (slides) {
          final photoSlides = slides
              .where((s) => s.kind == 'photo' && s.assetId != null)
              .toList();

          if (photoSlides.isEmpty) return const SizedBox.shrink();

          if (!_initializedPage && widget.initialSlideId != null) {
            final targetIndex = photoSlides.indexWhere(
              (s) => s.id == widget.initialSlideId,
            );
            if (targetIndex != -1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(targetIndex);
                }
              });
            }
            _initializedPage = true;
          }

          return PageView.builder(
            controller: _pageController,
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: photoSlides.length,
            itemBuilder: (context, index) {
              final slide = photoSlides[index];
              return PhotoSlideViewer(
                album: widget.album,
                slide: slide,
                onTap: _toggleImmersive,
                onZoomChanged: _onZoomChanged,
                isEditing: _isEditing,
                onNavigateToSlide: _navigateToSlide,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: _immersiveMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              backgroundColor: _isEditing
                  ? Theme.of(context).colorScheme.error
                  : null,
              child: Icon(_isEditing ? Icons.close : Icons.edit),
            ),
    );
  }
}
