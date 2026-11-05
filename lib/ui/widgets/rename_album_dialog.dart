import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Dialog allowing the user to rename an existing album.
class RenameAlbumDialog extends StatefulWidget {
  const RenameAlbumDialog({
    super.key,
    required this.currentName,
    required this.existingAlbumNames,
  });

  final String currentName;
  final Set<String> existingAlbumNames;

  @override
  State<RenameAlbumDialog> createState() => _RenameAlbumDialogState();
}

class _RenameAlbumDialogState extends State<RenameAlbumDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(
        () => _errorMessage = 'Le nom de l\'album ne peut pas être vide.',
      );
      return;
    }

    if (trimmed.length > 80) {
      setState(
        () => _errorMessage = 'Le nom ne peut pas dépasser 80 caractères.',
      );
      return;
    }

    if (Album.forbiddenCharactersRegex.hasMatch(trimmed)) {
      setState(
        () => _errorMessage = 'Caractères interdits : / \\ : * ? " < > |',
      );
      return;
    }

    final lower = trimmed.toLowerCase();
    final currentLower = widget.currentName.toLowerCase();
    if (lower != currentLower) {
      final alreadyExists = widget.existingAlbumNames.any(
        (name) => name.toLowerCase() == lower,
      );
      if (alreadyExists) {
        setState(() => _errorMessage = 'Un album avec ce nom existe déjà.');
        return;
      }
    }

    setState(() => _errorMessage = null);
  }

  void _submit() {
    final name = _controller.text.trim();
    _validate(name);

    if (_errorMessage != null) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges =
        _controller.text.trim() != widget.currentName &&
        _controller.text.trim().isNotEmpty &&
        _errorMessage == null;

    return AlertDialog(
      title: const Text('Renommer l\'album'),
      content: TextField(
        controller: _controller,
        maxLength: 80,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Nouveau nom',
          errorText: _errorMessage,
          border: const OutlineInputBorder(),
        ),
        onChanged: _validate,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: hasChanges ? _submit : null,
          child: const Text('Renommer'),
        ),
      ],
    );
  }
}
