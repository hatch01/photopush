import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

/// Wraps native sharing and file selection capabilities.
class ShareService {
  const ShareService();

  /// Prompts the user to share a file using the OS share sheet.
  Future<void> shareFile(File file, {String? text}) async {
    final xFile = XFile(file.path);
    // ignore: deprecated_member_use
    await Share.shareXFiles([xFile], text: text);
  }

  /// Prompts the user to pick a `.photopush` file from the device storage.
  Future<File?> pickPhotopushArchive() async {
    const typeGroup = XTypeGroup(
      label: 'PhotoPush Archive',
      extensions: ['photopush'],
    );
    final xFile = await openFile(acceptedTypeGroups: [typeGroup]);
    if (xFile == null) return null;
    return File(xFile.path);
  }
}
