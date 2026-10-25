import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case to persist the user's selected application theme mode.
class SetThemeModeUseCase extends UseCase<void, ThemeMode> {
  final SettingsRepository settingsRepository;

  SetThemeModeUseCase({required this.settingsRepository});

  @override
  Future<Either<Failure, void>> call(ThemeMode params) async {
    return await settingsRepository.setThemeMode(params);
  }
}
