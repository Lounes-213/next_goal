// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GOLDEN GOAL';

  @override
  String get noRouteFound => 'No route found';

  @override
  String get home => 'Home';

  @override
  String get fixtures => 'Fixtures';

  @override
  String get standings => 'Standings';

  @override
  String get liveScore => 'GOLDEN GOAL';

  @override
  String get versus => 'vs';

  @override
  String get statistics => 'Statistics';

  @override
  String get lineups => 'Lineups';

  @override
  String get events => 'Events';

  @override
  String get assist => 'Assist';

  @override
  String get viewFixtures => 'View Fixtures';

  @override
  String get viewStandings => 'View Standings';

  @override
  String get liveFixtures => 'Live Fixtures';

  @override
  String get viewAll => 'View All';

  @override
  String get reload => 'Reload';

  @override
  String get noStats => 'Statistics are not available yet';

  @override
  String get noLineups => 'Lineups are not available yet';

  @override
  String get noEvents => 'Events are not available yet';

  @override
  String get noFixtures => 'No matches scheduled today';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceDescription =>
      'Choose how the app looks across every screen.';

  @override
  String get appVersion => 'App Version';

  @override
  String get systemDefault => 'System default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageDescription =>
      'Choose the app language or follow your device language.';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get topStats => 'Top Stats';

  @override
  String get teamName => 'Team';

  @override
  String get form => 'Form';

  @override
  String get playedShort => 'PL';

  @override
  String get wonShort => 'W';

  @override
  String get drawnShort => 'D';

  @override
  String get lostShort => 'L';

  @override
  String get goalsForShort => 'GF';

  @override
  String get goalsAgainstShort => 'GA';

  @override
  String get goalDifferenceShort => 'GD';

  @override
  String get pointsShort => 'Pts';

  @override
  String get tbd => 'TBD';

  @override
  String get liveFallback => 'LIVE';

  @override
  String aggregateScore(Object homeScore, Object awayScore) {
    return 'Aggregate ($homeScore - $awayScore)';
  }

  @override
  String roundNumber(Object number) {
    return 'Round $number';
  }

  @override
  String seasonNumber(Object number) {
    return 'Season $number';
  }

  @override
  String get errorClientClosedRequest =>
      'Something went wrong while loading details. Please try again.';

  @override
  String get errorInternalServerError =>
      'Something went wrong. Please try again later.';

  @override
  String get errorNetworkConnectError =>
      'Connection timed out. Please check your internet and try again.';

  @override
  String get errorWebProxyRequired =>
      'Flutter Web needs a server-side proxy for this API.';

  @override
  String get errorUnexpected => 'Unexpected error.';

  @override
  String get errorLoadFixtures => 'Unable to load fixtures right now.';

  @override
  String get noStandingsYet => 'No standings available yet.';

  @override
  String get errorLoadStandings => 'Unable to load standings right now.';

  @override
  String get all => 'All';

  @override
  String get allLeaguesTooltip => 'All leagues';

  @override
  String get fullLineups => 'Full Lineups';

  @override
  String get channels => 'Channels';

  @override
  String get watchLive => 'Watch Live';

  @override
  String get searchChannels => 'Search Channels';

  @override
  String get noChannels => 'No channels available';
}
