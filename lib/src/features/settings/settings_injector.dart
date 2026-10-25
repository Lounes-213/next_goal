import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../container_injector.dart';
import '../../core/api/locale_provider.dart';
import 'data/datasources/settings_local_data_source.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/services/settings_locale_provider.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/use_cases/get_app_language_usecase.dart';
import 'domain/use_cases/get_app_version_usecase.dart';
import 'domain/use_cases/get_theme_mode_usecase.dart';
import 'domain/use_cases/set_app_language_usecase.dart';
import 'domain/use_cases/set_theme_mode_usecase.dart';
import 'presentation/cubit/settings_cubit.dart';

void initSettings() {
  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(
      sharedPreferences: sl<SharedPreferences>(),
      packageInfo: sl<PackageInfo>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl<SettingsLocalDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GetThemeModeUseCase(settingsRepository: sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => SetThemeModeUseCase(settingsRepository: sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => GetAppLanguageUseCase(settingsRepository: sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => SetAppLanguageUseCase(settingsRepository: sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => GetAppVersionUseCase(settingsRepository: sl<SettingsRepository>()),
  );

  // Cubits
  sl.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(
      getThemeModeUseCase: sl<GetThemeModeUseCase>(),
      setThemeModeUseCase: sl<SetThemeModeUseCase>(),
      getAppLanguageUseCase: sl<GetAppLanguageUseCase>(),
      setAppLanguageUseCase: sl<SetAppLanguageUseCase>(),
      getAppVersionUseCase: sl<GetAppVersionUseCase>(),
    ),
  );

  // Providers
  sl.registerLazySingleton<LocaleProvider>(
    () => SettingsLocaleProviderImpl(settingsCubit: sl<SettingsCubit>()),
  );
}
