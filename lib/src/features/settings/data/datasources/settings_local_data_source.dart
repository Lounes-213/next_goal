import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/app_language.dart';

abstract class SettingsLocalDataSource {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode themeMode);
  Future<AppLanguage> getAppLanguage();
  Future<void> setAppLanguage(AppLanguage language);
  Future<String> getAppVersion();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  final PackageInfo packageInfo;

  static const _themeModeKey = 'theme_mode';
  static const _appLanguageKey = 'app_language';

  SettingsLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.packageInfo,
  });

  @override
  Future<ThemeMode> getThemeMode() async {
    final String? storedThemeMode = sharedPreferences.getString(_themeModeKey);

    return switch (storedThemeMode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final String value = switch (themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await sharedPreferences.setString(_themeModeKey, value);
  }

  @override
  Future<AppLanguage> getAppLanguage() async {
    return AppLanguage.fromStorage(sharedPreferences.getString(_appLanguageKey));
  }

  @override
  Future<void> setAppLanguage(AppLanguage language) async {
    await sharedPreferences.setString(_appLanguageKey, language.storageValue);
  }

  @override
  Future<String> getAppVersion() async {
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }
}
