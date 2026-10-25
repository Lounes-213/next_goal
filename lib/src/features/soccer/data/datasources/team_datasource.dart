import 'package:next_goal/src/core/api/api_client.dart';
import 'package:next_goal/src/core/api/endpoints.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';

class TeamInfo {
  final int id;
  final String name;
  final String? shortName;
  final int? imageId;
  final String? countryName;
  final int? countryId;
  final String? sport;
  final Map<String, dynamic>? meta;

  const TeamInfo({
    required this.id,
    required this.name,
    this.shortName,
    this.imageId,
    this.countryName,
    this.countryId,
    this.sport,
    this.meta,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      shortName: json['shortName'],
      imageId: _toInt(json['imageId']) ?? _toInt(json['id']),
      countryName: json['countryName'],
      countryId: _toInt(json['countryId']),
      sport: json['sport'],
      meta: json['meta'],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class TeamFixture {
  final int id;
  final int homeTeamId;
  final String homeTeamName;
  final int awayTeamId;
  final String awayTeamName;
  final String? homeScore;
  final String? awayScore;
  final DateTime? startTime;
  final String? status;
  final int? competitionId;
  final String? competitionName;

  const TeamFixture({
    required this.id,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.awayTeamId,
    required this.awayTeamName,
    this.homeScore,
    this.awayScore,
    this.startTime,
    this.status,
    this.competitionId,
    this.competitionName,
  });

  factory TeamFixture.fromJson(Map<String, dynamic> json) {
    final homeTeam = json['homeCompetitor'] ?? json['homeTeam'];
    final awayTeam = json['awayCompetitor'] ?? json['awayTeam'];

    return TeamFixture(
      id: _toInt(json['id']) ?? 0,
      homeTeamId: _toInt(homeTeam?['id']) ?? _toInt(json['homeCompetitorId']) ?? 0,
      homeTeamName: homeTeam?['name'] ?? json['homeCompetitorName'] ?? '',
      awayTeamId: _toInt(awayTeam?['id']) ?? _toInt(json['awayCompetitorId']) ?? 0,
      awayTeamName: awayTeam?['name'] ?? json['awayCompetitorName'] ?? '',
      homeScore: json['homeScore']?.toString(),
      awayScore: json['awayScore']?.toString(),
      startTime: _parseDateTime(json['startTime'] ?? json['start']),
      status: json['status'],
      competitionId: _toInt(json['competitionId']),
      competitionName: json['competitionDisplayName'] ?? json['competitionName'],
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class TeamPlayer {
  final int id;
  final String name;
  final String? shortName;
  final int? imageId;
  final int? number;
  final String? position;
  final String? countryName;

  const TeamPlayer({
    required this.id,
    required this.name,
    this.shortName,
    this.imageId,
    this.number,
    this.position,
    this.countryName,
  });

  factory TeamPlayer.fromJson(Map<String, dynamic> json) {
    return TeamPlayer(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      shortName: json['shortName'],
      imageId: _toInt(json['imageId']) ?? _toInt(json['id']),
      number: _toInt(json['jerseyNumber']),
      position: json['position'],
      countryName: json['countryName'],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class TeamDataSource {
  final ApiClient apiClient;

  TeamDataSource({required this.apiClient});

  Future<TeamInfo> getTeamInfo(int teamId) async {
    try {
      final response = await apiClient.get(
        url: '${Endpoints.competitor}$teamId',
        queryParams: {
          'lang': AppConstants.apiEnglishLangId,
        },
      );

      return TeamInfo.fromJson(response.data['competitor'] ?? response.data);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<TeamFixture>> getTeamFixtures(int teamId) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.teamFixtures,
        queryParams: {
          'competitor': teamId,
          'lang': AppConstants.apiEnglishLangId,
        },
      );

      final List<dynamic> games = response.data['games'] ?? [];
      return games
          .whereType<Map>()
          .map((item) => TeamFixture.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<TeamPlayer>> getTeamPlayers(int teamId) async {
    try {
      final response = await apiClient.get(
        url: '${Endpoints.competitor}$teamId/players',
        queryParams: {
          'lang': AppConstants.apiEnglishLangId,
        },
      );

      final List<dynamic> players = response.data['players'] ?? [];
      return players
          .whereType<Map>()
          .map((item) => TeamPlayer.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      rethrow;
    }
  }
}
