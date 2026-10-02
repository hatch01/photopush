import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Archive Codec (.photopush ZIP) tests (RF-142, RF-143)', () {
    test(
      'JSON manifest packs into and unpacks from ZIP without corruption',
      () {
        final manifest = {
          'format': 'photopush',
          'version': 1,
          'album': {
            'id': '0192f1a0-8e11-7a3e-a1b2-c3d4e5f60789',
            'name': 'Vacances 2026',
          },
          'slides': [
            {
              'id': '0192f1a0-8e11-7a3e-a1b2-c3d4e5f6078a',
              'kind': 'comment',
              'title': 'Introduction',
              'commentText': 'Bienvenue dans notre voyage.',
              'orderKey': '000000',
              'pins': [],
            },
          ],
          'assets': [],
        };

        final manifestBytes = utf8.encode(jsonEncode(manifest));

        // 1. Pack into archive
        final archive = Archive();
        archive.addFile(
          ArchiveFile('album.json', manifestBytes.length, manifestBytes),
        );
        final zipEncoder = ZipEncoder();
        final zipBytes = zipEncoder.encode(archive);

        expect(zipBytes, isNotEmpty);

        // 2. Unpack from archive
        final unzippedArchive = ZipDecoder().decodeBytes(zipBytes);
        final extractedManifestFile = unzippedArchive.firstWhere(
          (f) => f.name == 'album.json',
        );
        final extractedJsonString = utf8.decode(
          extractedManifestFile.content as List<int>,
        );
        final extractedManifest =
            jsonDecode(extractedJsonString) as Map<String, dynamic>;

        expect(extractedManifest['format'], equals('photopush'));
        expect(extractedManifest['version'], equals(1));
        expect(extractedManifest['album']['name'], equals('Vacances 2026'));
        expect(extractedManifest['slides'], hasLength(1));
        expect(extractedManifest['slides'][0]['title'], equals('Introduction'));
      },
    );
  });
}
