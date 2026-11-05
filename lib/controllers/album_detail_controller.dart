import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/models.dart';
import '../services/services.dart';

/// Controller managing the slides, viewing, and editing of an opened album.
class AlbumDetailController extends ChangeNotifier {
  AlbumDetailController({
    required Album initialAlbum,
    AlbumStorageService? storageService,
    ImageProcessorService? imageProcessor,
    ImagePickerService? imagePicker,
  }) : _album = initialAlbum,
       _storageService = storageService ?? AlbumStorageService(),
       _imageProcessor = imageProcessor ?? const ImageProcessorService(),
       _imagePicker = imagePicker ?? DefaultImagePickerService(),
       _currentIndex = initialAlbum.slides.isNotEmpty ? 0 : -1;

  final AlbumStorageService _storageService;
  final ImageProcessorService _imageProcessor;
  final ImagePickerService _imagePicker;

  Album _album;
  int _currentIndex;
  bool _isSaving = false;
  bool _showCommentView = false; // toggle between photo view and comment view

  Album get album => _album;
  int get currentIndex => _currentIndex;
  bool get isSaving => _isSaving;
  bool get showCommentView => _showCommentView;

  List<Slide> get slides => _album.slides;
  bool get isEmpty => slides.isEmpty;
  bool get hasSlides => slides.isNotEmpty;

  Slide? get currentSlide {
    if (_currentIndex >= 0 && _currentIndex < slides.length) {
      return slides[_currentIndex];
    }
    return null;
  }

  void toggleCommentView() {
    _showCommentView = !_showCommentView;
    notifyListeners();
  }

  void nextSlide() {
    if (slides.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % slides.length;
    _showCommentView = false;
    notifyListeners();
  }

  void previousSlide() {
    if (slides.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + slides.length) % slides.length;
    _showCommentView = false;
    notifyListeners();
  }

  void goToSlide(int index) {
    if (index >= 0 && index < slides.length) {
      _currentIndex = index;
      _showCommentView = false;
      notifyListeners();
    }
  }

  /// Adds a photo slide from camera or gallery.
  Future<Slide?> addPhotoSlideFromPicker({
    required bool fromCamera,
    bool storeInApp = true,
    String? customTitle,
    String? comment,
  }) async {
    final file = fromCamera
        ? await _imagePicker.pickFromCamera()
        : await _imagePicker.pickFromGallery();

    if (file == null) return null;

    return addPhotoSlide(
      sourceFile: file,
      storeInApp: storeInApp,
      customTitle: customTitle,
      comment: comment,
    );
  }

  /// Adds a photo slide from an existing [File].
  Future<Slide> addPhotoSlide({
    required File sourceFile,
    bool storeInApp = true,
    String? customTitle,
    String? comment,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final defaultTitle = customTitle?.trim().isNotEmpty == true
          ? customTitle!.trim()
          : 'Titre ${slides.length + 1}';

      final ImageSource imageSource;

      if (storeInApp) {
        final imagesDir = await _storageService.getImagesDirectory(_album.name);
        final processedFile = await _imageProcessor.processAndSaveImage(
          sourceFile: sourceFile,
          targetImagesDir: imagesDir,
        );

        imageSource = ImageSource(
          storageType: ImageStorageType.internal,
          path: p.join('images', p.basename(processedFile.path)),
          originalFileName: p.basename(sourceFile.path),
          fileSize: processedFile.lengthSync(),
        );

        // Generate cover thumbnail if this is the first photo or album has no cover
        if (_album.coverPath == null || _album.slides.isEmpty) {
          final albumDir = await _storageService.getAlbumDirectory(_album.name);
          await _imageProcessor.generateCoverThumbnail(
            photoFile: processedFile,
            albumDir: albumDir,
          );
        }
      } else {
        imageSource = ImageSource(
          storageType: ImageStorageType.gallery,
          path: sourceFile.path,
          originalFileName: p.basename(sourceFile.path),
          fileSize: sourceFile.lengthSync(),
        );
      }

      final newSlide = Slide(
        type: SlideType.photo,
        title: defaultTitle,
        comment: comment,
        image: imageSource,
      );

      final newSlides = List<Slide>.from(slides);
      final insertIndex = _currentIndex >= 0 && _currentIndex < newSlides.length
          ? _currentIndex + 1
          : newSlides.length;

      newSlides.insert(insertIndex, newSlide);

      _album = _album.copyWith(
        slides: newSlides,
        coverPath: _album.coverPath ?? 'cover.jpg',
        updatedAt: DateTime.now().toUtc(),
      );

      await _storageService.saveAlbum(_album);
      _currentIndex = insertIndex;
      _showCommentView = false;
      return newSlide;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Adds a text-only comment slide.
  Future<Slide> addCommentSlide({
    required String commentText,
    String? customTitle,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final defaultTitle = customTitle?.trim().isNotEmpty == true
          ? customTitle!.trim()
          : 'Titre ${slides.length + 1}';

      final newSlide = Slide(
        type: SlideType.comment,
        title: defaultTitle,
        comment: commentText.trim(),
      );

      final newSlides = List<Slide>.from(slides);
      final insertIndex = _currentIndex >= 0 && _currentIndex < newSlides.length
          ? _currentIndex + 1
          : newSlides.length;

      newSlides.insert(insertIndex, newSlide);

      _album = _album.copyWith(
        slides: newSlides,
        updatedAt: DateTime.now().toUtc(),
      );

      await _storageService.saveAlbum(_album);
      _currentIndex = insertIndex;
      _showCommentView = true;
      return newSlide;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Updates the title of the current slide.
  Future<void> updateCurrentSlideTitle(String newTitle) async {
    if (currentSlide == null) return;
    final updatedSlide = currentSlide!.copyWith(title: newTitle);
    await _replaceCurrentSlide(updatedSlide);
  }

  /// Updates the comment of the current slide.
  Future<void> updateCurrentSlideComment(String? newComment) async {
    if (currentSlide == null) return;
    final updatedSlide = currentSlide!.copyWith(comment: newComment?.trim());
    await _replaceCurrentSlide(updatedSlide);
  }

  /// Deletes the currently displayed slide.
  Future<void> deleteCurrentSlide() async {
    if (currentSlide == null) return;

    final newSlides = List<Slide>.from(slides)..removeAt(_currentIndex);
    _album = _album.copyWith(
      slides: newSlides,
      updatedAt: DateTime.now().toUtc(),
    );

    await _storageService.saveAlbum(_album);

    if (_currentIndex >= newSlides.length) {
      _currentIndex = newSlides.length - 1;
    }
    notifyListeners();
  }

  Future<void> _replaceCurrentSlide(Slide updatedSlide) async {
    final newSlides = List<Slide>.from(slides);
    newSlides[_currentIndex] = updatedSlide;

    _album = _album.copyWith(
      slides: newSlides,
      updatedAt: DateTime.now().toUtc(),
    );

    await _storageService.saveAlbum(_album);
    notifyListeners();
  }

  /// Resolves the file for an image source.
  Future<File?> resolveImageFile(ImageSource? source) async {
    if (source == null) return null;
    if (source.isGallery) {
      final file = File(source.path);
      return file.existsSync() ? file : null;
    }

    final albumDir = await _storageService.getAlbumDirectory(_album.name);
    final file = File(p.join(albumDir.path, source.path));
    return file.existsSync() ? file : null;
  }
}
