import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:serverpod_database/serverpod_database.dart';
import '../../client.dart';

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  return PinRepository(dbSession);
});

final slidePinsProvider = FutureProvider.family<List<Pin>, UuidValue>((
  ref,
  slideId,
) async {
  final repo = ref.watch(pinRepositoryProvider);
  return repo.listBySlide(slideId);
});

class PinRepository {
  final ClientDatabaseSession session;

  PinRepository(this.session);

  Future<List<Pin>> listBySlide(UuidValue slideId) async {
    return Pin.db.find(
      session,
      where: (t) => t.slideId.equals(slideId) & t.deletedAt.equals(null),
      orderBy: (t) =>
          t.zIndex, // Important to render them in the correct Z order
    );
  }

  Future<Pin> create({
    required UuidValue slideId,
    required double x,
    required double y,
    double sizeScale = 1.0,
    String color = 'black',
  }) async {
    // Get the current max Z-Index for the slide to place the new pin on top
    final currentPins = await listBySlide(slideId);
    final nextZIndex = currentPins.isEmpty ? 0 : currentPins.last.zIndex + 1;

    final pin = Pin(
      id: Uuid().v7obj(),
      slideId: slideId,
      kind: 'neutral',
      x: x,
      y: y,
      sizeScale: sizeScale,
      color: color,
      zIndex: nextZIndex,
      hlcWall: DateTime.now().millisecondsSinceEpoch,
      hlcCounter: 0,
      deviceId: 'TODO_LOCAL_DEVICE_ID',
      createdAt: DateTime.now(),
    );
    return Pin.db.insertRow(session, pin);
  }

  Future<void> update(Pin pin) async {
    final updatedPin = pin.copyWith(
      hlcWall: DateTime.now().millisecondsSinceEpoch,
    );
    await Pin.db.updateRow(session, updatedPin);
  }

  Future<void> moveToTrash(UuidValue id) async {
    var pin = await Pin.db.findById(session, id);
    if (pin != null) {
      pin = pin.copyWith(
        deletedAt: DateTime.now(),
        hlcWall: DateTime.now().millisecondsSinceEpoch,
      );
      await Pin.db.updateRow(session, pin);
    }
  }
}
