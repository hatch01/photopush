import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:serverpod_database/serverpod_database.dart';
import '../../client.dart';

final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  return AlbumRepository(dbSession);
});

final albumListProvider = FutureProvider<List<Album>>((ref) async {
  final repo = ref.watch(albumRepositoryProvider);
  return repo.listAll();
});

final trashedAlbumListProvider = FutureProvider<List<Album>>((ref) async {
  final repo = ref.watch(albumRepositoryProvider);
  return repo.listTrashed();
});

class AlbumRepository {
  final ClientDatabaseSession session;

  AlbumRepository(this.session);

  Future<List<Album>> listAll() async {
    return Album.db.find(
      session,
      where: (t) => t.deletedAt.equals(null),
      orderBy: (t) => t.name,
    );
  }

  Future<List<Album>> listTrashed() async {
    return Album.db.find(
      session,
      where: (t) => t.deletedAt.notEquals(null),
      orderBy: (t) => t.deletedAt.desc(),
    );
  }

  Future<Album?> findByName(String name) async {
    return Album.db.findFirstRow(
      session,
      where: (t) => t.name.ilike(name) & t.deletedAt.equals(null),
    );
  }

  Future<Album> create(String name) async {
    var album = Album(
      id: Uuid().v7obj(),
      name: name,
      hlcWall: DateTime.now().millisecondsSinceEpoch,
      hlcCounter: 0,
      deviceId: 'TODO_LOCAL_DEVICE_ID',
    );
    return Album.db.insertRow(session, album);
  }

  Future<void> rename(UuidValue id, String newName) async {
    var album = await Album.db.findById(session, id);
    if (album != null) {
      album = album.copyWith(
        name: newName,
        hlcWall: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now(),
      );
      await Album.db.updateRow(session, album);
    }
  }

  Future<void> moveToTrash(UuidValue id) async {
    var album = await Album.db.findById(session, id);
    if (album != null) {
      album = album.copyWith(
        deletedAt: DateTime.now(),
        hlcWall: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now(),
      );
      await Album.db.updateRow(session, album);
    }
  }

  Future<void> restoreFromTrash(UuidValue id) async {
    var album = await Album.db.findById(session, id);
    if (album != null) {
      album = album.copyWith(
        deletedAt: null,
        hlcWall: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now(),
      );
      await Album.db.updateRow(session, album);
    }
  }

  Future<void> duplicate(UuidValue id, String newName) async {
    // For now, creating a new empty album since slides are not yet implemented.
    // TODO: deeply duplicate slides and pins when implemented
    await create(newName);
  }
}