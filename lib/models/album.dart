import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'pin.dart';
import 'slide.dart';

/// An interactive photo album representing the contents of `album.json`.
@immutable
class Album {
  Album({
    this.version = currentVersion,
    String? id,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.coverPath,
    List<Slide>? slides,
  }) : id = id ?? const Uuid().v4(),
       name = _validateName(name),
       createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc(),
       slides = List<Slide>.unmodifiable(slides ?? const <Slide>[]);

  /// Current JSON schema version.
  static const int currentVersion = 1;

  /// Characters forbidden in folder/album names for filesystem portability.
  static final RegExp forbiddenCharactersRegex = RegExp(r'[\\/:*?"<>|]');

  /// Schema version of the album format.
  final int version;

  /// Unique identifier of the album.
  final String id;

  /// Name of the album (1 to 80 characters, trimmed).
  final String name;

  /// Creation timestamp (UTC).
  final DateTime createdAt;

  /// Last modification timestamp (UTC).
  final DateTime updatedAt;

  /// Relative path to the cover thumbnail (e.g. 'cover.jpg').
  final String? coverPath;

  /// Ordered list of slides composing the album.
  final List<Slide> slides;

  /// Number of slides in the album.
  int get slideCount => slides.length;

  /// Whether the album has no slides.
  bool get isEmpty => slides.isEmpty;

  /// Whether the album has at least one slide.
  bool get isNotEmpty => slides.isNotEmpty;

  /// The first slide of the album, if any.
  Slide? get firstSlide => slides.isEmpty ? null : slides.first;

  /// Validates an album name according to specifications.
  static bool isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 80) return false;
    if (forbiddenCharactersRegex.hasMatch(trimmed)) return false;
    return true;
  }

  /// Sanitizes an album name by trimming and removing forbidden characters.
  static String sanitizeName(String name) {
    var sanitized = name.replaceAll(forbiddenCharactersRegex, '').trim();
    if (sanitized.length > 80) {
      sanitized = sanitized.substring(0, 80).trim();
    }
    return sanitized;
  }

  static String _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Album name cannot be empty');
    }
    if (trimmed.length > 80) {
      throw ArgumentError.value(
        name,
        'name',
        'Album name cannot exceed 80 characters',
      );
    }
    if (forbiddenCharactersRegex.hasMatch(trimmed)) {
      throw ArgumentError.value(
        name,
        'name',
        'Album name contains forbidden characters (/ \\ : * ? " < > |)',
      );
    }
    return trimmed;
  }

  /// Finds a slide by its unique ID.
  Slide? findSlideById(String slideId) {
    for (final slide in slides) {
      if (slide.id == slideId) return slide;
    }
    return null;
  }

  /// Finds the 0-based index of a slide by its unique ID, or -1 if not found.
  int getSlideIndex(String slideId) {
    return slides.indexWhere((s) => s.id == slideId);
  }

  /// Validates data integrity and returns a list of detected issues/warnings.
  List<String> validate() {
    final issues = <String>[];
    final slideIds = slides.map((s) => s.id).toSet();

    for (var i = 0; i < slides.length; i++) {
      final slide = slides[i];

      if (slide.isPhoto && !slide.hasImage) {
        issues.add(
          'Slide ${i + 1} ("${slide.title}") is marked as photo but has no image',
        );
      }

      for (final pin in slide.pins) {
        if (pin.hasLink) {
          if (!slideIds.contains(pin.targetSlideId)) {
            issues.add(
              'Pin "${pin.id}" in slide ${i + 1} points to non-existent target "${pin.targetSlideId}"',
            );
          }
        }
      }
    }

    return issues;
  }

  /// Returns a copy of the album where broken links in pins have been detached.
  Album cleanOrphanPins() {
    final slideIds = slides.map((s) => s.id).toSet();
    var modified = false;

    final cleanedSlides = slides.map((slide) {
      var slideModified = false;
      final cleanedPins = slide.pins.map((pin) {
        if (pin.hasLink && !slideIds.contains(pin.targetSlideId)) {
          slideModified = true;
          modified = true;
          return pin.copyWith(
            targetSlideId: null,
            type: pin.hasText ? PinType.info : PinType.info,
          );
        }
        return pin;
      }).toList();

      if (slideModified) {
        return slide.copyWith(pins: cleanedPins);
      }
      return slide;
    }).toList();

    if (!modified) return this;

    return copyWith(slides: cleanedSlides, updatedAt: DateTime.now().toUtc());
  }

  static const Object _sentinel = Object();

  Album copyWith({
    int? version,
    Object? id = _sentinel,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? coverPath = _sentinel,
    List<Slide>? slides,
  }) {
    return Album(
      version: version ?? this.version,
      id: identical(id, _sentinel) ? this.id : id as String?,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverPath: identical(coverPath, _sentinel)
          ? this.coverPath
          : coverPath as String?,
      slides: slides ?? this.slides,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (coverPath != null) 'coverPath': coverPath,
      'slides': slides.map((slide) => slide.toJson()).toList(),
    };
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    final rawVersion = json['version'];
    final int version = rawVersion is int ? rawVersion : currentVersion;

    final rawSlides = json['slides'];
    final List<Slide> slides = [];
    if (rawSlides is List) {
      for (final item in rawSlides) {
        if (item is Map<String, dynamic>) {
          slides.add(Slide.fromJson(item));
        }
      }
    }

    final rawCreatedAt = json['createdAt'];
    DateTime createdAt = DateTime.now().toUtc();
    if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt)?.toUtc() ?? createdAt;
    }

    final rawUpdatedAt = json['updatedAt'];
    DateTime updatedAt = DateTime.now().toUtc();
    if (rawUpdatedAt is String) {
      updatedAt = DateTime.tryParse(rawUpdatedAt)?.toUtc() ?? updatedAt;
    }

    return Album(
      version: version,
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Nouvel Album',
      createdAt: createdAt,
      updatedAt: updatedAt,
      coverPath: json['coverPath'] as String?,
      slides: slides,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          id == other.id &&
          name == other.name &&
          coverPath == other.coverPath &&
          listEquals(slides, other.slides);

  @override
  int get hashCode =>
      Object.hash(version, id, name, coverPath, Object.hashAll(slides));

  @override
  String toString() =>
      'Album(id: $id, name: "$name", version: $version, slides: ${slides.length})';
}
