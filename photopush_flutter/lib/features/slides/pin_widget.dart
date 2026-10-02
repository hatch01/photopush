import 'package:flutter/material.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';

class PinWidget extends StatelessWidget {
  final Pin pin;
  final VoidCallback onTap;

  const PinWidget({
    super.key,
    required this.pin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Determine color
    Color pinColor;
    switch (pin.color) {
      case 'white':
        pinColor = Colors.white;
        break;
      case 'green':
        pinColor = Colors.green;
        break;
      case 'yellow':
        pinColor = Colors.yellow;
        break;
      case 'blue':
        pinColor = Colors.blue;
        break;
      case 'purple':
        pinColor = Colors.purple;
        break;
      case 'black':
      default:
        pinColor = Colors.black;
    }

    // Size calculation (R-04: 20 * sizeScale)
    final double size = 20.0 * pin.sizeScale;

    IconData iconData;
    switch (pin.kind) {
      case 'text':
        iconData = Icons.notes;
        break;
      case 'link':
        iconData = Icons.link;
        break;
      case 'textLink':
        iconData = Icons.insert_link;
        break;
      case 'neutral':
      default:
        iconData = Icons.stop_circle;
    }

    // Ensure touch target is at least 48x48 dp to prevent fat-finger misses (RNF-60)
    const double minTouchTarget = 48.0;
    final double touchTargetSize = size < minTouchTarget
        ? minTouchTarget
        : size;

    // RNF-61 / RNF-64 / A-01: Build descriptive screen reader semantics
    String semanticLabel = 'Punaise ${pin.color}';
    if (l10n != null) {
      switch (pin.kind) {
        case 'text':
          semanticLabel = l10n.pinSemanticText(pin.color, pin.text ?? '');
          break;
        case 'link':
          semanticLabel = l10n.pinSemanticLink(pin.color);
          break;
        case 'textLink':
          semanticLabel = l10n.pinSemanticTextLink(pin.color, pin.text ?? '');
          break;
        case 'neutral':
        default:
          semanticLabel = l10n.pinSemanticNeutral(pin.color);
          break;
      }
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: touchTargetSize,
          height: touchTargetSize,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: pinColor,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.white, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2.0,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  iconData,
                  size: size * 0.6,
                  color: pinColor == Colors.white ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
