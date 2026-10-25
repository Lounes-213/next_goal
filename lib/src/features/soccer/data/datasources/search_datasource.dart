import 'package:next_goal/src/core/api/api_client.dart';
import 'package:next_goal/src/core/api/endpoints.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';

class SearchResultItem {
  final String type;
  final int id;
  final String name;
  final String? shortName;
  final String? subtitle;
  final int? imageId;
  final String? countryName;
  final String? teamName;
  final int? teamId;

  const SearchResultItem({
    required this.type,
    required this.id,
    required this.name,
    this.shortName,
    this.subtitle,
    this.imageId,
    this.countryName,
    this.teamName,
    this.teamId,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    final type = _mapResultType(json['type'] ?? json['resultType'] ?? '');

    return SearchResultItem(
      type: type,
      id: _toInt(json['id']) ?? 0,
      name: json['name'] ?? json['fullName'] ?? '',
      shortName: json['shortName'],
      subtitle: _buildSubtitle(json, type),
      imageId: _toInt(json['imageId']) ?? _toInt(json['id']),
      countryName: json['countryName'],
      teamName: json['teamName'] ?? json['competitorName'],
      teamId: _toInt(json['competitorId']) ?? _toInt(json['teamId']),
    );
  }

  static String _mapResultType(String raw) {
    switch (raw.toLowerCase()) {
      case 'athlete':
      case 'player':
        return 'player';
      case 'competitor':
      case 'team':
        return 'team';
      case 'competition':
      case 'league':
        return 'competition';
      default:
        return raw.toLowerCase();
    }
  }

  static String? _buildSubtitle(Map<String, dynamic> json, String type) {
    switch (type) {
      case 'player':
        return json['teamName'] ?? json['competitorName'];
      case 'team':
        return json['countryName'] ?? json['competitionName'];
      case 'competition':
        return json['countryName'];
      default:
        return null;
    }
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class SearchDataSource {
  final ApiClient apiClient;

  SearchDataSource({required this.apiClient});

  Future<List<SearchResultItem>> search(String query) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.search,
        queryParams: {
          'q': query,
          'limit': 20,
          'lang': AppConstants.apiEnglishLangId,
        },
      );

      final List<dynamic> results = response.data['results'] ?? [];
      return results
          .whereType<Map>()
          .map((item) => SearchResultItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<SearchResultItem>> searchPlayers(String query) async {
    final results = await search(query);
    return results.where((r) => r.type == 'player').toList();
  }

  Future<List<SearchResultItem>> searchTeams(String query) async {
    final results = await search(query);
    return results.where((r) => r.type == 'team').toList();
  }

  Future<List<SearchResultItem>> searchCompetitions(String query) async {
    final results = await search(query);
    return results.where((r) => r.type == 'competition').toList();
  }
}
