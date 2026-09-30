import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_limits.dart';

class CreateAlbumSheet extends StatefulWidget {
  const CreateAlbumSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const CreateAlbumSheet(),
      ),
    );
  }

  @override
  State<CreateAlbumSheet> createState() => _CreateAlbumSheetState();
}

class _CreateAlbumSheetState extends State<CreateAlbumSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSubmit(AppLocalizations l10n) {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() { _error = l10n.albumNameEmptyError; });
      return;
    }

    final hasInvalid = name.contains('/') || name.contains(':') || name.contains('*') || name.contains('?') || name.contains('"') || name.contains('<') || name.contains('>') || name.contains('|') || name.contains('\\');
    if (hasInvalid) {
      setState(() { _error = l10n.albumNameInvalidCharactersError; });
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.createAlbumTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: AppLimits.maxAlbumNameLength,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _validateAndSubmit(l10n),
              decoration: InputDecoration(
                labelText: l10n.albumNameLabel,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) setState(() { _error = null; });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _validateAndSubmit(l10n),
                  child: Text(l10n.create),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}