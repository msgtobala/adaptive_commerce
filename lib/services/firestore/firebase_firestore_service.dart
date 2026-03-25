import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'firestore_service.dart';

/// [FirestoreService] backed by [FirebaseFirestore].
final class FirebaseFirestoreService implements FirestoreService {
  FirebaseFirestoreService(this._db);

  final FirebaseFirestore _db;

  @override
  DocumentReference<Map<String, dynamic>> doc(String path) => _db.doc(path);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  @override
  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await _db.doc(path).set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e, st) {
      appLog.severe('setDocument failed: $path', e, st);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final snap = await _db.doc(path).get();
      if (!snap.exists) return null;
      return snap.data();
    } on FirebaseException catch (e, st) {
      appLog.severe('getDocument failed: $path', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).update(data);
    } on FirebaseException catch (e, st) {
      appLog.severe('updateDocument failed: $path', e, st);
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String path) async {
    try {
      await _db.doc(path).delete();
    } on FirebaseException catch (e, st) {
      appLog.severe('deleteDocument failed: $path', e, st);
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchDocument(String path) {
    return _db.doc(path).snapshots().map((s) => s.data());
  }

  @override
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      return _db.collection(collectionPath).add(data);
    } on FirebaseException catch (e, st) {
      appLog.severe('addDocument failed: $collectionPath', e, st);
      rethrow;
    }
  }
}
