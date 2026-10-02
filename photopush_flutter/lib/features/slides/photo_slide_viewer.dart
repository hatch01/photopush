import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'asset_repository.dart';

class PhotoSlideViewer extends ConsumerStatefulWidget {
  final Slide slide;
  final VoidCallback onTap;
  final ValueChanged<bool>? onZoomChanged;

  const PhotoSlideViewer({
    super.key,
    required this.slide,
    required this.onTap,
    this.onZoomChanged,
  });

  @override
  ConsumerState<PhotoSlideViewer> createState() => _PhotoSlideViewerState();
}

class _PhotoSlideViewerState extends ConsumerState<PhotoSlideViewer>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  Animation<Matrix4>? _animation;
  Offset _doubleTapPosition = Offset.zero;

  Future<Asset?>? _assetFuture;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAssetFuture();
  }

  @override
  void didUpdateWidget(covariant PhotoSlideViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slide.assetId != widget.slide.assetId) {
      _loadAssetFuture();
    }
  }

  void _loadAssetFuture() {
    if (widget.slide.assetId != null) {
      final repo = ref.read(assetRepositoryProvider);
      _assetFuture = Asset.db.findById(repo.session, widget.slide.assetId!);
    } else {
      _assetFuture = null;
    }
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomed = scale > 1.01;
    widget.onZoomChanged?.call(isZoomed);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    final Matrix4 targetMatrix;
    if (currentScale > 1.05) {
      targetMatrix = Matrix4.identity();
    } else {
      const targetScale = 2.5;
      final x = -_doubleTapPosition.dx * (targetScale - 1);
      final y = -_doubleTapPosition.dy * (targetScale - 1);
      targetMatrix = Matrix4.identity()
        ..storage[0] = targetScale
        ..storage[5] = targetScale
        ..storage[12] = x
        ..storage[13] = y;
    }

    _animation =
        Matrix4Tween(
          begin: currentMatrix,
          end: targetMatrix,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    void listener() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    }

    _animation!.addListener(listener);

    _animationController.forward(from: 0).then((_) {
      _animation?.removeListener(listener);
      _transformationController.value = targetMatrix;
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final double scaleChange = event.scrollDelta.dy < 0 ? 1.15 : 0.85;
      final currentMatrix = _transformationController.value;
      final currentScale = currentMatrix.getMaxScaleOnAxis();
      final newScale = (currentScale * scaleChange).clamp(1.0, 6.0);

      if (newScale == 1.0) {
        _transformationController.value = Matrix4.identity();
      } else {
        final focalPoint = event.localPosition;
        final x = -focalPoint.dx * (newScale - 1);
        final y = -focalPoint.dy * (newScale - 1);
        _transformationController.value = Matrix4.identity()
          ..storage[0] = newScale
          ..storage[5] = newScale
          ..storage[12] = x
          ..storage[13] = y;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slide.assetId == null) {
      return const Center(child: Text('No Image attached'));
    }

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onTap: () {
          // Only toggle immersive mode when not zoomed in and not currently interacting
          if (!_isInteracting &&
              _transformationController.value.getMaxScaleOnAxis() <= 1.01) {
            widget.onTap();
          }
        },
        onDoubleTapDown: (details) {
          _doubleTapPosition = details.localPosition;
        },
        onDoubleTap: _handleDoubleTap,
        child: FutureBuilder<Asset?>(
          future: _assetFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final asset = snapshot.data;
            if (asset?.localPath != null &&
                File(asset!.localPath!).existsSync()) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 6.0,
                clipBehavior: Clip.none,
                trackpadScrollCausesScale: true,
                onInteractionStart: (_) {
                  _isInteracting = true;
                },
                onInteractionEnd: (_) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted) _isInteracting = false;
                  });
                },
                child: Center(
                  child: Image.file(
                    File(asset.localPath!),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Image not found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
