import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/controllers/albums_controller.dart';
import 'package:photopush/services/services.dart';

void main() {
  group('AlbumsController', () {
    late Directory tempRootDir;
    late AlbumStorageService storageService;
    late AlbumsController controller;

    setUp(() {
      tempRootDir = Directory.systemTemp.createTempSync('controller_test_');
      storageService = AlbumStorageService(
        baseDirectoryResolver: () async => tempRootDir,
      );
      controller = AlbumsController(storageService: storageService);
    });

    tearDown(() {
      if (tempRootDir.existsSync()) {
        tempRootDir.deleteSync(recursive: true);
      }
    });

    test('starts with empty list and loads cleanly', () async {
      expect(controller.allAlbums, isEmpty);
      await controller.loadAlbums();
      expect(controller.allAlbums, isEmpty);
      expect(controller.isLoading, isFalse);
    });

    test('creates album and updates allAlbums', () async {
      final album = await controller.createAlbum('Islande');
      expect(album.name, 'Islande');
      expect(controller.allAlbums.length, 1);
      expect(controller.allAlbums.first.albumName, 'Islande');
    });

    test('search filters albums correctly', () async {
      await controller.createAlbum('Islande');
      await controller.createAlbum('Norvège');
      await controller.createAlbum('Irlande');

      expect(controller.filteredAlbums.length, 3);

      controller.setSearchQuery('land');
      expect(controller.filteredAlbums.length, 2);
      expect(controller.filteredAlbums.map((a) => a.albumName).toList(), [
        'Irlande',
        'Islande',
      ]);

      controller.clearSearch();
      expect(controller.filteredAlbums.length, 3);
    });

    test('renames album', () async {
      await controller.createAlbum('Ancien');
      await controller.renameAlbum('Ancien', 'Nouveau');

      expect(controller.allAlbums.length, 1);
      expect(controller.allAlbums.first.albumName, 'Nouveau');
    });

    test('duplicates album', () async {
      await controller.createAlbum('Vacances');
      await controller.duplicateAlbum('Vacances');

      expect(controller.allAlbums.length, 2);
      expect(controller.allAlbums.map((a) => a.albumName).toList(), [
        'Vacances',
        'Vacances (copie)',
      ]);
    });

    test('deletes album', () async {
      await controller.createAlbum('A Supprimer');
      expect(controller.allAlbums.length, 1);

      await controller.deleteAlbum('A Supprimer');
      expect(controller.allAlbums, isEmpty);
    });
  });
}
