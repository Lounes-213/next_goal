import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/usecase/usecase.dart';
import '../app_language.dart';
import '../repositories/settings_repository.dart';

/// Use case to retrieve the persisted application language preference.
class GetAppLanguageUseCase extends UseCase<AppLanguage, NoParams> {
  final SettingsRepository settingsRepository;

  GetAppLanguageUseCase({required this.settingsRepository});

  @override
  Future<Either<Failure, AppLanguage>> call(NoParams params) async {
    return await settingsRepository.getAppLanguage();
  }
}
