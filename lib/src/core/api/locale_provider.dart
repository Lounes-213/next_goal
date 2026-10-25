import 'dart:ui' as ui;

/// Interface for providing the current application locale to the core api/network layer.
abstract class LocaleProvider {
  ui.Locale getLocale();
}
