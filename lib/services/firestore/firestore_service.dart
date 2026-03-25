import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstraction over document database — swap in a fake for tests.
abstract class FirestoreService {
  DocumentReference<Map<String, dynamic>> doc(String path);

  CollectionReference<Map<String, dynamic>> collection(String path);

  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  });

  Future<Map<String, dynamic>?> getDocument(String path);

  Future<void> updateDocument(String path, Map<String, dynamic> data);

  Future<void> deleteDocument(String path);

  Stream<Map<String, dynamic>?> watchDocument(String path);

  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  );
}
