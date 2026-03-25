import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'storage_service.dart';

/// [StorageService] backed by [FirebaseStorage].
final class FirebaseStorageService implements StorageService {
  FirebaseStorageService(this._storage);

  final FirebaseStorage _storage;

  @override
  Reference reference(String path) => _storage.ref(path);

  @override
  Future<String> storeAsset({
    required String remotePath,
    required Uint8List bytes,
    String? contentType,
    Map<String, String>? customMetadata,
  }) async {
    final ref = _storage.ref(remotePath);
    try {
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: customMetadata,
        ),
      );
      return ref.getDownloadURL();
    } on FirebaseException catch (e, st) {
      appLog.severe('storeAsset failed: $remotePath', e, st);
      rethrow;
    }
  }

  @override
  Future<void> deleteAsset(String remotePath) async {
    try {
      await _storage.ref(remotePath).delete();
    } on FirebaseException catch (e, st) {
      appLog.severe('deleteAsset failed: $remotePath', e, st);
      rethrow;
    }
  }

  @override
  Future<String> getDownloadUrl(String remotePath) async {
    try {
      return _storage.ref(remotePath).getDownloadURL();
    } on FirebaseException catch (e, st) {
      appLog.severe('getDownloadUrl failed: $remotePath', e, st);
      rethrow;
    }
  }
}
