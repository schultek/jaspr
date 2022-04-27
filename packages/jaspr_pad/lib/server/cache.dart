import 'dart:convert';
import 'dart:io';

import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class StorageCache {
  late Future<StorageApi> _storage;
  final _bucket = 'jasprpad_compile_cache';

  StorageCache() {
    _storage = _initStorage();
  }

  Future<StorageApi> _initStorage() async {
    // Read the service account credentials from the file.
    var jsonCredentials = File('serviceAccountKey.json').readAsStringSync();
    var credentials = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    // Get an HTTP authenticated client using the service account credentials.
    var scopes = [StorageApi.devstorageFullControlScope];
    var client = await auth.clientViaServiceAccount(credentials, scopes);

    return StorageApi(client);
  }

  Future<String?> getCachedResult(int hash) async {
    var storage = await _storage;
    try {
      var dataStream = await storage.objects
          .get(_bucket, 'compilation_result_$hash.js', downloadOptions: DownloadOptions.fullMedia) as Media;
      var result = await utf8.decodeStream(dataStream.stream);
      await storage.objects.patch(Object(customTime: DateTime.now()), _bucket, 'compilation_result_$hash.js');
      return result;
    } catch (e) {
      print("[WARNING]: Failed to read cache compilation result: $e");
      return null;
    }
  }

  Future<void> cacheResult(int hash, String mainJs) async {
    var storage = await _storage;
    try {
      var encoded = utf8.encode(mainJs);
      await storage.objects.insert(
        Object(customTime: DateTime.now()),
        _bucket,
        name: 'compilation_result_$hash.js',
        uploadMedia: Media(Stream.value(encoded), encoded.length, contentType: 'text/javascript'),
      );
    } catch (e) {
      print("[WARNING]: Failed to cache compilation result: $e");
    }
  }
}
