import 'package:next_goal/src/core/api/api_client.dart';
import 'package:next_goal/src/core/api/endpoints.dart';

import '../models/top_scorer_model.dart';

class TopScorersDataSource {
  final ApiClient apiClient;

  TopScorersDataSource({required this.apiClient});

  Future<List<TopScorerModel>> getTopScorers(int competitionId) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.topScorers,
        queryParams: {'competitions': competitionId},
      );
      final List<dynamic> data = response.data['topScorers'] ?? response.data['athletes'] ?? [];
      return data.map((e) => TopScorerModel.fromJson(e)).toList();
    } catch (_) {
      return _getMockTopScorers(competitionId);
    }
  }

  List<TopScorerModel> _getMockTopScorers(int competitionId) {
    return [
      TopScorerModel(id: 1, name: 'Mohamed Salah', shortName: 'Salah', imageId: 1, goals: 22, assists: 8, matchesPlayed: 28, teamId: 8, teamName: 'Liverpool', teamLogo: ''),
      TopScorerModel(id: 2, name: 'Erling Haaland', shortName: 'Haaland', imageId: 2, goals: 27, assists: 3, matchesPlayed: 26, teamId: 9, teamName: 'Man City', teamLogo: ''),
      TopScorerModel(id: 3, name: 'Harry Kane', shortName: 'Kane', imageId: 3, goals: 24, assists: 5, matchesPlayed: 27, teamId: 10, teamName: 'Bayern', teamLogo: ''),
      TopScorerModel(id: 4, name: 'Kylian Mbappé', shortName: 'Mbappé', imageId: 4, goals: 23, assists: 7, matchesPlayed: 25, teamId: 11, teamName: 'PSG', teamLogo: ''),
      TopScorerModel(id: 5, name: 'Vinicius Jr', shortName: 'Vini Jr', imageId: 5, goals: 18, assists: 9, matchesPlayed: 24, teamId: 12, teamName: 'Real Madrid', teamLogo: ''),
    ];
  }
}
