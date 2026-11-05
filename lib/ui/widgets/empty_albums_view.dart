import 'package:flutter/material.dart';

/// Zero-state placeholder widget displayed when no albums exist.
class EmptyAlbumsView extends StatelessWidget {
  const EmptyAlbumsView({super.key, required this.onCreateAlbum});

  final VoidCallback onCreateAlbum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aucun album photo',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Créez votre premier album pour organiser vos photos, ajouter des commentaires et y planter des punaises interactives.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onCreateAlbum,
              icon: const Icon(Icons.add),
              label: const Text('Créer un album'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
