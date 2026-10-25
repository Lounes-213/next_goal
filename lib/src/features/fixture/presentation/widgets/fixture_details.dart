import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:next_goal/src/core/extensions/fixture.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/widgets/custom_image.dart';

class FixtureDetails extends StatelessWidget {
  final SoccerFixture soccerFixture;

  const FixtureDetails({super.key, required this.soccerFixture});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final isLive = soccerFixture.status.isLive;
    final hasStarted = soccerFixture.gameTime != null && soccerFixture.gameTime! > 0;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 4,
        bottom: AppSpacing.s,
        left: AppSpacing.m,
        right: AppSpacing.m,
      ),
      decoration: BoxDecoration(gradient: soccerFixture.gradientColor(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LeagueRow(soccerFixture: soccerFixture),
          const SizedBox(height: AppSpacing.l),
          _TeamsScore(
            soccerFixture: soccerFixture,
            isLive: isLive,
            hasStarted: hasStarted,
          ),
          const SizedBox(height: AppSpacing.m),
          _StatusBadge(soccerFixture: soccerFixture),
          if (isLive && !soccerFixture.isHalftime) ...[
            const SizedBox(height: AppSpacing.s),
            _LiveMinuteIndicator(soccerFixture: soccerFixture),
          ],
          if (!isLive && !hasStarted) ...[
            const SizedBox(height: AppSpacing.s),
            _CountdownTimer(startTime: soccerFixture.startTime),
          ],
        ],
      ),
    );
  }
}

class _LeagueRow extends StatelessWidget {
  const _LeagueRow({required this.soccerFixture});
  final SoccerFixture soccerFixture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(width: 16, height: 16, imageUrl: soccerFixture.fixtureLeague.logo),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                soccerFixture.fixtureLeague.name,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamsScore extends StatelessWidget {
  final SoccerFixture soccerFixture;
  final bool isLive;
  final bool hasStarted;

  const _TeamsScore({required this.soccerFixture, required this.isLive, required this.hasStarted});

  @override
  Widget build(BuildContext context) {
    final homeTeam = soccerFixture.teams.home;
    final awayTeam = soccerFixture.teams.away;
    final scoreStyle = const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold);
    final teamNameStyle = const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500);

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TeamLogo(logo: homeTeam.logo, size: 48),
              const SizedBox(height: 6),
              FittedBox(child: Text(homeTeam.displayName, style: teamNameStyle, maxLines: 1)),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasStarted || isLive)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${homeTeam.score}', style: scoreStyle),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(':', style: scoreStyle.copyWith(color: Colors.white54)),
                  ),
                  Text('${awayTeam.score}', style: scoreStyle),
                ],
              )
            else
              Text('VS', style: scoreStyle.copyWith(fontSize: 28, color: Colors.white38)),
            const SizedBox(height: 2),
            Text(
              soccerFixture.roundNum != null
                  ? context.l10n.roundNumber(soccerFixture.roundNum.toString())
                  : '',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TeamLogo(logo: awayTeam.logo, size: 48),
              const SizedBox(height: 6),
              FittedBox(child: Text(awayTeam.displayName, style: teamNameStyle, maxLines: 1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final String logo;
  final double size;
  const _TeamLogo({required this.logo, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => SizedBox(width: size, height: size),
          errorWidget: (_, __, ___) => SizedBox(width: size, height: size),
        ),
      ),
    );
  }
}

class _LiveMinuteIndicator extends StatelessWidget {
  final SoccerFixture soccerFixture;
  const _LiveMinuteIndicator({required this.soccerFixture});

  @override
  Widget build(BuildContext context) {
    final progress = soccerFixture.progressPercentage;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          soccerFixture.displayMinute,
          style: const TextStyle(
            color: Color(0xFFFB7185),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFE11D48)),
          ),
        ),
      ],
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final DateTime? startTime;
  const _CountdownTimer({this.startTime});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    if (widget.startTime != null) {
      final diff = widget.startTime!.difference(DateTime.now());
      if (mounted) setState(() => _remaining = diff.isNegative ? null : diff);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A843).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4A843).withValues(alpha: 0.3)),
      ),
      child: Text(
        _formatRemaining(_remaining!),
        style: const TextStyle(color: Color(0xFFD4A843), fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }

  String _formatRemaining(Duration d) {
    if (d.inDays > 0) return '${d.inDays} يوم ${d.inHours.remainder(24)} ساعة ${d.inMinutes.remainder(60)} دقيقة';
    if (d.inHours > 0) return '${d.inHours} ساعة ${d.inMinutes.remainder(60)} دقيقة';
    return '${d.inMinutes} دقيقة';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.soccerFixture});
  final SoccerFixture soccerFixture;

  @override
  Widget build(BuildContext context) {
    final isLive = soccerFixture.status.isLive;
    final isHalftime = soccerFixture.isHalftime;
    final isEnded = soccerFixture.status.isEnded;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (isHalftime) {
      bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.3);
      textColor = const Color(0xFFFBBF24);
    } else if (isLive) {
      bgColor = const Color(0xFFE11D48).withValues(alpha: 0.15);
      borderColor = const Color(0xFFE11D48).withValues(alpha: 0.4);
      textColor = const Color(0xFFFB7185);
    } else if (isEnded) {
      bgColor = Colors.white.withValues(alpha: 0.08);
      borderColor = Colors.white.withValues(alpha: 0.15);
      textColor = Colors.white70;
    } else {
      bgColor = const Color(0xFFD4A843).withValues(alpha: 0.1);
      borderColor = const Color(0xFFD4A843).withValues(alpha: 0.2);
      textColor = const Color(0xFFD4A843);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive && !isHalftime) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (isHalftime) ...[
            const Icon(Icons.pause_circle_outline, color: Color(0xFFFBBF24), size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            soccerFixture.statusTextAr,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
