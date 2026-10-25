import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/api/dio_helper.dart';
import 'core/api/interceptors.dart';
import 'core/api/locale_provider.dart';
import 'core/network/network_info.dart';
import 'core/utils/date_time_provider.dart';
import 'features/fixture/fixture_injector.dart';
import 'features/settings/settings_injector.dart';
import 'features/soccer/soccer_injector.dart';
import 'features/streams/streams_injector.dart';

final sl = GetIt.instance;

Future<void> initApp() async {
  await initCore();
  initSettings();
  initSoccer();
  initFixture();
  initStreams();
}

Future<void> initCore() async {
  // Async third-party registration
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  final packageInfo = await PackageInfo.fromPlatform();
  sl.registerLazySingleton<PackageInfo>(() => packageInfo);

  // Core providers
  sl.registerLazySingleton<DateTimeProvider>(() => const DateTimeProviderImpl());

  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<AppInterceptors>(() => AppInterceptors());

  sl.registerLazySingleton<LogInterceptor>(() {
    return LogInterceptor(
      error: kDebugMode,
      request: kDebugMode,
      requestBody: kDebugMode,
      requestHeader: kDebugMode,
      responseBody: kDebugMode,
      responseHeader: kDebugMode,
    );
  });

  sl.registerLazySingleton<ApiClient>(
    () => DioHelper(
      dio: sl<Dio>(),
      localeProvider: sl<LocaleProvider>(),
      dateTimeProvider: sl<DateTimeProvider>(),
    ),
  );

  if (!kIsWeb) {
    sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker(),
    );
  }
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectionChecker: kIsWeb ? null : sl<InternetConnectionChecker>(),
    ),
  );
}
