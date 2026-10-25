import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/app_language.dart';
import '../../domain/use_cases/get_app_language_usecase.dart';
import '../../domain/use_cases/get_app_version_usecase.dart';
import '../../domain/use_cases/get_theme_mode_usecase.dart';
import '../../domain/use_cases/set_app_language_usecase.dart';
import '../../domain/use_cases/set_theme_mode_usecase.dart';

part 'settings_state.dart';

/// Cubit managing the application settings state.
class SettingsCubit extends Cubit<SettingsState> {
  final GetThemeModeUseCase getThemeModeUseCase;
  final SetThemeModeUseCase setThemeModeUseCase;
  final GetAppLanguageUseCase getAppLanguageUseCase;
  final SetAppLanguageUseCase setAppLanguageUseCase;
  final GetAppVersionUseCase getAppVersionUseCase;

  SettingsCubit({
    required this.getThemeModeUseCase,
    required this.setThemeModeUseCase,
    required this.getAppLanguageUseCase,
    required this.setAppLanguageUseCase,
    required this.getAppVersionUseCase,
  }) : super(const SettingsState());

  /// Load settings.
  Future<void> loadSettings() async {
    final themeResult = await getThemeModeUseCase(NoParams());
    final languageResult = await getAppLanguageUseCase(NoParams());
    final versionResult = await getAppVersionUseCase(NoParams());

    ThemeMode themeMode = ThemeMode.system;
    AppLanguage language = AppLanguage.system;
    String appVersion = '';

    themeResult.fold((_) {}, (r) => themeMode = r);
    languageResult.fold((_) {}, (r) => language = r);
    versionResult.fold((_) {}, (r) => appVersion = r);

    emit(
      state.copyWith(
        themeMode: themeMode,
        appVersion: appVersion,
        language: language,
      ),
    );
  }

  /// Set theme mode.
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final result = await setThemeModeUseCase(themeMode);
    result.fold(
      (_) {},
      (_) => emit(state.copyWith(themeMode: themeMode)),
    );
  }

  /// Set language.
  Future<void> setLanguage(AppLanguage language) async {
    final result = await setAppLanguageUseCase(language);
    result.fold(
      (_) {},
      (_) => emit(state.copyWith(language: language)),
    );
  }
}
