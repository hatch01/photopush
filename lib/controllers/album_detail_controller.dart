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
  final List<int> _navigationHistory = [];

  Album get album => _album;
  int get currentIndex => _currentIndex;
  bool get isSaving => _isSaving;
  bool get showCommentView => _showCommentView;
  bool get canGoBack => _navigationHistory.isNotEmpty;

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
    _navigationHistory.clear(); // Swipe resets history
    notifyListeners();
  }

  void previousSlide() {
    if (slides.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + slides.length) % slides.length;
    _showCommentView = false;
    _navigationHistory.clear(); // Swipe resets history
    notifyListeners();
  }

  /// Jumps directly to a slide without pushing to history (e.g. from grid)
  void goToSlide(int index) {
    if (index >= 0 && index < slides.length && index != _currentIndex) {
      _currentIndex = index;
      _showCommentView = false;
      _navigationHistory.clear();
      notifyListeners();
    }
  }

  /// Navigates to a slide via a pin link, keeping track of history.
  void navigateToSlideViaLink(int index) {
    if (index >= 0 && index < slides.length && index != _currentIndex) {
      _navigationHistory.add(_currentIndex);
      _currentIndex = index;
      _showCommentView = false;
      notifyListeners();
    }
  }

  /// Returns to the previous slide in the navigation history.
  void goBackInHistory() {
    if (_navigationHistory.isNotEmpty) {
      _currentIndex = _navigationHistory.removeLast();
      _showCommentView = false;
      notifyListeners();
    }
  }

  /// Reorders slides by moving a slide from [oldIndex] to [newIndex].
  Future<void> reorderSlides(int oldIndex, int newIndex) async {
    if (oldIndex < 0 ||
        oldIndex >= slides.length ||
        newIndex < 0 ||
        newIndex >= slides.length) {
      return;
    }

    if (oldIndex == newIndex) return;

    final newSlides = List<Slide>.from(slides);
    final slide = newSlides.removeAt(oldIndex);
    newSlides.insert(newIndex, slide);

    // Update currentIndex to follow the slide we were currently looking at
    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
      _currentIndex--;
    } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
      _currentIndex++;
    }

    _album = _album.copyWith(
      slides: newSlides,
      updatedAt: DateTime.now().toUtc(),
    );

    await _storageService.saveAlbum(_album);
    notifyListeners();
  }

  /// Reassociates an image for a slide that lost its file.
  Future<void> reassociateImage(
    String slideId, {
    required bool fromCamera,
    bool storeInApp = true,
  }) async {
    final file = fromCamera
        ? await _imagePicker.pickFromCamera()
        : await _imagePicker.pickFromGallery();
    if (file == null) return;

    final slideIndex = slides.indexWhere((s) => s.id == slideId);
    if (slideIndex == -1) return;

    _isSaving = true;
    notifyListeners();

    try {
      final ImageSource imageSource;

      if (storeInApp) {
        final imagesDir = await _storageService.getImagesDirectory(_album.name);
        final processedFile = await _imageProcessor.processAndSaveImage(
          sourceFile: file,
          targetImagesDir: imagesDir,
        );

        imageSource = ImageSource(
          storageType: ImageStorageType.internal,
          path: p.join('images', p.basename(processedFile.path)),
          originalFileName: p.basename(file.path),
          fileSize: processedFile.lengthSync(),
        );
      } else {
        imageSource = ImageSource(
          storageType: ImageStorageType.gallery,
          path: file.path,
          originalFileName: p.basename(file.path),
          fileSize: file.lengthSync(),
        );
      }

      final updatedSlide = slides[slideIndex].copyWith(image: imageSource);
      final newSlides = List<Slide>.from(slides);
      newSlides[slideIndex] = updatedSlide;

      _album = _album.copyWith(
        slides: newSlides,
        updatedAt: DateTime.now().toUtc(),
      );

      await _storageService.saveAlbum(_album);
    } finally {
      _isSaving = false;
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

  /// Adds a new pin to the current slide.
  Future<void> addPin(Pin pin) async {
    if (currentSlide == null) return;
    final newPins = List<Pin>.from(currentSlide!.pins)..add(pin);
    final updatedSlide = currentSlide!.copyWith(pins: newPins);
    await _replaceCurrentSlide(updatedSlide);
  }

  /// Updates an existing pin on the current slide.
  Future<void> updatePin(Pin pin) async {
    if (currentSlide == null) return;
    final newPins = currentSlide!.pins
        .map((p) => p.id == pin.id ? pin : p)
        .toList();
    final updatedSlide = currentSlide!.copyWith(pins: newPins);
    await _replaceCurrentSlide(updatedSlide);
  }

  /// Removes a pin from the current slide.
  Future<void> deletePin(String pinId) async {
    if (currentSlide == null) return;
    final newPins = currentSlide!.pins.where((p) => p.id != pinId).toList();
    final updatedSlide = currentSlide!.copyWith(pins: newPins);
    await _replaceCurrentSlide(updatedSlide);
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
