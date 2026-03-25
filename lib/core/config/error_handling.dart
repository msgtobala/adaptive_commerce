import 'dart:developer' as developer;

import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Registers framework-wide error reporting and user-visible fallbacks.
///
/// Call once from [main], after [configureLogging], and before [runApp].
void configureGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    _reportError(
      'Flutter framework error',
      details.exception,
      details.stack,
    );
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _reportError('Uncaught async error', error, stack);
    return false;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    return const _ReleaseErrorFallback();
  };
}

void _reportError(String context, Object error, StackTrace? stack) {
  appLog.severe(context, error, stack);
  developer.log(
    context,
    error: error,
    stackTrace: stack,
    level: 1000,
    name: 'AdaptiveCommerce',
  );
}

/// Minimal [ErrorWidget] replacement so release users see on-brand copy instead of a gray box.
class _ReleaseErrorFallback extends StatelessWidget {
  const _ReleaseErrorFallback();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                AppStrings.errorGenericTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.alegreyaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.errorGenericBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.alegreyaSans(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.bodySecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
