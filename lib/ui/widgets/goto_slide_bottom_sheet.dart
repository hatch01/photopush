import 'package:flutter/material.dart';

import '../../controllers/album_detail_controller.dart';

/// Modal bottom sheet displaying a list of slides for quick navigation.
class GoToSlideBottomSheet extends StatelessWidget {
  const GoToSlideBottomSheet({super.key, required this.controller});

  final AlbumDetailController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final slides = controller.slides;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Aller à la diapositive...',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  final isCurrent = index == controller.currentIndex;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrent
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      slide.title.isNotEmpty
                          ? slide.title
                          : 'Diapositive ${index + 1}',
                      style: TextStyle(
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: slide.isComment
                        ? const Icon(Icons.notes_outlined)
                        : const Icon(Icons.photo_outlined),
                    selected: isCurrent,
                    onTap: () {
                      controller.goToSlide(index);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
