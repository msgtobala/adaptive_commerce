import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Abstraction over object storage — swap in a fake for tests.
abstract class StorageService {
  /// [FirebaseStorage.ref] for advanced flows (streams, metadata).
  Reference reference(String path);

  /// Uploads [bytes] to [remotePath] and returns a download URL.
  ///
  /// Example: `storeAsset(remotePath: StoragePaths.shopMedia('hero', 'dog.jpg'), bytes: data)`.
  Future<String> storeAsset({
    required String remotePath,
    required Uint8List bytes,
    String? contentType,
    Map<String, String>? customMetadata,
  });

  Future<void> deleteAsset(String remotePath);

  Future<String> getDownloadUrl(String remotePath);
}
