import 'package:next_goal/src/features/fixture/data/models/fixture_details_model.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/statistics_model.dart';

abstract class FixtureDataSource {
  Future<StatisticsModel> getStatistics(int fixtureId);

  Future<FixtureDetailsModel> getFixtureDetails(int fixtureId);
}

class FixtureDataSourceImpl implements FixtureDataSource {
  final ApiClient apiClient;

  FixtureDataSourceImpl({required this.apiClient});

  @override
  Future<FixtureDetailsModel> getFixtureDetails(int fixtureId) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.fixtureDetails,
        queryParams: {'gameId': fixtureId},
      );
      final result = response.data['game'];
      return FixtureDetailsModel.fromJson(result);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<StatisticsModel> getStatistics(int fixtureId) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.matchStatistics,
        queryParams: {'games': fixtureId},
      );
      final result = response.data;
      return StatisticsModel.fromJson(result);
    } catch (error) {
      rethrow;
    }
  }
}
