import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/extensions/context_ext.dart';

class FixtureCard extends StatelessWidget {
  final SoccerFixture soccerFixture;
  final String? fixtureTime;

  const FixtureCard({
    super.key,
    required this.soccerFixture,
    this.fixtureTime,
  });

  @override
  Widget build(BuildContext context) {
    final homeTeam = soccerFixture.teams.home;
    final awayTeam = soccerFixture.teams.away;
    final isLive = soccerFixture.status.isLive;
    final isEnded = soccerFixture.status.isEnded;
    final goalsAvailable = homeTeam.score != -1 && awayTeam.score != -1;

    String centerText = '';
    String? subText;

    if (isLive) {
      centerText = goalsAvailable ? '${homeTeam.score} - ${awayTeam.score}' : '-- - --';
      subText = soccerFixture.displayTimeFull;
    } else if (isEnded && goalsAvailable) {
      centerText = '${homeTeam.score} - ${awayTeam.score}';
    } else {
      final local = soccerFixture.startTime?.toLocal();
      if (local != null) {
        final now = DateTime.now();
        final isToday = local.year == now.year && local.month == now.month && local.day == now.day;
        final timeStr = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
        if (isToday) {
          centerText = timeStr;
          subText = 'اليوم';
        } else {
          centerText = timeStr;
          subText = '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
        }
      } else {
        centerText = 'TBD';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLive ? const Color(0xFFE11D48).withValues(alpha: 0.3) : context.colorsExt.dividerSubtle.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Stack(
          children: [
            if (isLive)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185), Color(0xFFE11D48)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: homeTeam.logo,
                              fit: BoxFit.cover,
                              memCacheWidth: 72,
                              memCacheHeight: 72,
                              placeholder: (_, __) => _placeholderCircle(context),
                              errorWidget: (_, __, ___) => _placeholderCircle(context, homeTeam.displayName),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          homeTeam.displayName,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: isLive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE11D48),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              centerText,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          )
                        else if (isEnded && goalsAvailable)
                          Text(
                            centerText,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        else
                          Text(
                            centerText,
                            style: const TextStyle(
                              color: Color(0xFFD4A843),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (subText != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subText,
                            style: TextStyle(
                              color: isLive ? const Color(0xFFFB7185) : context.colorsExt.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: awayTeam.logo,
                              fit: BoxFit.cover,
                              memCacheWidth: 72,
                              memCacheHeight: 72,
                              placeholder: (_, __) => _placeholderCircle(context),
                              errorWidget: (_, __, ___) => _placeholderCircle(context, awayTeam.displayName),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          awayTeam.displayName,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: isLive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderCircle(BuildContext context, [String? letter]) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorsExt.dividerSubtle,
      ),
      child: Center(
        child: letter != null && letter.isNotEmpty
            ? Text(
                letter[0],
                style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
              )
            : const Icon(Icons.sports_soccer, color: Colors.white24, size: 16),
      ),
    );
  }
}
