import 'package:flutter/material.dart';
import 'package:next_goal/src/core/domain/entities/soccer_fixture.dart';

extension FixtureExtension on SoccerFixture {
  LinearGradient gradientColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (status.isLive) {
      if (brightness == Brightness.dark) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        );
      }
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8ECF0), Color(0xFFD5DCE4), Color(0xFFC0CAD4)],
      );
    }
    if (status.isEnded) {
      if (brightness == Brightness.dark) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF1E1E30), Color(0xFF2D1B3D)],
        );
      }
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8ECF0), Color(0xFFE0D8E8), Color(0xFFD5CEDD)],
      );
    }
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF162447)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE0E8F0), Color(0xFFD0D8E0), Color(0xFFC5D0DC)],
    );
  }

  bool get isThereWinner {
    return teams.away.score != teams.home.score;
  }

  String get statusTextAr {
    if (isHalftime) return 'استراحة بين الشوطين';
    if (isFullTime) return 'انتهت';
    if (status.isLive) return 'مباشر';
    if (status.isScheduled) return 'لم تبدأ';
    return statusText;
  }
}
