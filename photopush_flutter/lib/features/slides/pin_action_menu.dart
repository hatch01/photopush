import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'pin_repository.dart';
import 'pin_text_editor_sheet.dart';
import '../../l10n/app_localizations.dart';

enum PinAction { edit, delete }

class PinActionMenu {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Pin pin,
    Album album,
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
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () => Navigator.of(context).pop(PinAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.of(context).pop(PinAction.delete),
            ),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == PinAction.delete) {
      await pinRepo.moveToTrash(pin.id);
    } else if (action == PinAction.edit) {
      final result = await PinTextEditorSheet.show(
        context,
        initialText: pin.text,
        initialTargetSlideId: pin.targetSlideId,
        album: album,
        currentSlideId: slideId,
      );
      if (result != null && context.mounted) {
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

        pin.text = hasText ? text : null;
        pin.targetSlideId = finalTargetId;
        pin.kind = newKind;
        await pinRepo.update(pin);
      }
    }

    // Always invalidate after an action
    ref.invalidate(slidePinsProvider(slideId));
  }
}
