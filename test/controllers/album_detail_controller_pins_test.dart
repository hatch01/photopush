import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:photopush/controllers/album_detail_controller.dart';
import 'package:photopush/models/models.dart';
import 'package:photopush/services/services.dart';

void main() {
  group('US-3 : AlbumDetailController (Interactive Pins Management)', () {
    late Directory tempRootDir;
    late AlbumStorageService storageService;
    late Album initialAlbum;
    late AlbumDetailController controller;

    setUp(() {
      tempRootDir = Directory.systemTemp.createTempSync(
        'detail_ctrl_test_pins_',
      );
      storageService = AlbumStorageService(
        baseDirectoryResolver: () async => tempRootDir,
      );

      final photo = File(p.join(tempRootDir.path, 'img.jpg'));
      photo.writeAsBytesSync(img.encodeJpg(img.Image(width: 10, height: 10)));

      final slide1 = Slide(
        id: 's1',
        title: 'Vue 1',
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'img.jpg',
        ),
      );

      initialAlbum = Album(name: 'Test Punaise', slides: [slide1]);
      storageService.saveAlbum(initialAlbum);

      controller = AlbumDetailController(
        initialAlbum: initialAlbum,
        storageService: storageService,
      );
    });

    tearDown(() {
      if (tempRootDir.existsSync()) {
        tempRootDir.deleteSync(recursive: true);
      }
    });

    test('adds a pin to current slide', () async {
      final pin = Pin(
        id: 'p1',
        x: 0.5,
        y: 0.5,
        color: PinColor.green,
        text: 'La foret',
      );

      await controller.addPin(pin);

      expect(controller.currentSlide!.pins.length, 1);
      final storedPin = controller.currentSlide!.pins.first;
      expect(storedPin.id, 'p1');
      expect(storedPin.x, 0.5);
      expect(storedPin.color, PinColor.green);
      expect(storedPin.text, 'La foret');
    });

    test('updates an existing pin', () async {
      final pin = Pin(id: 'p1', x: 0.1, y: 0.1);
      await controller.addPin(pin);
      expect(controller.currentSlide!.pins.first.x, 0.1);

      final updatedPin = pin.copyWith(
        x: 0.9,
        y: 0.9,
        color: PinColor.purple,
        text: 'Mis à jour',
      );

      await controller.updatePin(updatedPin);

      expect(controller.currentSlide!.pins.length, 1);
      final storedPin = controller.currentSlide!.pins.first;
      expect(storedPin.x, 0.9);
      expect(storedPin.color, PinColor.purple);
      expect(storedPin.text, 'Mis à jour');
    });

    test('deletes an existing pin', () async {
      final pin1 = Pin(id: 'p1', x: 0.1, y: 0.1);
      final pin2 = Pin(id: 'p2', x: 0.2, y: 0.2);

      await controller.addPin(pin1);
      await controller.addPin(pin2);
      expect(controller.currentSlide!.pins.length, 2);

      await controller.deletePin('p1');

      expect(controller.currentSlide!.pins.length, 1);
      expect(controller.currentSlide!.pins.first.id, 'p2');
    });
  });
}
