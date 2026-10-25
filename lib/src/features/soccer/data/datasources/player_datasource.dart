import 'package:next_goal/src/core/api/api_client.dart';
import 'package:next_goal/src/core/api/endpoints.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';

class PlayerInfo {
  final int id;
  final String name;
  final String? shortName;
  final int? imageId;
  final String? position;
  final int? number;
  final int? teamId;
  final String? teamName;
  final String? countryName;
  final int? countryId;
  final DateTime? dateOfBirth;
  final double? height;
  final double? weight;
  final String? preferredFoot;

  const PlayerInfo({
    required this.id,
    required this.name,
    this.shortName,
    this.imageId,
    this.position,
    this.number,
    this.teamId,
    this.teamName,
    this.countryName,
    this.countryId,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.preferredFoot,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    final competitor = json['competitor'] ?? json['team'];

    return PlayerInfo(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      shortName: json['shortName'],
      imageId: _toInt(json['imageId']) ?? _toInt(json['id']),
      position: json['position'],
      number: _toInt(json['jerseyNumber']),
      teamId: _toInt(competitor?['id']) ?? _toInt(json['competitorId']),
      teamName: competitor?['name'] ?? json['competitorName'],
      countryName: json['countryName'],
      countryId: _toInt(json['countryId']),
      dateOfBirth: _parseDateTime(json['dateOfBirth'] ?? json['birthDate']),
      height: _toDouble(json['height']),
      weight: _toDouble(json['weight']),
      preferredFoot: json['preferredFoot'],
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

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class PlayerStats {
  final int? goals;
  final int? assists;
  final int? appearances;
  final int? minutesPlayed;
  final int? yellowCards;
  final int? redCards;
  final double? rating;
  final int? shotsOnTarget;
  final int? passesCompleted;
  final double? passAccuracy;

  const PlayerStats({
    this.goals,
    this.assists,
    this.appearances,
    this.minutesPlayed,
    this.yellowCards,
    this.redCards,
    this.rating,
    this.shotsOnTarget,
    this.passesCompleted,
    this.passAccuracy,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      goals: _toInt(json['goals']),
      assists: _toInt(json['assists']),
      appearances: _toInt(json['appearances'] ?? json['gamesPlayed']),
      minutesPlayed: _toInt(json['minutesPlayed']),
      yellowCards: _toInt(json['yellowCards']),
      redCards: _toInt(json['redCards']),
      rating: _toDouble(json['rating']),
      shotsOnTarget: _toInt(json['shotsOnTarget']),
      passesCompleted: _toInt(json['passesCompleted']),
      passAccuracy: _toDouble(json['passAccuracy']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class PlayerTransfer {
  final int? fromTeamId;
  final String? fromTeamName;
  final int? toTeamId;
  final String? toTeamName;
  final DateTime? date;
  final String? type;

  const PlayerTransfer({
    this.fromTeamId,
    this.fromTeamName,
    this.toTeamId,
    this.toTeamName,
    this.date,
    this.type,
  });

  factory PlayerTransfer.fromJson(Map<String, dynamic> json) {
    final fromTeam = json['fromCompetitor'] ?? json['fromTeam'];
    final toTeam = json['toCompetitor'] ?? json['toTeam'];

    return PlayerTransfer(
      fromTeamId: _toInt(fromTeam?['id']) ?? _toInt(json['fromCompetitorId']),
      fromTeamName: fromTeam?['name'] ?? json['fromCompetitorName'],
      toTeamId: _toInt(toTeam?['id']) ?? _toInt(json['toCompetitorId']),
      toTeamName: toTeam?['name'] ?? json['toCompetitorName'],
      date: _parseDateTime(json['date'] ?? json['transferDate']),
      type: json['type'] ?? json['transferType'],
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

class PlayerDataSource {
  final ApiClient apiClient;

  PlayerDataSource({required this.apiClient});

  Future<PlayerInfo> getPlayerInfo(int playerId) async {
    try {
      final response = await apiClient.get(
        url: '${Endpoints.athlete}$playerId',
        queryParams: {
          'lang': AppConstants.apiEnglishLangId,
        },
      );

      return PlayerInfo.fromJson(response.data['athlete'] ?? response.data);
    } catch (error) {
      rethrow;
    }
  }

  Future<PlayerStats> getPlayerStats(int playerId) async {
    try {
      final response = await apiClient.get(
        url: '${Endpoints.athlete}$playerId/stats',
        queryParams: {
          'lang': AppConstants.apiEnglishLangId,
        },
      );

      return PlayerStats.fromJson(response.data['stats'] ?? response.data);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<PlayerTransfer>> getPlayerTransfers(int playerId) async {
    try {
      final response = await apiClient.get(
        url: '${Endpoints.athlete}$playerId/transfers',
        queryParams: {
          'lang': AppConstants.apiEnglishLangId,
        },
      );

      final List<dynamic> transfers = response.data['transfers'] ?? [];
      return transfers
          .whereType<Map>()
          .map((item) => PlayerTransfer.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      rethrow;
    }
  }
}
