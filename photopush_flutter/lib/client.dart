import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_database/serverpod_database.dart';

const bool isOnline = bool.fromEnvironment('PP_ONLINE', defaultValue: false);
final serverUrl = getServerUrl();

late final Client client;
late final ClientDatabaseSession dbSession;

Future<void> initializeClient() async {
  client = Client(await serverUrl);

  if (isOnline) {
    client.connectivityMonitor = FlutterConnectivityMonitor();
    client.authSessionManager = FlutterAuthSessionManager();
    unawaited(client.auth.initialize());
  }

  final dbPath = await _resolveDatabasePath('photopush.db');
  dbSession = await client.createSession(dbPath, isDebugMode: kDebugMode);
}

Future<String> _resolveDatabasePath(String fileName) async {
  if (kIsWeb) return fileName;
  final dir = await getApplicationSupportDirectory();
  return p.join(dir.path, fileName);
}
