import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Dialog allowing the user to create a new album with real-time validation.
class CreateAlbumDialog extends StatefulWidget {
  const CreateAlbumDialog({super.key, required this.existingAlbumNames});

  final Set<String> existingAlbumNames;

  @override
  State<CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorMessage = null);
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
    final alreadyExists = widget.existingAlbumNames.any(
      (name) => name.toLowerCase() == lower,
    );

    if (alreadyExists) {
      setState(() => _errorMessage = 'Un album avec ce nom existe déjà.');
      return;
    }

    setState(() => _errorMessage = null);
  }

  void _submit() {
    final name = _controller.text.trim();
    _validate(name);

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Veuillez saisir un nom d\'album.');
      return;
    }

    if (_errorMessage != null) return;

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel album'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Nom de l\'album',
              hintText: 'Ex: Voyage en Islande',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
            onChanged: _validate,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isNotEmpty && _errorMessage == null
              ? _submit
              : null,
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
