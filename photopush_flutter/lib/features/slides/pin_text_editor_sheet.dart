import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class PinTextEditorSheet extends StatefulWidget {
  final String? initialText;

  const PinTextEditorSheet({super.key, this.initialText});

  static Future<String?> show(BuildContext context, {String? initialText}) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: PinTextEditorSheet(initialText: initialText),
      ),
    );
  }

  @override
  State<PinTextEditorSheet> createState() => _PinTextEditorSheetState();
}

class _PinTextEditorSheetState extends State<PinTextEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              l10n.pinTextTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              maxLength: 400, // LIM-04
              decoration: InputDecoration(
                hintText: l10n.commentHint,
                border: const OutlineInputBorder(),
              ),
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
                  onPressed: () {
                    Navigator.of(context).pop(_controller.text);
                  },
                  child: Text(l10n.ok),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}