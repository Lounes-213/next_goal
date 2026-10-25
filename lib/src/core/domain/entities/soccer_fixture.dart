import 'package:equatable/equatable.dart';
import 'package:next_goal/src/core/domain/entities/league.dart';

import '../enums/soccer_fixture_status.dart';
import 'teams.dart';

/// Represents the soccer fixture entity/model.
class SoccerFixture extends Equatable {
  final int id;
  final Teams teams;
  final String statusText;
  final int gameTimeAndStatusDisplayType;
  final League fixtureLeague;
  final DateTime? startTime;
  final int? gameTime;
  final int? addedTime;
  final String gameTimeDisplay;
  final int? roundNum;
  final int? stageNum;
  final int? seasonNum;

  const SoccerFixture({
    required this.id,
    required this.teams,
    required this.statusText,
    required this.gameTimeAndStatusDisplayType,
    required this.fixtureLeague,
    this.startTime,
    this.gameTime,
    this.addedTime,
    this.gameTimeDisplay = '',
    this.roundNum,
    this.stageNum,
    this.seasonNum,
  });

  @override
  List<Object?> get props => [
    id,
    fixtureLeague,
    teams,
    statusText,
    startTime,
    gameTime,
    roundNum,
    stageNum,
    seasonNum,
  ];

  SoccerFixtureStatus get status => switch (gameTimeAndStatusDisplayType) {
    0 => SoccerFixtureStatus.scheduled,
    1 when gameTime != null && gameTime! < 90 => SoccerFixtureStatus.live,
    1 => SoccerFixtureStatus.ended,
    2 => SoccerFixtureStatus.live,
    _ => SoccerFixtureStatus.scheduled,
  };

  bool get isHalftime {
    final st = statusText.toLowerCase();
    return st.contains('half') && st.contains('break') ||
        st == 'ht' ||
        st.contains('halftime') ||
        st.contains('استراحة');
  }

  bool get isFullTime {
    final st = statusText.toLowerCase();
    return st == 'ft' || st.contains('full time') || st.contains('انتهت') || st.contains('ended');
  }

  String get displayMinute {
    if (gameTime == null) return '';
    final gt = gameTime!;

    if (isHalftime) return 'HT';
    if (isFullTime) return 'FT';

    final st = statusText.toLowerCase();
    final isSecondHalf = st.contains('2nd') || st.contains('second') || st.contains('الشوط الثاني') || gt > 45;

    if (isSecondHalf) {
      final secondHalfMinute = gt - 45;
      if (secondHalfMinute <= 0) return "45'";
      if (addedTime != null && addedTime! > 0 && secondHalfMinute >= 45) {
        final extra = secondHalfMinute - 45;
        return extra > 0 ? "90+${extra}'" : "90'";
      }
      return "${45 + secondHalfMinute}'";
    }

    if (gt <= 45) {
      return "$gt'";
    }

    final extra = gt - 45;
    return extra > 0 ? "45+${extra}'" : "45'";
  }

  double get progressPercentage {
    if (gameTime == null) return 0;
    final gt = gameTime!;
    if (isHalftime) return 0.5;
    if (isFullTime || gt >= 90) return 1.0;
    return (gt / 90.0).clamp(0.0, 1.0);
  }

  String get displayTimeFull {
    if (gameTime == null) return '';
    if (isHalftime) return 'استراحة';
    if (isFullTime) return 'FT';
    return displayMinute;
  }
}
