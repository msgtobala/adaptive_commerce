import 'package:adaptive_commerce/app.dart';
import 'package:adaptive_commerce/core/config/error_handling.dart';
import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'package:adaptive_commerce/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureLogging();
  configureGlobalErrorHandling();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    appLog.severe('Firebase.initializeApp failed', e, st);
    rethrow;
  }
  appLog.info('Firebase initialized');

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
