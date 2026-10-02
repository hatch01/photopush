import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../core/app_limits.dart';
import '../../l10n/app_localizations.dart';
import 'asset_repository.dart';
import 'pin_bubble_dialog.dart';
import 'pin_edit_sheet.dart';
import 'pin_repository.dart';
import 'pin_settings_screen.dart';
import 'pin_widget.dart';

class PhotoSlideViewer extends ConsumerStatefulWidget {
  final Album album;
  final Slide slide;
  final VoidCallback onTap;
  final ValueChanged<bool>? onZoomChanged;
  final bool isEditing;
  final ValueChanged<UuidValue>? onNavigateToSlide;

  const PhotoSlideViewer({
    super.key,
    required this.album,
    required this.slide,
    required this.onTap,
    this.onZoomChanged,
    this.isEditing = false,
    this.onNavigateToSlide,
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

  Future<void> _ensurePinVisible(Offset scenePoint, RenderBox renderBox) async {
    const double sheetHeight = 220.0;
    final double screenHeight = renderBox.size.height;
    final double thresholdY = screenHeight - sheetHeight - 40.0;

    final matrix = _transformationController.value;
    final double currentViewportY =
        matrix.storage[5] * scenePoint.dy + matrix.storage[13];

    if (currentViewportY > thresholdY) {
      final double dy = thresholdY - currentViewportY;
      final Matrix4 targetMatrix = matrix.clone()
        ..storage[13] = matrix.storage[13] + dy;

      _animation =
          Matrix4Tween(
            begin: matrix,
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
      await _animationController.forward(from: 0);
      _animation?.removeListener(listener);
      _transformationController.value = targetMatrix;
    }
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

    final pinsAsync = ref.watch(slidePinsProvider(widget.slide.id));
    final l10n = AppLocalizations.of(context)!;

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onTapUp: (details) async {
          if (widget.isEditing) {
            final currentPins =
                ref.read(slidePinsProvider(widget.slide.id)).value ?? [];
            if (currentPins.length >= AppLimits.maxPinsPerSlide) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.maxPinsReachedError)),
              );
              return;
            }

            final renderBox = context.findRenderObject() as RenderBox;
            final scenePoint = _transformationController.toScene(
              details.localPosition,
            );

            final x = (scenePoint.dx / renderBox.size.width).clamp(0.0, 1.0);
            final y = (scenePoint.dy / renderBox.size.height).clamp(
              0.0,
              1.0,
            );

            final pinSettings = ref.read(pinSettingsProvider);
            final pinRepo = ref.read(pinRepositoryProvider);
            final newPin = await pinRepo.create(
              slideId: widget.slide.id,
              x: x,
              y: y,
              color: pinSettings.color,
              sizeScale: pinSettings.sizeScale,
            );
            ref.invalidate(slidePinsProvider(widget.slide.id));

            // Auto-pan if the pin would be obscured by the bottom sheet
            await _ensurePinVisible(scenePoint, renderBox);

            // Open the live editing sheet immediately!
            if (context.mounted) {
              await PinEditSheet.show(
                context,
                album: widget.album,
                slide: widget.slide,
                pin: newPin,
              );
            }
          } else {
            if (!_isInteracting &&
                _transformationController.value.getMaxScaleOnAxis() <= 1.01) {
              widget.onTap();
            }
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(asset.localPath!),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        if (pinsAsync.hasValue)
                          ...pinsAsync.value!.map((pin) {
                            const double touchTargetSize = 48.0;
                            return Positioned(
                              left:
                                  pin.x * constraints.maxWidth -
                                  touchTargetSize / 2,
                              top:
                                  pin.y * constraints.maxHeight -
                                  touchTargetSize / 2,
                              width: touchTargetSize,
                              height: touchTargetSize,
                              child: PinWidget(
                                pin: pin,
                                onTap: () async {
                                  if (widget.isEditing) {
                                    final renderBox =
                                        context.findRenderObject() as RenderBox;
                                    final scenePoint = Offset(
                                      pin.x * renderBox.size.width,
                                      pin.y * renderBox.size.height,
                                    );
                                    await _ensurePinVisible(
                                      scenePoint,
                                      renderBox,
                                    );

                                    if (context.mounted) {
                                      await PinEditSheet.show(
                                        context,
                                        album: widget.album,
                                        slide: widget.slide,
                                        pin: pin,
                                      );
                                    }
                                  } else {
                                    void navigate() {
                                      if (widget.onNavigateToSlide != null &&
                                          pin.targetSlideId != null) {
                                        widget.onNavigateToSlide!(
                                          pin.targetSlideId!,
                                        );
                                      }
                                    }

                                    if (pin.text != null &&
                                        pin.text!.isNotEmpty) {
                                      await PinBubbleDialog.show(
                                        context,
                                        pin,
                                        onNavigate: pin.targetSlideId != null
                                            ? navigate
                                            : null,
                                      );
                                    } else if (pin.targetSlideId != null) {
                                      navigate();
                                    }
                                  }
                                },
                              ),
                            );
                          }),
                      ],
                    );
                  },
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
