import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photopush/models/models.dart';
import 'package:photopush/services/services.dart';

void main() {
  group('AlbumStorageService (US-02 : Atomic Persistence & Resilience)', () {
    late Directory tempRootDir;
    late AlbumStorageService storageService;

    setUp(() {
      tempRootDir = Directory.systemTemp.createTempSync('photopush_test_');
      storageService = AlbumStorageService(
        baseDirectoryResolver: () async => tempRootDir,
      );
    });

    tearDown(() {
      if (tempRootDir.existsSync()) {
        tempRootDir.deleteSync(recursive: true);
      }
    });

    test(
      'saves album atomically to album.json and creates images folder',
      () async {
        final album = Album(
          id: 'album-1',
          name: 'Voyage en Norvège',
          slides: [
            Slide(
              id: 'slide-1',
              type: SlideType.photo,
              title: 'Fjords',
              image: const ImageSource(
                storageType: ImageStorageType.internal,
                path: 'images/fjord.jpg',
              ),
            ),
          ],
        );

        await storageService.saveAlbum(album);

        final albumDir = await storageService.getAlbumDirectory(album.name);
        expect(albumDir.existsSync(), isTrue);

        final targetFile = File(p.join(albumDir.path, 'album.json'));
        expect(targetFile.existsSync(), isTrue);

        final tmpFile = File(p.join(albumDir.path, 'album.json.tmp'));
        expect(tmpFile.existsSync(), isFalse); // clean up after atomic rename

        final imagesDir = Directory(p.join(albumDir.path, 'images'));
        expect(imagesDir.existsSync(), isTrue);

        final result = await storageService.loadAlbum(album.name);
        expect(result.isSuccess, isTrue);
        expect(result.albumOrNull, equals(album));
      },
    );

    test('recovers from album.json.tmp when album.json is missing (interrupted write)', () async {
      final album = Album(
        id: 'album-recovery',
        name: 'Interrupted Album',
        slides: [Slide(title: 'Only Slide')],
      );

      final albumDir = await storageService.getAlbumDirectory(album.name);
      await albumDir.create(recursive: true);

      // Simulate crash right after writing .tmp but before atomic rename
      final tmpFile = File(p.join(albumDir.path, 'album.json.tmp'));
      await tmpFile.writeAsString(
        '{"version": 1, "id": "rec-1", "name": "Interrupted Album", "slides": []}',
      );

      final targetFile = File(p.join(albumDir.path, 'album.json'));
      expect(targetFile.existsSync(), isFalse);

      final loadResult = await storageService.loadAlbum(album.name);

      expect(loadResult.isSuccess, isTrue);
      final loaded = (loadResult as AlbumLoadSuccess).album;
      expect(loaded.name, 'Interrupted Album');

      // Check that .tmp was restored to album.json
      expect(targetFile.existsSync(), isTrue);
    });

    test('recovers from album.json.tmp when album.json is corrupted', () async {
      final albumDir = await storageService.getAlbumDirectory('CorruptWithTmp');
      await albumDir.create(recursive: true);

      // Corrupted album.json
      final targetFile = File(p.join(albumDir.path, 'album.json'));
      await targetFile.writeAsString(
        '{"version": 1, "name": "Broken JSON... TRUNCATED',
      );

      // Valid .tmp file
      final tmpFile = File(p.join(albumDir.path, 'album.json.tmp'));
      await tmpFile.writeAsString(
        '{"version": 1, "name": "CorruptWithTmp", "slides": []}',
      );

      final result = await storageService.loadAlbum('CorruptWithTmp');
      expect(result.isSuccess, isTrue);
      expect((result as AlbumLoadSuccess).album.name, 'CorruptWithTmp');
    });

    test('loadAllAlbums does not block when an album is corrupted and reports AlbumLoadCorrupted', () async {
      final validAlbum1 = Album(name: 'Album A', slides: []);
      final validAlbum2 = Album(name: 'Album C', slides: []);

      await storageService.saveAlbum(validAlbum1);
      await storageService.saveAlbum(validAlbum2);

      // Create Album B which is completely corrupted
      final corruptDir = await storageService.getAlbumDirectory('Album B');
      await corruptDir.create(recursive: true);
      final corruptFile = File(p.join(corruptDir.path, 'album.json'));
      await corruptFile.writeAsString('INVALID_NON_JSON_CONTENT{{{');

      final allResults = await storageService.loadAllAlbums();

      expect(allResults.length, 3);

      expect(allResults[0].albumName, 'Album A');
      expect(allResults[0].isSuccess, isTrue);

      expect(allResults[1].albumName, 'Album B');
      expect(allResults[1].isCorrupted, isTrue);
      expect((allResults[1] as AlbumLoadCorrupted).error, isNotNull);

      expect(allResults[2].albumName, 'Album C');
      expect(allResults[2].isSuccess, isTrue);
    });

    test('albumExists performs case-insensitive directory check', () async {
      final album = Album(name: 'Alpes 2026');
      await storageService.saveAlbum(album);

      expect(await storageService.albumExists('Alpes 2026'), isTrue);
      expect(await storageService.albumExists('alpes 2026'), isTrue);
      expect(await storageService.albumExists('ALPES 2026'), isTrue);
      expect(await storageService.albumExists('Inexistant'), isFalse);
    });

    test(
      'deleteAlbum removes the directory and all contents recursively',
      () async {
        final album = Album(name: 'To Delete');
        await storageService.saveAlbum(album);

        expect(await storageService.albumExists('To Delete'), isTrue);
        await storageService.deleteAlbum('To Delete');
        expect(await storageService.albumExists('To Delete'), isFalse);
      },
    );

    test('renameAlbum renames the directory and updates album.json', () async {
      final album = Album(name: 'Old Name');
      await storageService.saveAlbum(album);

      final renamed = await storageService.renameAlbum('Old Name', 'New Name');
      expect(renamed.name, 'New Name');

      expect(await storageService.albumExists('Old Name'), isFalse);
      expect(await storageService.albumExists('New Name'), isTrue);

      final result = await storageService.loadAlbum('New Name');
      expect(result.isSuccess, isTrue);
      expect(result.albumOrNull?.name, 'New Name');
    });

    test(
      'duplicateAlbum clones album files and generates unique name with new ID',
      () async {
        final original = Album(
          id: 'orig-id',
          name: 'Vacances',
          slides: [
            Slide(
              id: 's1',
              type: SlideType.photo,
              title: 'Plage',
              image: const ImageSource(
                storageType: ImageStorageType.internal,
                path: 'images/photo.jpg',
              ),
            ),
          ],
        );

        await storageService.saveAlbum(original);

        // Add a dummy photo file in images/
        final imagesDir = await storageService.getImagesDirectory(
          original.name,
        );
        final dummyPhoto = File(p.join(imagesDir.path, 'photo.jpg'));
        await dummyPhoto.writeAsString('fake_image_bytes');

        final duplicate1 = await storageService.duplicateAlbum(original.name);
        expect(duplicate1.name, 'Vacances (copie)');
        expect(duplicate1.id, isNot(equals(original.id)));
        expect(duplicate1.slides.length, 1);

        // Check that the image was copied
        final copyImagesDir = await storageService.getImagesDirectory(
          duplicate1.name,
        );
        final copiedPhoto = File(p.join(copyImagesDir.path, 'photo.jpg'));
        expect(copiedPhoto.existsSync(), isTrue);

        // Duplicate again to verify counter increment
        final duplicate2 = await storageService.duplicateAlbum(original.name);
        expect(duplicate2.name, 'Vacances (copie 2)');
      },
    );
  });
}
