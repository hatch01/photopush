import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'pin_repository.dart';
import 'pin_text_editor_sheet.dart';
import 'pin_target_picker_sheet.dart';
import '../../l10n/app_localizations.dart';

enum PinAction { addText, addLink, delete }

class PinActionMenu {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Pin pin,
    UuidValue albumId,
    UuidValue slideId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final pinRepo = ref.read(pinRepositoryProvider);

    final action = await showModalBottomSheet<PinAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text(pin.text == null ? l10n.pinAddText : l10n.pinEditText),
              onTap: () => Navigator.of(context).pop(PinAction.addText),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(pin.targetSlideId == null ? l10n.pinAddLink : l10n.pinEditLink),
              onTap: () => Navigator.of(context).pop(PinAction.addLink),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onTap: () => Navigator.of(context).pop(PinAction.delete),
            ),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == PinAction.delete) {
      await pinRepo.moveToTrash(pin.id);
    } else if (action == PinAction.addText) {
      final text = await PinTextEditorSheet.show(context, initialText: pin.text);
      if (text != null && context.mounted) {
        String newKind = pin.targetSlideId != null ? 'textLink' : 'text';
        if (text.isEmpty && pin.targetSlideId != null) newKind = 'link';
        if (text.isEmpty && pin.targetSlideId == null) newKind = 'neutral';
        
        // Due to a limitation in Serverpod copyWith not easily setting nulls,
        // we might have to update directly or use the setter. Serverpod Dart client 
        // does support setting null usually.
        pin.text = text.isEmpty ? null : text;
        pin.kind = newKind;
        await pinRepo.update(pin);
      }
    } else if (action == PinAction.addLink) {
      final targetId = await PinTargetPickerSheet.show(
        context,
        albumId: albumId,
        currentSlideId: slideId,
      );
      if (targetId != null && context.mounted) {
        // RF-50: bascule on/off if same target selected
        final bool isSameTarget = pin.targetSlideId?.toString() == targetId.toString();
        final finalTargetId = isSameTarget ? null : targetId;
        
        String newKind = pin.text != null ? 'textLink' : 'link';
        if (finalTargetId == null && pin.text != null) newKind = 'text';
        if (finalTargetId == null && pin.text == null) newKind = 'neutral';
        
        pin.targetSlideId = finalTargetId;
        pin.kind = newKind;
        await pinRepo.update(pin);
      }
    }
    
    // Always invalidate after an action
    ref.invalidate(slidePinsProvider(slideId));
  }
}