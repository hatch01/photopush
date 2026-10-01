import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:serverpod_database/serverpod_database.dart';
import '../../client.dart';

final assetRepositoryProvider = Provider<LocalAssetRepository>((ref) {
  return LocalAssetRepository(dbSession);
});

class LocalAssetRepository {
  final ClientDatabaseSession session;

  LocalAssetRepository(this.session);

  Future<Asset?> findBySha256(String sha256) async {
    return Asset.db.findFirstRow(
      session,
      where: (t) => t.sha256.equals(sha256),
    );
  }

  Future<Asset> create({
    required UuidValue id,
    required String sha256,
    required String localPath,
    required String mimeType,
    required int byteSize,
    String? originalName,
  }) async {
    final asset = Asset(
      id: id,
      sha256: sha256,
      localPath: localPath,
      mimeType: mimeType,
      byteSize: byteSize,
      originalName: originalName,
      syncState: 'local',
      createdAt: DateTime.now(),
    );
    return Asset.db.insertRow(session, asset);
  }
}