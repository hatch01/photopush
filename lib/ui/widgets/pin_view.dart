import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Renders a single pin on top of an image.
class PinView extends StatefulWidget {
  const PinView({super.key, required this.pin, required this.onTap});

  final Pin pin;
  final VoidCallback onTap;

  @override
  State<PinView> createState() => _PinViewState();
}

class _PinViewState extends State<PinView> {
  bool _showBubble = false;

  void _toggleBubble() {
    setState(() => _showBubble = !_showBubble);
    // Note: In US-4 with fully interactive viewers, we might navigate if it's a link.
    // For now, if it's tapped, we toggle the bubble. The parent could also listen to `onTap` to navigate.
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.pin.color.colorValue);
    final sizeMultiplier = widget.pin.size;

    // Base size for x1.0
    const double basePinWidth = 32.0;
    const double basePinHeight = 32.0;

    final pinWidth = basePinWidth * sizeMultiplier;
    final pinHeight = basePinHeight * sizeMultiplier;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Bubble
        if (_showBubble && widget.pin.hasText)
          Positioned(
            bottom: pinHeight + 4,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: Colors.black87,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  widget.pin.text!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        // Pin marker
        GestureDetector(
          onTap: _toggleBubble,
          child: SizedBox(
            width: pinWidth,
            height: pinHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.location_on, color: color, size: pinWidth),
                if (widget.pin.hasLink)
                  Positioned(
                    top: pinWidth * 0.15, // roughly center of the pin head
                    child: Icon(
                      Icons.link,
                      size: pinWidth * 0.4,
                      color: Colors.white, // contrast with pin color
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
