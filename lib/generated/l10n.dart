import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GOLDEN GOAL'**
  String get appName;

  /// No description provided for @noRouteFound.
  ///
  /// In en, this message translates to:
  /// **'No route found'**
  String get noRouteFound;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @fixtures.
  ///
  /// In en, this message translates to:
  /// **'Fixtures'**
  String get fixtures;

  /// No description provided for @standings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get standings;

  /// No description provided for @liveScore.
  ///
  /// In en, this message translates to:
  /// **'GOLDEN GOAL'**
  String get liveScore;

  /// No description provided for @versus.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get versus;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @lineups.
  ///
  /// In en, this message translates to:
  /// **'Lineups'**
  String get lineups;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @assist.
  ///
  /// In en, this message translates to:
  /// **'Assist'**
  String get assist;

  /// No description provided for @viewFixtures.
  ///
  /// In en, this message translates to:
  /// **'View Fixtures'**
  String get viewFixtures;

  /// No description provided for @viewStandings.
  ///
  /// In en, this message translates to:
  /// **'View Standings'**
  String get viewStandings;

  /// No description provided for @liveFixtures.
  ///
  /// In en, this message translates to:
  /// **'Live Fixtures'**
  String get liveFixtures;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @noStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics are not available yet'**
  String get noStats;

  /// No description provided for @noLineups.
  ///
  /// In en, this message translates to:
  /// **'Lineups are not available yet'**
  String get noLineups;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'Events are not available yet'**
  String get noEvents;

  /// No description provided for @noFixtures.
  ///
  /// In en, this message translates to:
  /// **'No matches scheduled today'**
  String get noFixtures;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app looks across every screen.'**
  String get appearanceDescription;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language or follow your device language.'**
  String get languageDescription;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @topStats.
  ///
  /// In en, this message translates to:
  /// **'Top Stats'**
  String get topStats;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamName;

  /// No description provided for @form.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get form;

  /// No description provided for @playedShort.
  ///
  /// In en, this message translates to:
  /// **'PL'**
  String get playedShort;

  /// No description provided for @wonShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wonShort;

  /// No description provided for @drawnShort.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get drawnShort;

  /// No description provided for @lostShort.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get lostShort;

  /// No description provided for @goalsForShort.
  ///
  /// In en, this message translates to:
  /// **'GF'**
  String get goalsForShort;

  /// No description provided for @goalsAgainstShort.
  ///
  /// In en, this message translates to:
  /// **'GA'**
  String get goalsAgainstShort;

  /// No description provided for @goalDifferenceShort.
  ///
  /// In en, this message translates to:
  /// **'GD'**
  String get goalDifferenceShort;

  /// No description provided for @pointsShort.
  ///
  /// In en, this message translates to:
  /// **'Pts'**
  String get pointsShort;

  /// No description provided for @tbd.
  ///
  /// In en, this message translates to:
  /// **'TBD'**
  String get tbd;

  /// No description provided for @liveFallback.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveFallback;

  /// No description provided for @aggregateScore.
  ///
  /// In en, this message translates to:
  /// **'Aggregate ({homeScore} - {awayScore})'**
  String aggregateScore(Object homeScore, Object awayScore);

  /// No description provided for @roundNumber.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundNumber(Object number);

  /// No description provided for @seasonNumber.
  ///
  /// In en, this message translates to:
  /// **'Season {number}'**
  String seasonNumber(Object number);

  /// No description provided for @errorClientClosedRequest.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading details. Please try again.'**
  String get errorClientClosedRequest;

  /// No description provided for @errorInternalServerError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errorInternalServerError;

  /// No description provided for @errorNetworkConnectError.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your internet and try again.'**
  String get errorNetworkConnectError;

  /// No description provided for @errorWebProxyRequired.
  ///
  /// In en, this message translates to:
  /// **'Flutter Web needs a server-side proxy for this API.'**
  String get errorWebProxyRequired;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error.'**
  String get errorUnexpected;

  /// No description provided for @errorLoadFixtures.
  ///
  /// In en, this message translates to:
  /// **'Unable to load fixtures right now.'**
  String get errorLoadFixtures;

  /// No description provided for @noStandingsYet.
  ///
  /// In en, this message translates to:
  /// **'No standings available yet.'**
  String get noStandingsYet;

  /// No description provided for @errorLoadStandings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load standings right now.'**
  String get errorLoadStandings;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allLeaguesTooltip.
  ///
  /// In en, this message translates to:
  /// **'All leagues'**
  String get allLeaguesTooltip;

  /// No description provided for @fullLineups.
  ///
  /// In en, this message translates to:
  /// **'Full Lineups'**
  String get fullLineups;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @watchLive.
  ///
  /// In en, this message translates to:
  /// **'Watch Live'**
  String get watchLive;

  /// No description provided for @searchChannels.
  ///
  /// In en, this message translates to:
  /// **'Search Channels'**
  String get searchChannels;

  /// No description provided for @noChannels.
  ///
  /// In en, this message translates to:
  /// **'No channels available'**
  String get noChannels;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
