import 'package:equatable/equatable.dart';
import '../../../../../core/domain/entities/soccer_fixture.dart';
import '../../../domain/entities/standings.dart';

sealed class SoccerState extends Equatable {
  const SoccerState();

  @override
  List<Object?> get props => [];
}

/// Represents the soccer initial entity/model.
class SoccerInitial extends SoccerState {
  const SoccerInitial();
}

/// Represents the soccer current round fixtures loading entity/model.
class SoccerCurrentRoundFixturesLoading extends SoccerState {
  const SoccerCurrentRoundFixturesLoading();
}

/// Represents the soccer current round fixtures loaded entity/model.
class SoccerCurrentRoundFixturesLoaded extends SoccerState {
  final List<SoccerFixture> fixtures;

  const SoccerCurrentRoundFixturesLoaded(this.fixtures);

  @override
  List<Object?> get props => [fixtures];
}

/// Represents the soccer current round fixtures load failure entity/model.
class SoccerCurrentRoundFixturesLoadFailure extends SoccerState {
  final String message;
  final int? competitionId;

  const SoccerCurrentRoundFixturesLoadFailure(this.message, {this.competitionId});

  @override
  List<Object?> get props => [message, competitionId];
}

/// Represents the soccer today fixtures loading entity/model.
class SoccerTodayFixturesLoading extends SoccerState {
  final bool isTimerLoading;

  const SoccerTodayFixturesLoading({this.isTimerLoading = false});

  @override
  List<Object?> get props => [isTimerLoading];
}

/// Represents the soccer today fixtures loaded entity/model.
class SoccerTodayFixturesLoaded extends SoccerState {
  final List<SoccerFixture> todayFixtures;
  final List<SoccerFixture> liveFixtures;

  const SoccerTodayFixturesLoaded({
    required this.todayFixtures,
    required this.liveFixtures,
  });

  @override
  List<Object?> get props => [todayFixtures, liveFixtures];
}

/// Represents the soccer today fixtures load failure entity/model.
class SoccerTodayFixturesLoadFailure extends SoccerState {
  final String message;

  const SoccerTodayFixturesLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Represents the soccer standings loading entity/model.
class SoccerStandingsLoading extends SoccerState {
  const SoccerStandingsLoading();
}

/// Represents the soccer standings loaded entity/model.
class SoccerStandingsLoaded extends SoccerState {
  final Standings standings;

  const SoccerStandingsLoaded(this.standings);

  @override
  List<Object?> get props => [standings];
}

/// Represents the soccer standings load failure entity/model.
class SoccerStandingsLoadFailure extends SoccerState {
  final String message;

  const SoccerStandingsLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
