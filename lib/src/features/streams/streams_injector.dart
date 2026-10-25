import 'package:dio/dio.dart';

import '../../container_injector.dart';
import 'data/scrapers/highlights_scraper_service.dart';
import 'data/scrapers/stream_scraper_service.dart';

void initStreams() {
  sl.registerLazySingleton<StreamScraperService>(
    () => StreamScraperService(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<HighlightsScraperService>(
    () => HighlightsScraperService(dio: sl<Dio>()),
  );
}
