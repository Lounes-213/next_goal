import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/error_handler.dart';
import '../app_language.dart';

/// Contract for settings persistence operations.
abstract class SettingsRepository {
  /// Returns the persisted [ThemeMode], defaulting to [ThemeMode.system].
  Future<Either<Failure, ThemeMode>> getThemeMode();

  /// Persists the user's [ThemeMode] selection.
  Future<Either<Failure, void>> setThemeMode(ThemeMode themeMode);

  /// Returns the persisted [AppLanguage], defaulting to [AppLanguage.system].
  Future<Either<Failure, AppLanguage>> getAppLanguage();

  /// Persists the user's [AppLanguage] selection.
  Future<Either<Failure, void>> setAppLanguage(AppLanguage language);

  /// Returns the current app version string (e.g., `"1.0.0+1"`).
  Future<Either<Failure, String>> getAppVersion();
}
