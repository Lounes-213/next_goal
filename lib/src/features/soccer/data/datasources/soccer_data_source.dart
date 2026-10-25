import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';
import 'package:next_goal/src/core/models/country_model.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/domain/entities/league.dart';
import '../../../../core/models/league_model.dart';
import '../../../../core/models/soccer_fixture_model.dart';
import '../../../../core/utils/date_time_provider.dart';
import '../../domain/use_cases/standings_usecase.dart';
import '../models/standings_model.dart';

abstract class SoccerDataSource {
  Future<List<LeagueModel>> getLeagues();

  Future<List<SoccerFixtureModel>> getCurrentRoundFixtures({
    required int competitionId,
  });

  Future<List<SoccerFixtureModel>> getTodayFixtures();

  Future<List<SoccerFixtureModel>> getFixturesByDate(DateTime date);

  Future<List<SoccerFixtureModel>> getCompetitionFixtures(int competitionId);

  Future<StandingsModel> getStandings({required StandingsParams params});
}

class SoccerDataSourceImpl implements SoccerDataSource {
  final ApiClient apiClient;
  final DateTimeProvider dateTimeProvider;
  static final Set<int> _availableLeagueIds =
      AppConstants.availableLeagues.toSet();

  SoccerDataSourceImpl({
    required this.apiClient,
    required this.dateTimeProvider,
  });

  @override
  Future<List<SoccerFixtureModel>> getCurrentRoundFixtures({
    required int competitionId,
  }) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.currentRoundFixtures,
        queryParams: {'competitions': competitionId},
      );
      return _parseFixtures(response, allowedCompetitionIds: {competitionId});
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<LeagueModel>> getLeagues() async {
    try {
      final response = await apiClient.get(
        url: Endpoints.leagues,
        queryParams: {
          'competitions': AppConstants.availableLeagues.join(','),
          'withBestOdds': true,
        },
      );
      final List<dynamic> result = response.data['competitions'];
      final countries = List<CountryModel>.from(
        response.data['countries'].map((item) => CountryModel.fromJson(item)),
      );
      final leagues = List<LeagueModel>.from(
        result.map(
          (item) => LeagueModel.fromJson(
            item,
            country: countries.firstWhere(
              (country) => country.id == item['countryId'],
            ),
          ),
        ),
      );
      return leagues;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<SoccerFixtureModel>> getTodayFixtures() async {
    try {
      final today = DateFormat('dd/MM/yyyy').format(dateTimeProvider.now().toLocal());
      final response = await apiClient.get(
        url: Endpoints.todayFixtures,
        queryParams: {
          'sports': 1,
          'startDate': today,
          'endDate': today,
          'competitions': AppConstants.availableLeagues.join(','),
        },
      );

      return _parseFixtures(
        response,
        allowedCompetitionIds: _availableLeagueIds,
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<SoccerFixtureModel>> getFixturesByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(date.toLocal());
      final response = await apiClient.get(
        url: Endpoints.todayFixtures,
        queryParams: {
          'sports': 1,
          'startDate': formattedDate,
          'endDate': formattedDate,
          'competitions': AppConstants.availableLeagues.join(','),
        },
      );
      return _parseFixtures(
        response,
        allowedCompetitionIds: _availableLeagueIds,
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<StandingsModel> getStandings({required StandingsParams params}) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.standings,
        queryParams: params.toJson(),
      );
      final List<dynamic> result = response.data['standings'];
      final StandingsModel standings =
          result.isNotEmpty
              ? StandingsModel.fromJson(result.first)
              : const StandingsModel(standings: []);
      return standings;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<SoccerFixtureModel>> getCompetitionFixtures(int competitionId) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.fixtures,
        queryParams: {
          'competitions': competitionId,
          'withSeasonsFilter': 'false',
        },
      );
      final result = response.data['games'] as List<dynamic>? ?? const [];
      return result
          .whereType<Map>()
          .map((fixture) => Map<String, dynamic>.from(fixture))
          .map((fixture) => _buildFixtureModel(fixture))
          .toList();
    } catch (error) {
      return [];
    }
  }

  List<SoccerFixtureModel> _parseFixtures(
    Response response, {
    required Set<int> allowedCompetitionIds,
  }) {
    final result = response.data['games'] as List<dynamic>? ?? const [];
    return result
        .whereType<Map>()
        .map((fixture) => Map<String, dynamic>.from(fixture))
        .where((fixture) {
          final competitionId = (fixture['competitionId'] as num?)?.toInt();
          return competitionId != null &&
              allowedCompetitionIds.contains(competitionId);
        })
        .map(_buildFixtureModel)
        .toList();
  }

  SoccerFixtureModel _buildFixtureModel(Map<String, dynamic> fixture) {
    final competitionId = (fixture['competitionId'] as num).toInt();

    return SoccerFixtureModel.fromJson(
      fixture,
      fixtureLeague: League.light(
        id: competitionId,
        name: fixture['competitionDisplayName'],
      ),
    );
  }
}
