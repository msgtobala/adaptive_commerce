import 'package:adaptive_commerce/core/firebase/firebase_ai_config.dart';
import 'package:adaptive_commerce/services/firestore/firebase_firestore_service.dart';
import 'package:adaptive_commerce/services/firestore/firestore_service.dart';
import 'package:adaptive_commerce/services/storage/firebase_storage_service.dart';
import 'package:adaptive_commerce/services/storage/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raw [FirebaseFirestore] instance (use service provider in features).
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Raw [FirebaseStorage] instance.
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Application Firestore API.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirebaseFirestoreService(ref.watch(firebaseFirestoreProvider));
});

/// Application Storage API (includes [StorageService.storeAsset]).
final storageServiceProvider = Provider<StorageService>((ref) {
  return FirebaseStorageService(ref.watch(firebaseStorageProvider));
});

/// [FirebaseAI] (Google AI backend). For Vertex, call [FirebaseAI.vertexAI] in your own provider.
final firebaseAIProvider = Provider<FirebaseAI>((ref) {
  return FirebaseAI.googleAI();
});

/// Shared [GenerativeModel] — tune in [FirebaseAiConfig.generativeModel].
final generativeModelProvider = Provider<GenerativeModel>((ref) {
  return ref.watch(firebaseAIProvider).generativeModel(
        model: FirebaseAiConfig.generativeModel,
      );
});
