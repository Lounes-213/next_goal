import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/error/error_handler.dart';
import '../repositories/soccer_repository.dart';

class FixturesByDateUseCase {
  final SoccerRepository soccerRepository;

  FixturesByDateUseCase({required this.soccerRepository});

  Future<Either<Failure, List<SoccerFixture>>> call(DateTime date) async {
    return await soccerRepository.getFixturesByDate(date);
  }
}
