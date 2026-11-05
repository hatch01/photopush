import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Supported pin colors based on the specifications (6 colors).
enum PinColor {
  black('black', 'Noir', 0xFF1E1E1E),
  white('white', 'Blanc', 0xFFFFFFFF),
  green('green', 'Vert', 0xFF4CAF50),
  yellow('yellow', 'Jaune', 0xFFFFEB3B),
  blue('blue', 'Bleu', 0xFF2196F3),
  purple('purple', 'Violet', 0xFF9C27B0);

  const PinColor(this.name, this.labelFr, this.colorValue);

  final String name;
  final String labelFr;
  final int colorValue;

  static PinColor fromString(String? value) {
    if (value == null) return PinColor.yellow;
    final normalized = value.trim().toLowerCase();
    for (final color in PinColor.values) {
      if (color.name == normalized ||
          color.labelFr.toLowerCase() == normalized) {
        return color;
      }
    }
    return PinColor.yellow;
  }
}

/// Supported pin interaction types.
enum PinType {
  info('info'),
  link('link'),
  both('both');

  const PinType(this.value);

  final String value;

  static PinType fromString(String? value) {
    if (value == null) return PinType.info;
    final normalized = value.trim().toLowerCase();
    for (final type in PinType.values) {
      if (type.value == normalized) {
        return type;
      }
    }
    return PinType.info;
  }
}

/// An interactive pin anchored on a photo slide with normalized coordinates.
@immutable
class Pin {
  Pin({
    String? id,
    required double x,
    required double y,
    double size = 1.0,
    this.color = PinColor.yellow,
    PinType? type,
    this.text,
    this.targetSlideId,
  }) : id = id ?? const Uuid().v4(),
       x = _validateCoordinate(x, 'x'),
       y = _validateCoordinate(y, 'y'),
       size = _validateSize(size),
       type = type ?? _inferType(text, targetSlideId);

  /// Unique identifier of the pin.
  final String id;

  /// Normalized X coordinate on the image, between 0.0 (left) and 1.0 (right).
  final double x;

  /// Normalized Y coordinate on the image, between 0.0 (top) and 1.0 (bottom).
  final double y;

  /// Pin scale multiplier (1.0 to 3.0, step 0.5).
  final double size;

  /// Visual color of the pin.
  final PinColor color;

  /// Interaction type of the pin.
  final PinType type;

  /// Optional text content displayed in the speech bubble (max 400 chars).
  final String? text;

  /// Optional identifier of the destination slide when activated as a link.
  final String? targetSlideId;

  /// Whether the pin has bubble text to display.
  bool get hasText =>
      (type == PinType.info || type == PinType.both) &&
      text != null &&
      text!.trim().isNotEmpty;

  /// Whether the pin navigates to another slide.
  bool get hasLink =>
      (type == PinType.link || type == PinType.both) &&
      targetSlideId != null &&
      targetSlideId!.isNotEmpty;

  static double _validateCoordinate(double value, String axis) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError.value(
        value,
        axis,
        'Coordinate must be a finite number',
      );
    }
    return value.clamp(0.0, 1.0);
  }

  static double _validateSize(double value) {
    if (value.isNaN || value.isInfinite) return 1.0;
    return value.clamp(1.0, 3.0);
  }

  static PinType _inferType(String? text, String? targetSlideId) {
    final hasText = text != null && text.trim().isNotEmpty;
    final hasLink = targetSlideId != null && targetSlideId.isNotEmpty;
    if (hasText && hasLink) return PinType.both;
    if (hasLink) return PinType.link;
    return PinType.info;
  }

  static const Object _sentinel = Object();

  Pin copyWith({
    String? id,
    double? x,
    double? y,
    double? size,
    PinColor? color,
    PinType? type,
    Object? text = _sentinel,
    Object? targetSlideId = _sentinel,
  }) {
    return Pin(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      color: color ?? this.color,
      type: type ?? this.type,
      text: identical(text, _sentinel) ? this.text : text as String?,
      targetSlideId: identical(targetSlideId, _sentinel)
          ? this.targetSlideId
          : targetSlideId as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'size': size,
      'color': color.name,
      'type': type.value,
      if (text != null) 'text': text,
      if (targetSlideId != null) 'targetSlideId': targetSlideId,
    };
  }

  factory Pin.fromJson(Map<String, dynamic> json) {
    final rawX = json['x'];
    final rawY = json['y'];
    final rawSize = json['size'];

    final double x = rawX is num ? rawX.toDouble() : 0.0;
    final double y = rawY is num ? rawY.toDouble() : 0.0;
    final double size = rawSize is num ? rawSize.toDouble() : 1.0;

    return Pin(
      id: json['id'] as String?,
      x: x,
      y: y,
      size: size,
      color: PinColor.fromString(json['color'] as String?),
      type: json['type'] != null
          ? PinType.fromString(json['type'] as String?)
          : null,
      text: json['text'] as String?,
      targetSlideId: json['targetSlideId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pin &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          x == other.x &&
          y == other.y &&
          size == other.size &&
          color == other.color &&
          type == other.type &&
          text == other.text &&
          targetSlideId == other.targetSlideId;

  @override
  int get hashCode =>
      Object.hash(id, x, y, size, color, type, text, targetSlideId);

  @override
  String toString() =>
      'Pin(id: $id, pos: (${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}), '
      'size: $size, color: ${color.name}, type: ${type.value})';
}
