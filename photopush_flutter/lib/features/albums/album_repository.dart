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
}