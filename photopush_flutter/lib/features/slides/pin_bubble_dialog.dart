import 'package:flutter/material.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';

class PinBubbleDialog extends StatelessWidget {
  final Pin pin;
  final VoidCallback? onNavigate;

  const PinBubbleDialog({
    super.key,
    required this.pin,
    this.onNavigate,
  });

  static Future<void> show(BuildContext context, Pin pin, {VoidCallback? onNavigate}) {
    return showDialog(
      context: context,
      builder: (context) => PinBubbleDialog(pin: pin, onNavigate: onNavigate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      content: Text(
        pin.text ?? '',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
        if (pin.targetSlideId != null && onNavigate != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onNavigate!();
            },
            child: Text(l10n.goToSlide),
          ),
      ],
    );
  }
}