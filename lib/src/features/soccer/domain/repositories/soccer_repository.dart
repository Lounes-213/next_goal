import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/league.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/error/error_handler.dart';
import '../entities/standings.dart';
import '../use_cases/standings_usecase.dart';

/// Represents the soccer repository entity/model.
abstract class SoccerRepository {
  /// Get leagues.
  Future<Either<Failure, List<League>>> getLeagues();

  /// Get current round fixtures.
  Future<Either<Failure, List<SoccerFixture>>> getCurrentRoundFixtures({
    required int competitionId,
  });

  /// Get today fixtures.
  Future<Either<Failure, List<SoccerFixture>>> getTodayFixtures();

  /// Get fixtures by date.
  Future<Either<Failure, List<SoccerFixture>>> getFixturesByDate(DateTime date);

  /// Get all fixtures for a specific competition.
  Future<Either<Failure, List<SoccerFixture>>> getCompetitionFixtures(int competitionId);

  /// Get standings.
  Future<Either<Failure, Standings>> getStandings({
    required StandingsParams params,
  });
}
