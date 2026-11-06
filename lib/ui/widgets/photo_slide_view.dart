import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/album_detail_controller.dart';
import '../../models/models.dart';
import 'pin_editor_dialog.dart';
import 'pin_view.dart';

/// View displaying a photo slide with fallback handling for missing images
/// and interactive pins overlay.
class PhotoSlideView extends StatefulWidget {
  const PhotoSlideView({
    super.key,
    required this.slide,
    required this.controller,
    required this.onToggleComment,
  });

  final Slide slide;
  final AlbumDetailController controller;
  final VoidCallback onToggleComment;

  @override
  State<PhotoSlideView> createState() => _PhotoSlideViewState();
}

class _PhotoSlideViewState extends State<PhotoSlideView> {
  bool _pinsVisible = true;

  Future<void> _handleImageTap(
    TapUpDetails details,
    BoxConstraints constraints,
  ) async {
    // 1. Calculate normalized coordinates
    final x = details.localPosition.dx / constraints.maxWidth;
    final y = details.localPosition.dy / constraints.maxHeight;

    // We constrain the coordinates between 0 and 1 strictly
    final normalizedX = x.clamp(0.0, 1.0);
    final normalizedY = y.clamp(0.0, 1.0);

    // 2. Create a default pin
    final newPin = Pin(x: normalizedX, y: normalizedY);

    // 3. Open editor dialog
    await _openPinEditor(newPin, isNew: true);
  }

  Future<void> _openPinEditor(Pin pin, {bool isNew = false}) async {
    // Exclude current slide from target list
    final availableTargets = widget.controller.slides
        .where((s) => s.id != widget.slide.id)
        .toList();

    final dynamic result = await showDialog(
      context: context,
      builder: (ctx) => PinEditorDialog(
        pin: pin,
        availableSlides: availableTargets,
        isNew: isNew,
      ),
    );

    if (result == null) return; // Cancelled

    if (result == 'delete') {
      if (!isNew) {
        await widget.controller.deletePin(pin.id);
      }
    } else if (result is Pin) {
      if (isNew) {
        await widget.controller.addPin(result);
      } else {
        await widget.controller.updatePin(result);
      }
    }
  }

  void _handlePinTap(Pin pin) {
    if (pin.hasLink && pin.targetSlideId != null) {
      // Navigate to linked slide
      final targetIndex = widget.controller.slides.indexWhere(
        (s) => s.id == pin.targetSlideId,
      );
      if (targetIndex != -1) {
        widget.controller.goToSlide(targetIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<File?>(
            future: widget.controller.resolveImageFile(widget.slide.image),
            builder: (context, snapshot) {
              final file = snapshot.data;

              if (file != null && file.existsSync()) {
                return Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) =>
                            _handleImageTap(details, constraints),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // The image sizes itself to fit the constraints while maintaining aspect ratio.
                            // The Stack shrink-wraps it, giving us the exact painted dimensions.
                            Image.file(file, fit: BoxFit.contain),

                            if (_pinsVisible)
                              ...widget.slide.pins.map((pin) {
                                // Calculate position based on the painted image size (which matches the Stack size)
                                return Positioned(
                                  // Pin tip is at bottom center. We use FractionalOffset to align the pin widget.
                                  // Since Positioned doesn't support FractionalOffset directly relative to its own size,
                                  // we will position it by its tip manually.
                                  // A cleaner way is using Align if we had a wrapping container, but Positioned works if we calculate offset.
                                  // Actually, PinView uses Stack alignment bottomCenter, so the container's bottomCenter is the tip.
                                  // We must place the top-left of the PinView such that its bottom-center falls on (x, y).
                                  // Size of PinView is (32 * size) x (32 * size).
                                  left:
                                      (pin.x * constraints.maxWidth) -
                                      (16.0 * pin.size),
                                  top:
                                      (pin.y * constraints.maxHeight) -
                                      (32.0 * pin.size),
                                  child: GestureDetector(
                                    onLongPress: () => _openPinEditor(pin),
                                    child: PinView(
                                      pin: pin,
                                      onTap: () => _handlePinTap(pin),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }

              // Fallback: Image introuvable
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 72,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Image introuvable',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.slide.image?.isGallery == true
                            ? 'La photo liée à la galerie a été déplacée ou supprimée du téléphone.'
                            : 'Le fichier image de l\'album est manquant.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Storage mode indicator
        if (widget.slide.image != null)
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.slide.image!.isInternal
                        ? Icons.sd_storage
                        : Icons.photo_library,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.slide.image!.isInternal
                        ? 'Copie locale'
                        : 'Lien galerie',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

        // Visibility toggle
        Positioned(
          left: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: null,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.8,
            ),
            onPressed: () => setState(() => _pinsVisible = !_pinsVisible),
            tooltip: _pinsVisible
                ? 'Masquer les punaises'
                : 'Afficher les punaises',
            child: Icon(
              _pinsVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // Comment toggle
        if (widget.slide.hasComment)
          Positioned(
            right: 16,
            bottom: 16,
            child: ActionChip(
              avatar: const Icon(Icons.notes, size: 18),
              label: const Text('Lire le commentaire'),
              onPressed: widget.onToggleComment,
            ),
          ),
      ],
    );
  }
}
