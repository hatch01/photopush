import 'package:flutter/material.dart';
import 'package:photopush_client/photopush_client.dart';
import 'pin_target_picker_sheet.dart';
import '../../l10n/app_localizations.dart';

class PinTextEditorResult {
  final String text;
  final UuidValue? targetSlideId;

  const PinTextEditorResult({
    required this.text,
    this.targetSlideId,
  });
}

class PinTextEditorSheet extends StatefulWidget {
  final String? initialText;
  final UuidValue? initialTargetSlideId;
  final UuidValue? albumId;
  final UuidValue? currentSlideId;

  const PinTextEditorSheet({
    super.key,
    this.initialText,
    this.initialTargetSlideId,
    this.albumId,
    this.currentSlideId,
  });

  static Future<PinTextEditorResult?> show(
    BuildContext context, {
    String? initialText,
    UuidValue? initialTargetSlideId,
    UuidValue? albumId,
    UuidValue? currentSlideId,
  }) {
    return showModalBottomSheet<PinTextEditorResult?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: PinTextEditorSheet(
          initialText: initialText,
          initialTargetSlideId: initialTargetSlideId,
          albumId: albumId,
          currentSlideId: currentSlideId,
        ),
      ),
    );
  }

  @override
  State<PinTextEditorSheet> createState() => _PinTextEditorSheetState();
}

class _PinTextEditorSheetState extends State<PinTextEditorSheet> {
  late final TextEditingController _controller;
  UuidValue? _selectedTargetSlideId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _selectedTargetSlideId = widget.initialTargetSlideId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickTarget() async {
    if (widget.albumId == null || widget.currentSlideId == null) return;

    final targetId = await PinTargetPickerSheet.show(
      context,
      albumId: widget.albumId!,
      currentSlideId: widget.currentSlideId!,
    );
    if (targetId != null && mounted) {
      setState(() {
        _selectedTargetSlideId = targetId;
      });
    }
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
              maxLines: 4,
              maxLength: 400, // LIM-04
              decoration: InputDecoration(
                hintText: l10n.commentHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.albumId != null && widget.currentSlideId != null) ...[
              if (_selectedTargetSlideId == null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_link),
                  label: Text(l10n.pinAddLink),
                  onPressed: _pickTarget,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.pinEditLink,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickTarget,
                        child: Text(l10n.pinEditLink),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Supprimer le lien',
                        onPressed: () {
                          setState(() {
                            _selectedTargetSlideId = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
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
                    Navigator.of(context).pop(
                      PinTextEditorResult(
                        text: _controller.text,
                        targetSlideId: _selectedTargetSlideId,
                      ),
                    );
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
