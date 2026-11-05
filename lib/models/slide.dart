import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'image_source.dart';
import 'pin.dart';

/// The type of slide in an album.
enum SlideType {
  photo('photo'),
  comment('comment');

  const SlideType(this.value);

  final String value;

  static SlideType fromString(String? value) {
    if (value == null) return SlideType.photo;
    final normalized = value.trim().toLowerCase();
    for (final type in SlideType.values) {
      if (type.value == normalized) {
        return type;
      }
    }
    return SlideType.photo;
  }
}

/// A slide inside an album, which can be either a photo slide or a comment slide.
@immutable
class Slide {
  Slide({
    String? id,
    this.type = SlideType.photo,
    String? title,
    this.comment,
    this.image,
    List<Pin>? pins,
  }) : id = id ?? const Uuid().v4(),
       title = _sanitizeTitle(title),
       pins = List<Pin>.unmodifiable(pins ?? const <Pin>[]);

  /// Unique identifier of the slide.
  final String id;

  /// Type of slide (photo or standalone comment).
  final SlideType type;

  /// Title of the slide (up to 40 characters).
  final String title;

  /// Text comment or notes associated with the slide.
  final String? comment;

  /// Image information for photo slides (null for text-only comments).
  final ImageSource? image;

  /// Interactive pins anchored on this slide.
  final List<Pin> pins;

  /// Whether this slide is a photo slide.
  bool get isPhoto => type == SlideType.photo;

  /// Whether this slide is a comment slide.
  bool get isComment => type == SlideType.comment;

  /// Whether this slide has an image attached.
  bool get hasImage => image != null && image!.path.isNotEmpty;

  /// Whether this slide has interactive pins.
  bool get hasPins => pins.isNotEmpty;

  /// Whether this slide has comment text.
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  static String _sanitizeTitle(String? title) {
    if (title == null) return '';
    final trimmed = title.trim();
    if (trimmed.length > 40) {
      return trimmed.substring(0, 40);
    }
    return trimmed;
  }

  static const Object _sentinel = Object();

  Slide copyWith({
    String? id,
    SlideType? type,
    String? title,
    Object? comment = _sentinel,
    Object? image = _sentinel,
    List<Pin>? pins,
  }) {
    return Slide(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      comment: identical(comment, _sentinel)
          ? this.comment
          : comment as String?,
      image: identical(image, _sentinel) ? this.image : image as ImageSource?,
      pins: pins ?? this.pins,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      if (comment != null) 'comment': comment,
      if (image != null) 'image': image!.toJson(),
      'pins': pins.map((pin) => pin.toJson()).toList(),
    };
  }

  factory Slide.fromJson(Map<String, dynamic> json) {
    final rawPins = json['pins'];
    final List<Pin> pins = [];
    if (rawPins is List) {
      for (final item in rawPins) {
        if (item is Map<String, dynamic>) {
          pins.add(Pin.fromJson(item));
        }
      }
    }

    final rawImage = json['image'];
    ImageSource? image;
    if (rawImage is Map<String, dynamic>) {
      image = ImageSource.fromJson(rawImage);
    }

    return Slide(
      id: json['id'] as String?,
      type: SlideType.fromString(json['type'] as String?),
      title: json['title'] as String? ?? '',
      comment: json['comment'] as String?,
      image: image,
      pins: pins,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Slide &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          comment == other.comment &&
          image == other.image &&
          listEquals(pins, other.pins);

  @override
  int get hashCode =>
      Object.hash(id, type, title, comment, image, Object.hashAll(pins));

  @override
  String toString() =>
      'Slide(id: $id, type: ${type.value}, title: "$title", pins: ${pins.length})';
}
