import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/album_detail_controller.dart';
import '../../models/models.dart';

/// View displaying a photo slide with fallback handling for missing images.
class PhotoSlideView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<File?>(
            future: controller.resolveImageFile(slide.image),
            builder: (context, snapshot) {
              final file = snapshot.data;

              if (file != null && file.existsSync()) {
                return Center(
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
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
                        slide.image?.isGallery == true
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
        if (slide.hasComment)
          Positioned(
            right: 16,
            bottom: 16,
            child: ActionChip(
              avatar: const Icon(Icons.notes, size: 18),
              label: const Text('Lire le commentaire'),
              onPressed: onToggleComment,
            ),
          ),
      ],
    );
  }
}
