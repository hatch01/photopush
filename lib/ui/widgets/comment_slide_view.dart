import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Fullscreen typography view for a comment slide or comment pane.
class CommentSlideView extends StatelessWidget {
  const CommentSlideView({
    super.key,
    required this.slide,
    required this.onEditComment,
  });

  final Slide slide;
  final VoidCallback onEditComment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = slide.comment?.trim() ?? '';
    final charCount = text.length;
    final isLong = charCount > 350;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 48,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              if (text.isNotEmpty)
                Text(
                  text,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'Aucun texte pour le moment. Touchez pour ajouter un commentaire.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (isLong)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '$charCount caractères (au-delà de 350 caractères conseillés)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: onEditComment,
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  text.isEmpty ? 'Ajouter un texte' : 'Modifier le commentaire',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
