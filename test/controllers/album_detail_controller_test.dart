import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:photopush/controllers/album_detail_controller.dart';
import 'package:photopush/models/models.dart';
import 'package:photopush/services/services.dart';

class FakeImagePickerService implements ImagePickerService {
  FakeImagePickerService({this.fileToReturn});

  File? fileToReturn;

  @override
  Future<File?> pickFromGallery() async => fileToReturn;

  @override
  Future<File?> pickFromCamera() async => fileToReturn;
}

void main() {
  group('AlbumDetailController', () {
    late Directory tempRootDir;
    late AlbumStorageService storageService;
    late Album initialAlbum;
    late AlbumDetailController controller;
    late FakeImagePickerService fakePicker;

    setUp(() {
      tempRootDir = Directory.systemTemp.createTempSync('detail_ctrl_test_');
      storageService = AlbumStorageService(
        baseDirectoryResolver: () async => tempRootDir,
      );
      initialAlbum = Album(name: 'Voyage Test');
      storageService.saveAlbum(initialAlbum);

      fakePicker = FakeImagePickerService();
      controller = AlbumDetailController(
        initialAlbum: initialAlbum,
        storageService: storageService,
        imagePicker: fakePicker,
      );
    });

    tearDown(() {
      if (tempRootDir.existsSync()) {
        tempRootDir.deleteSync(recursive: true);
      }
    });

    File createDummyImageFile(String name) {
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(255, 0, 0));
      final file = File(p.join(tempRootDir.path, name));
      file.writeAsBytesSync(img.encodeJpg(image));
      return file;
    }

    test('initial state for empty album', () {
      expect(controller.isEmpty, isTrue);
      expect(controller.hasSlides, isFalse);
      expect(controller.currentIndex, -1);
      expect(controller.currentSlide, isNull);
    });

    test('adds text-only comment slide and updates album', () async {
      final slide = await controller.addCommentSlide(
        commentText: 'Mon premier commentaire de voyage',
        customTitle: 'Introduction',
      );

      expect(controller.hasSlides, isTrue);
      expect(controller.slides.length, 1);
      expect(controller.currentIndex, 0);
      expect(controller.currentSlide?.title, 'Introduction');
      expect(
        controller.currentSlide?.comment,
        'Mon premier commentaire de voyage',
      );
      expect(controller.currentSlide?.isComment, isTrue);

      // Verify on disk
      final loaded = await storageService.loadAlbum(initialAlbum.name);
      expect(loaded.isSuccess, isTrue);
      expect(loaded.albumOrNull?.slides.length, 1);
      expect(loaded.albumOrNull?.slides.first.id, slide.id);
    });

    test('adds photo slide with internal storage and copies file', () async {
      final photo = createDummyImageFile('dummy.jpg');

      final slide = await controller.addPhotoSlide(
        sourceFile: photo,
        storeInApp: true,
        customTitle: 'Vue Montagne',
        comment: 'Superbe vue',
      );

      expect(controller.slides.length, 1);
      expect(slide.isPhoto, isTrue);
      expect(slide.title, 'Vue Montagne');
      expect(slide.comment, 'Superbe vue');
      expect(slide.image?.isInternal, isTrue);

      final resolvedFile = await controller.resolveImageFile(slide.image);
      expect(resolvedFile, isNotNull);
      expect(resolvedFile!.existsSync(), isTrue);
    });

    test(
      'adds photo slide with gallery link without copying into images',
      () async {
        final photo = createDummyImageFile('gallery_photo.jpg');

        final slide = await controller.addPhotoSlide(
          sourceFile: photo,
          storeInApp: false,
          customTitle: 'Lien Galerie',
        );

        expect(slide.image?.isGallery, isTrue);
        expect(slide.image?.path, photo.path);

        final resolvedFile = await controller.resolveImageFile(slide.image);
        expect(resolvedFile?.path, photo.path);
      },
    );

    test('adds photo via picker', () async {
      final photo = createDummyImageFile('cam.jpg');
      fakePicker.fileToReturn = photo;

      final slide = await controller.addPhotoSlideFromPicker(fromCamera: true);
      expect(slide, isNotNull);
      expect(controller.slides.length, 1);
    });

    test('updates current slide title and comment', () async {
      await controller.addCommentSlide(commentText: 'Texte initial');

      await controller.updateCurrentSlideTitle('Titre Modifié');
      expect(controller.currentSlide?.title, 'Titre Modifié');

      await controller.updateCurrentSlideComment('Texte Modifié');
      expect(controller.currentSlide?.comment, 'Texte Modifié');

      // Verify on disk
      final loaded = await storageService.loadAlbum(initialAlbum.name);
      expect(loaded.albumOrNull?.slides.first.title, 'Titre Modifié');
      expect(loaded.albumOrNull?.slides.first.comment, 'Texte Modifié');
    });

    test('deletes current slide', () async {
      await controller.addCommentSlide(commentText: 'Slide 1');
      await controller.addCommentSlide(commentText: 'Slide 2');

      expect(controller.slides.length, 2);
      expect(controller.currentIndex, 1);

      await controller.deleteCurrentSlide();

      expect(controller.slides.length, 1);
      expect(controller.currentIndex, 0);
      expect(controller.currentSlide?.comment, 'Slide 1');

      await controller.deleteCurrentSlide();
      expect(controller.isEmpty, isTrue);
    });

    test('navigation nextSlide, previousSlide and looping', () async {
      await controller.addCommentSlide(commentText: 'Slide 1');
      await controller.addCommentSlide(commentText: 'Slide 2');
      await controller.addCommentSlide(commentText: 'Slide 3');

      controller.goToSlide(0);
      expect(controller.currentIndex, 0);

      controller.nextSlide();
      expect(controller.currentIndex, 1);

      controller.nextSlide();
      expect(controller.currentIndex, 2);

      // Infinite loop to 0
      controller.nextSlide();
      expect(controller.currentIndex, 0);

      // Loop back to last
      controller.previousSlide();
      expect(controller.currentIndex, 2);
    });
  });
}
