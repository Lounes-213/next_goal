import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case to retrieve the persisted application theme mode.
class GetThemeModeUseCase extends UseCase<ThemeMode, NoParams> {
  final SettingsRepository settingsRepository;

  GetThemeModeUseCase({required this.settingsRepository});

  @override
  Future<Either<Failure, ThemeMode>> call(NoParams params) async {
    return await settingsRepository.getThemeMode();
  }
}
