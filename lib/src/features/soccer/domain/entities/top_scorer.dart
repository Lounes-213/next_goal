import 'package:equatable/equatable.dart';

class TopScorer extends Equatable {
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

  const TopScorer({
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

  @override
  List<Object?> get props => [id, name, goals, teamId];
}
