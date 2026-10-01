import 'package:flutter/material.dart';
import 'package:photopush_client/photopush_client.dart';

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

    // Size calculation (R-04: 20 * sizeScale * currentScale)
    // The currentScale is handled automatically by InteractiveViewer, so we just use 20 * sizeScale
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
        iconData = Icons.stop_circle; // Replaces the generic square
    }

    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
