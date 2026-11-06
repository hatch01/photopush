import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Modal dialog for creating or editing a pin's properties.
class PinEditorDialog extends StatefulWidget {
  const PinEditorDialog({
    super.key,
    required this.pin,
    required this.availableSlides,
  });

  final Pin pin;
  final List<Slide> availableSlides;

  @override
  State<PinEditorDialog> createState() => _PinEditorDialogState();
}

class _PinEditorDialogState extends State<PinEditorDialog> {
  late final TextEditingController _textController;
  late PinColor _selectedColor;
  late double _selectedSize;
  bool _hasLink = false;
  String? _selectedSlideId;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.pin.text ?? '');
    _selectedColor = widget.pin.color;
    _selectedSize = widget.pin.size;

    // Evaluate if the pin already has a link
    _hasLink =
        widget.pin.targetSlideId != null &&
        widget.pin.targetSlideId!.isNotEmpty;
    _selectedSlideId = _hasLink ? widget.pin.targetSlideId : null;

    // Ensure the selected target slide still exists in the available slides list
    if (_hasLink && _selectedSlideId != null) {
      final targetExists = widget.availableSlides.any(
        (s) => s.id == _selectedSlideId,
      );
      if (!targetExists) {
        _hasLink = false;
        _selectedSlideId = null;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();

    final updatedPin = widget.pin.copyWith(
      color: _selectedColor,
      size: _selectedSize,
      text: text.isEmpty ? null : text,
      targetSlideId: _hasLink ? _selectedSlideId : null,
      type: PinType.info, // This is a placeholder, it is correctly inferred by copyWith / model logic internally or we can explicitly set it, wait Pin._inferType handles it if not provided. But wait, copyWith provides type.
    );

    // In our model, copyWith forces us to define type or keeps the old one. We should compute the new type.
    final hasText = text.isNotEmpty;
    final hasLink = _hasLink && _selectedSlideId != null;

    PinType newType = PinType.info;
    if (hasText && hasLink) {
      newType = PinType.both;
    } else if (hasLink) {
      newType = PinType.link;
    }

    final finalPin = updatedPin.copyWith(type: newType);
    Navigator.of(context).pop(finalPin);
  }

  void _delete() {
    Navigator.of(context)
        .pop('delete'); // Return the literal 'delete' to trigger removal
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Éditer la punaise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color selector
            const Text(
              'Couleur :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PinColor.values.map((c) {
                final isSelected = c == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = c),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c.colorValue),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.grey.withValues(alpha: 0.5),
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Size slider
            const Text(
              'Taille :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Text('x1.0'),
                Expanded(
                  child: Slider(
                    value: _selectedSize,
                    min: 1.0,
                    max: 3.0,
                    divisions: 4, // 1.0, 1.5, 2.0, 2.5, 3.0
                    label: 'x${_selectedSize.toStringAsFixed(1)}',
                    onChanged: (val) => setState(() => _selectedSize = val),
                  ),
                ),
                const Text('x3.0'),
              ],
            ),
            const SizedBox(height: 8),

            // Text input
            TextField(
              controller: _textController,
              maxLines: 4,
              maxLength: 400,
              decoration: const InputDecoration(
                labelText: 'Texte de la bulle (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Target Slide Link
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Lien vers une autre diapositive',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: _hasLink,
              onChanged: widget.availableSlides.isEmpty
                  ? null
                  : (val) {
                      setState(() {
                        _hasLink = val;
                        if (_hasLink &&
                            _selectedSlideId == null &&
                            widget.availableSlides.isNotEmpty) {
                          _selectedSlideId = widget.availableSlides.first.id;
                        }
                      });
                    },
            ),
            if (_hasLink && widget.availableSlides.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedSlideId,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: widget.availableSlides.map((s) {
                  return DropdownMenuItem(value: s.id, child: Text(s.title));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSlideId = val),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _delete,
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('Supprimer'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Enregistrer')),
      ],
    );
  }
}
