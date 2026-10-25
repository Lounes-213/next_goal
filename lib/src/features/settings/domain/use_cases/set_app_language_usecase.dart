import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/usecase/usecase.dart';
import '../app_language.dart';
import '../repositories/settings_repository.dart';

/// Use case to persist the user's selected application language.
class SetAppLanguageUseCase extends UseCase<void, AppLanguage> {
  final SettingsRepository settingsRepository;

  SetAppLanguageUseCase({required this.settingsRepository});

  @override
  Future<Either<Failure, void>> call(AppLanguage params) async {
    return await settingsRepository.setAppLanguage(params);
  }
}
