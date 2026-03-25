import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Call once from [main] before other initialization.
///
/// - **Debug:** prints to the console via [debugPrint].
/// - **Release:** [Level.WARNING] and above also go to [developer.log] for device
///   logs / future Crashlytics wiring.
///
/// See https://pub.dev/packages/logging
void configureLogging({Level level = Level.ALL}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      final prefix =
          '${record.level.name} ${record.loggerName}: ${record.message}';
      debugPrint(prefix);
      if (record.error != null) {
        debugPrint('  error: ${record.error}');
      }
      if (record.stackTrace != null) {
        debugPrint('  stack: ${record.stackTrace}');
      }
      return;
    }

    if (record.level < Level.WARNING) return;

    developer.log(
      record.message,
      name: record.loggerName,
      level: record.level.value,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
}

/// Default logger for this app — create more with [Logger]('FeatureName') if needed.
final appLog = Logger('AdaptiveCommerce');
