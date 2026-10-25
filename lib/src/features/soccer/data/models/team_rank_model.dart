import '../../../../core/domain/mappers/mappers.dart';
import '../../../../core/models/teams_model.dart';
import '../../domain/entities/team_rank.dart';
import '../../domain/mappers/mappers.dart';

class TeamRankModel extends TeamRank {
  const TeamRankModel({
    required super.rank,
    required super.team,
    required super.points,
    required super.goalsDiff,
    required super.form,
    required super.stats,
    super.groupNum,
    super.destinationNum,
  });

  factory TeamRankModel.fromJson(Map<String, dynamic> json) {
    final scored = (json['for'] as num?)?.toInt() ?? 0;
    final received = (json['against'] as num?)?.toInt() ?? 0;
    return TeamRankModel(
      rank: json['position'],
      team: TeamModel.fromJson(json['competitor']).toDomain(),
      points: (json['points'] as num).toInt(),
      goalsDiff: scored - received,
      form: List<int>.from(
        (json['recentForm'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0) ?? [],
      ),
      stats:
          TeamRankStatsModel(
            played: json['gamePlayed'],
            win: json['gamesWon'],
            draw: json['gamesEven'],
            lose: json['gamesLost'],
            scored: scored,
            received: received,
          ).toDomain(),
      groupNum: (json['groupNum'] as num?)?.toInt(),
      destinationNum: (json['destinationNum'] as num?)?.toInt(),
    );
  }
}

class TeamRankStatsModel extends TeamRankStats {
  const TeamRankStatsModel({
    required super.played,
    required super.win,
    required super.draw,
    required super.lose,
    required super.scored,
    required super.received,
  });

  factory TeamRankStatsModel.fromJson(Map<String, dynamic> json) =>
      TeamRankStatsModel(
        played: json['played'],
        win: json['win'],
        draw: json['draw'],
        lose: json['lose'],
        scored: json['goals']['for'],
        received: json['goals']['against'],
      );
}
