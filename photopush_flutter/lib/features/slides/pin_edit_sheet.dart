import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'pin_repository.dart';
import 'pin_text_editor_sheet.dart';
import '../../l10n/app_localizations.dart';

class _PinColorOption {
  final String name;
  final Color color;

  const _PinColorOption(this.name, this.color);
}

class PinEditSheet extends ConsumerStatefulWidget {
  final Album album;
  final Slide slide;
  final Pin pin;

  const PinEditSheet({
    super.key,
    required this.album,
    required this.slide,
    required this.pin,
  });

  static Future<void> show(
    BuildContext context, {
    required Album album,
    required Slide slide,
    required Pin pin,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => PinEditSheet(
        album: album,
        slide: slide,
        pin: pin,
      ),
    );
  }

  @override
  ConsumerState<PinEditSheet> createState() => _PinEditSheetState();
}

class _PinEditSheetState extends ConsumerState<PinEditSheet> {
  late Pin _currentPin;

  static const List<_PinColorOption> _colors = [
    _PinColorOption('white', Colors.white),
    _PinColorOption('black', Colors.black),
    _PinColorOption('green', Colors.green),
    _PinColorOption('yellow', Colors.yellow),
    _PinColorOption('blue', Colors.blue),
    _PinColorOption('purple', Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    _currentPin = widget.pin;
  }

  Future<void> _updateColor(String colorName) async {
    final repo = ref.read(pinRepositoryProvider);
    _currentPin.color = colorName;
    await repo.update(_currentPin);
    ref.invalidate(slidePinsProvider(widget.slide.id));
    if (mounted) setState(() {});
  }

  Future<void> _updateSize(double sizeScale) async {
    final repo = ref.read(pinRepositoryProvider);
    _currentPin.sizeScale = sizeScale;
    await repo.update(_currentPin);
    ref.invalidate(slidePinsProvider(widget.slide.id));
    if (mounted) setState(() {});
  }

  Future<void> _editTextAndLink() async {
    final result = await PinTextEditorSheet.show(
      context,
      initialText: _currentPin.text,
      initialTargetSlideId: _currentPin.targetSlideId,
      album: widget.album,
      currentSlideId: widget.slide.id,
    );

    if (result != null && mounted) {
      final text = result.text.trim();
      final finalTargetId = result.targetSlideId;
      final hasText = text.isNotEmpty;
      final hasLink = finalTargetId != null;

      String newKind = 'neutral';
      if (hasText && hasLink) {
        newKind = 'textLink';
      } else if (hasLink) {
        newKind = 'link';
      } else if (hasText) {
        newKind = 'text';
      }

      final repo = ref.read(pinRepositoryProvider);
      _currentPin.text = hasText ? text : null;
      _currentPin.targetSlideId = finalTargetId;
      _currentPin.kind = newKind;
      await repo.update(_currentPin);
      ref.invalidate(slidePinsProvider(widget.slide.id));
      if (mounted) setState(() {});
    }
  }

  Future<void> _deletePin() async {
    final repo = ref.read(pinRepositoryProvider);
    await repo.moveToTrash(_currentPin.id);
    ref.invalidate(slidePinsProvider(widget.slide.id));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Colors & Sizes
            Row(
              children: [
                // Color dots
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _colors.map((c) {
                      final isSelected = _currentPin.color == c.name;
                      return GestureDetector(
                        onTap: () => _updateColor(c.name),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              width: isSelected ? 3.0 : 1.0,
                            ),
                            boxShadow: [
                              if (isSelected)
                                const BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: c.name == 'white' || c.name == 'yellow'
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                // Size segmented control (S / M / L)
                SegmentedButton<double>(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: const [
                    ButtonSegment(value: 0.75, label: Text('S')),
                    ButtonSegment(value: 1.0, label: Text('M')),
                    ButtonSegment(value: 1.25, label: Text('L')),
                  ],
                  selected: {_currentPin.sizeScale},
                  onSelectionChanged: (set) => _updateSize(set.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 2: Text & Link button
            OutlinedButton.icon(
              icon: Icon(
                _currentPin.kind == 'textLink'
                    ? Icons.insert_link
                    : (_currentPin.kind == 'link' ? Icons.link : Icons.notes),
              ),
              label: Text(
                _currentPin.text != null && _currentPin.text!.isNotEmpty
                    ? '${_currentPin.text!} ${_currentPin.targetSlideId != null ? '🔗' : ''}'
                    : (_currentPin.targetSlideId != null
                          ? 'Photo liée 🔗'
                          : '${l10n.pinAddText} / ${l10n.pinAddLink}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: _editTextAndLink,
            ),
            const SizedBox(height: 8),
            // Row 3: Delete & Confirm
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onPressed: _deletePin,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
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
