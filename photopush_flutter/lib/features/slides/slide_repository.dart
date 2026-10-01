import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:serverpod_database/serverpod_database.dart';
import '../../client.dart';
import '../../core/utils/order_key.dart';

final slideRepositoryProvider = Provider<SlideRepository>((ref) {
  return SlideRepository(dbSession);
});

final albumSlidesProvider =
    FutureProvider.family<List<Slide>, UuidValue>((ref, albumId) async {
  final repo = ref.watch(slideRepositoryProvider);
  return repo.listByAlbum(albumId);
});

final slidePinCountProvider =
    FutureProvider.family<int, UuidValue>((ref, slideId) async {
  final repo = ref.watch(slideRepositoryProvider);
  return repo.countPins(slideId);
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

  Future<int> countPins(UuidValue slideId) async {
    return Pin.db.count(
      session,
      where: (t) => t.slideId.equals(slideId) & t.deletedAt.equals(null),
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

  Future<Slide> createPhotoSlide(
    UuidValue albumId,
    UuidValue assetId,
    String orderKey,
  ) async {
    final slide = Slide(
      id: Uuid().v7obj(),
      albumId: albumId,
      kind: 'photo',
      title: '',
      assetId: assetId,
      orderKey: orderKey,
      hlcWall: DateTime.now().millisecondsSinceEpoch,
      hlcCounter: 0,
      deviceId: 'TODO_LOCAL_DEVICE_ID',
      dirty: 1,
    );

    final inserted = await Slide.db.insertRow(session, slide);
    await recalculateAlbumCover(albumId);
    return inserted;
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
      await recalculateAlbumCover(slide.albumId);
    }
  }

  Future<void> reorderSlides(UuidValue albumId, List<Slide> reordered) async {
    final now = DateTime.now();
    for (var i = 0; i < reordered.length; i++) {
      final s = reordered[i];
      final newKey = OrderKey.keyFromIndex(i);
      if (s.orderKey != newKey) {
        final updated = s.copyWith(
          orderKey: newKey,
          dirty: 1,
          hlcWall: now.millisecondsSinceEpoch,
          updatedAt: now,
        );
        await Slide.db.updateRow(session, updated);
      }
    }
    await recalculateAlbumCover(albumId);
  }

  Future<void> recalculateAlbumCover(UuidValue albumId) async {
    final album = await Album.db.findById(session, albumId);
    if (album == null) return;

    final slides = await listByAlbum(albumId);
    UuidValue? newCoverId;
    for (final s in slides) {
      if (s.assetId != null) {
        newCoverId = s.assetId;
        break;
      }
    }

    if (album.coverAssetId != newCoverId) {
      final updatedAlbum = album.copyWith(coverAssetId: newCoverId);
      await Album.db.updateRow(session, updatedAlbum);
    }
  }
}
