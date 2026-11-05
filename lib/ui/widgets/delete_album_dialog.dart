import 'package:flutter/material.dart';

/// Confirmation dialog before permanently deleting an album from disk.
class DeleteAlbumDialog extends StatelessWidget {
  const DeleteAlbumDialog({super.key, required this.albumName});

  final String albumName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error),
          const SizedBox(width: 12),
          const Expanded(child: Text('Supprimer l\'album')),
        ],
      ),
      content: Text(
        'Êtes-vous sûr de vouloir supprimer définitivement l\'album "$albumName" ainsi que toutes les photos et punaises qu\'il contient ? Cette action est irréversible.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer définitivement'),
        ),
      ],
    );
  }
}
