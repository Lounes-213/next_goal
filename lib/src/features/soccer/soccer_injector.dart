import '../../container_injector.dart';
import '../../core/api/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/date_time_provider.dart';
import 'data/datasources/soccer_data_source.dart';
import 'data/datasources/top_scorers_datasource.dart';
import 'data/datasources/search_datasource.dart';
import 'data/datasources/team_datasource.dart';
import 'data/datasources/player_datasource.dart';
import 'data/repositories/soccer_repository_impl.dart';
import 'domain/repositories/soccer_repository.dart';
import 'domain/use_cases/day_fixtures_usecase.dart';
import 'domain/use_cases/leagues_usecase.dart';
import 'domain/use_cases/fixtures_by_date_usecase.dart';
import 'domain/use_cases/live_fixtures_usecase.dart';
import 'domain/use_cases/standings_usecase.dart';
import 'presentation/cubit/leagues/leagues_cubit.dart';
import 'presentation/cubit/soccer/soccer_cubit.dart';

void initSoccer() {
  sl.registerLazySingleton<SoccerDataSource>(
    () => SoccerDataSourceImpl(
      apiClient: sl<ApiClient>(),
      dateTimeProvider: sl<DateTimeProvider>(),
    ),
  );
  sl.registerLazySingleton<SoccerRepository>(
    () => SoccerRepositoryImpl(
      networkInfo: sl<NetworkInfo>(),
      soccerDataSource: sl<SoccerDataSource>(),
    ),
  );
  sl.registerLazySingleton<CurrentRoundFixturesUseCase>(
    () => CurrentRoundFixturesUseCase(soccerRepository: sl<SoccerRepository>()),
  );
  sl.registerLazySingleton<LeaguesUseCase>(
    () => LeaguesUseCase(soccerRepository: sl<SoccerRepository>()),
  );

  sl.registerLazySingleton<TodayFixturesUseCase>(
    () => TodayFixturesUseCase(soccerRepository: sl<SoccerRepository>()),
  );
  sl.registerLazySingleton<FixturesByDateUseCase>(
    () => FixturesByDateUseCase(soccerRepository: sl<SoccerRepository>()),
  );
  sl.registerLazySingleton<TopScorersDataSource>(
    () => TopScorersDataSource(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<SearchDataSource>(
    () => SearchDataSource(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<TeamDataSource>(
    () => TeamDataSource(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<PlayerDataSource>(
    () => PlayerDataSource(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<StandingsUseCase>(
    () => StandingsUseCase(soccerRepository: sl<SoccerRepository>()),
  );
  sl.registerFactory<SoccerCubit>(
    () => SoccerCubit(
      currentRoundFixturesUseCase: sl<CurrentRoundFixturesUseCase>(),
      todayFixturesUseCase: sl<TodayFixturesUseCase>(),
      fixturesByDateUseCase: sl<FixturesByDateUseCase>(),
      standingUseCase: sl<StandingsUseCase>(),
    ),
  );
  sl.registerFactory<LeaguesCubit>(
    () => LeaguesCubit(leaguesUseCase: sl<LeaguesUseCase>()),
  );
}
