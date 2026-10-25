import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case to retrieve the application's version and build number.
class GetAppVersionUseCase extends UseCase<String, NoParams> {
  final SettingsRepository settingsRepository;

  GetAppVersionUseCase({required this.settingsRepository});

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await settingsRepository.getAppVersion();
  }
}
