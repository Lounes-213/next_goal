import '../entities/top_scorer.dart';

abstract class TopScorersRepository {
  Future<List<TopScorer>> getTopScorers(int competitionId);
}
