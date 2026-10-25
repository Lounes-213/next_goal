import '../../domain/entities/top_scorer.dart';

class TopScorerModel {
  final int id;
  final String name;
  final String? shortName;
  final int? imageId;
  final int goals;
  final int? assists;
  final int? matchesPlayed;
  final int? teamId;
  final String? teamName;
  final String? teamLogo;

  TopScorerModel({
    required this.id,
    required this.name,
    this.shortName,
    this.imageId,
    required this.goals,
    this.assists,
    this.matchesPlayed,
    this.teamId,
    this.teamName,
    this.teamLogo,
  });

  factory TopScorerModel.fromJson(Map<String, dynamic> json) {
    return TopScorerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? json['displayName'] as String? ?? '',
      shortName: json['shortName'] as String? ?? (json['name'] as String?)?.split(' ').lastOrNull,
      imageId: json['imageId'] as int?,
      goals: json['goals'] as int? ?? json['totalGoals'] as int? ?? 0,
      assists: json['assists'] as int? ?? json['totalAssists'] as int?,
      matchesPlayed: json['matchesPlayed'] as int? ?? json['games'] as int?,
      teamId: json['teamId'] as int? ?? json['competitorId'] as int?,
      teamName: json['teamName'] as String? ?? json['competitorName'] as String?,
      teamLogo: json['teamLogo'] as String?,
    );
  }

  TopScorer toDomain() => TopScorer(
    id: id,
    name: name,
    shortName: shortName,
    imageId: imageId,
    goals: goals,
    assists: assists,
    matchesPlayed: matchesPlayed,
    teamId: teamId,
    teamName: teamName,
    teamLogo: teamLogo,
  );
}
