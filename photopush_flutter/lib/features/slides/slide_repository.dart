import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:serverpod_database/serverpod_database.dart';
import '../../client.dart';

final slideRepositoryProvider = Provider<SlideRepository>((ref) {
  return SlideRepository(dbSession);
});

final albumSlidesProvider = FutureProvider.family<List<Slide>, UuidValue>((
  ref,
  albumId,
) async {
  final repo = ref.watch(slideRepositoryProvider);
  return repo.listByAlbum(albumId);
});

class SlideRepository {
  final ClientDatabaseSession session;

  SlideRepository(this.session);

  Future<List<Slide>> listByAlbum(UuidValue albumId) async {
    return Slide.db.find(
      session,
      where: (t) => t.albumId.equals(albumId) & t.deletedAt.equals(null),
      orderBy: (t) => t.orderKey,
    );
  }

  Future<Slide> createCommentSlide(
    UuidValue albumId,
    String text,
    String title,
    String orderKey,
  ) async {
    final slide = Slide(
      id: Uuid().v7obj(),
      albumId: albumId,
      kind: 'comment',
      title: title,
      commentText: text,
      orderKey: orderKey,
      hlcWall: DateTime.now().millisecondsSinceEpoch,
      hlcCounter: 0,
      deviceId: 'TODO_LOCAL_DEVICE_ID',
      dirty: 1,
    );
    return Slide.db.insertRow(session, slide);
  }

  Future<void> updateComment(UuidValue id, String text, String title) async {
    var slide = await Slide.db.findById(session, id);
    if (slide != null) {
      slide = slide.copyWith(
        commentText: text,
        title: title,
        dirty: 1,
        hlcWall: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now(),
      );
      await Slide.db.updateRow(session, slide);
    }
  }

  Future<void> moveToTrash(UuidValue id) async {
    var slide = await Slide.db.findById(session, id);
    if (slide != null) {
      slide = slide.copyWith(
        deletedAt: DateTime.now(),
        dirty: 1,
        hlcWall: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now(),
      );
      await Slide.db.updateRow(session, slide);
    }
  }
}
