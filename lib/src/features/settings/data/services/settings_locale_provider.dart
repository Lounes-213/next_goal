import 'dart:ui' as ui;

import '../../../../core/api/locale_provider.dart';
import '../../presentation/cubit/settings_cubit.dart';

/// Implementation of [LocaleProvider] that bridges settings state to core api.
class SettingsLocaleProviderImpl implements LocaleProvider {
  final SettingsCubit settingsCubit;

  SettingsLocaleProviderImpl({required this.settingsCubit});

  @override
  ui.Locale getLocale() {
    return settingsCubit.state.language.resolveLocale(
      ui.PlatformDispatcher.instance.locale,
    );
  }
}
