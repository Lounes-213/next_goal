import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/safe_local_call.dart';
import '../../domain/app_language.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() {
    return safeLocalCall(() => localDataSource.getThemeMode());
  }

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeMode themeMode) {
    return safeLocalCall(() => localDataSource.setThemeMode(themeMode));
  }

  @override
  Future<Either<Failure, AppLanguage>> getAppLanguage() {
    return safeLocalCall(() => localDataSource.getAppLanguage());
  }

  @override
  Future<Either<Failure, void>> setAppLanguage(AppLanguage language) {
    return safeLocalCall(() => localDataSource.setAppLanguage(language));
  }

  @override
  Future<Either<Failure, String>> getAppVersion() {
    return safeLocalCall(() => localDataSource.getAppVersion());
  }
}
