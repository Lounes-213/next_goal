import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:next_goal/src/core/extensions/context_ext.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';

class LiveFixtureCard extends StatelessWidget {
  final SoccerFixture soccerFixture;
  final double? width;

  const LiveFixtureCard({super.key, required this.soccerFixture, this.width});

  @override
  Widget build(BuildContext context) {
    final home = soccerFixture.teams.home;
    final away = soccerFixture.teams.away;
    final isLive = soccerFixture.status.isLive;
    final goalsAvailable = home.score != -1 && away.score != -1;

    return Container(
      width: width ?? 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLive
              ? [const Color(0xFF4A1942), const Color(0xFF1A1033)]
              : [context.colorsExt.surfaceElevated, context.colorsExt.surfaceElevated],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isLive ? const Color(0xFFE11D48) : context.colorsExt.dividerSubtle).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: soccerFixture.fixtureLeague.logo,
                    fit: BoxFit.cover,
                    memCacheWidth: 32,
                    memCacheHeight: 32,
                    placeholder: (_, __) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 14),
                    errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 14),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  soccerFixture.fixtureLeague.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamLogo(context, home.logo),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    soccerFixture.displayMinute.isNotEmpty ? soccerFixture.displayMinute : '${soccerFixture.gameTime ?? 0}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              _buildTeamLogo(context, away.logo),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTeamScore(context, home.displayName, goalsAvailable ? '${home.score}' : '', true),
              const SizedBox(height: 4),
              _buildTeamScore(context, away.displayName, goalsAvailable ? '${away.score}' : '', false),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isLive ? const Color(0xFFE11D48) : context.colorsExt.dividerSubtle).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              soccerFixture.statusText,
              style: TextStyle(
                color: isLive ? const Color(0xFFFB7185) : const Color(0xFFD4A843),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(BuildContext context, String logo) {
    return SizedBox(
      width: 36,
      height: 36,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: logo,
          fit: BoxFit.cover,
          memCacheWidth: 72,
          memCacheHeight: 72,
          placeholder: (_, __) => Container(color: context.colorsExt.dividerSubtle),
          errorWidget: (_, __, ___) => Container(
            color: context.colorsExt.dividerSubtle,
            child: const Center(child: Icon(Icons.person, color: Colors.white24, size: 18)),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScore(BuildContext context, String name, String score, bool isHome) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isHome) ...[
            Text(
              score,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: isHome ? TextAlign.end : TextAlign.start,
            ),
          ),
          if (isHome) ...[
            const SizedBox(width: 6),
            Text(
              score,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}
