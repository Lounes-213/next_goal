import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:next_goal/src/core/extensions/context_ext.dart';

import '../../../../core/domain/entities/league.dart';

class FixtureLeagueSection extends StatelessWidget {
  final League league;
  final int? roundNum;
  final bool showLogo;

  const FixtureLeagueSection({
    super.key,
    required this.league,
    this.roundNum,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.more_horiz, color: Colors.grey[500], size: 20),
          const Spacer(),
          if (roundNum != null) ...[
            Text(
              ' - الجولة $roundNum',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
          const SizedBox(width: 8),
          Text(
            league.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (showLogo) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: league.logo,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 20),
                  errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
