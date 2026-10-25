import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';
import 'package:next_goal/src/core/extensions/color.dart';
import 'package:next_goal/src/core/extensions/context_ext.dart';

import '../../domain/entities/fixture_details.dart';
import 'pitch_painter.dart';

class LineupsView extends StatefulWidget {
  final FixtureDetails? fixtureDetails;
  final Color? color;

  const LineupsView({super.key, required this.fixtureDetails, this.color});

  @override
  State<LineupsView> createState() => _LineupsViewState();
}

class _LineupsViewState extends State<LineupsView> {
  int _selectedTeam = 2;

  @override
  Widget build(BuildContext context) {
    if (widget.fixtureDetails == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('التشكيلة غير متوفرة بعد', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      );
    }

    final details = widget.fixtureDetails!;
    final homeTeam = details.fixture.teams.home;
    final awayTeam = details.fixture.teams.away;

    final hasLineups =
        (homeTeam.lineup?.formation ?? '').isNotEmpty ||
        (awayTeam.lineup?.formation ?? '').isNotEmpty;

    if (!hasLineups) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('التشكيلة غير متوفرة بعد', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      );
    }

    final homePlayers = details.homePlayersInfo;
    final awayPlayers = details.awayPlayersInfo;
    final homeStarters = homePlayers.where((p) => p.lineupMember.isStarting).toList();
    final awayStarters = awayPlayers.where((p) => p.lineupMember.isStarting).toList();
    final homeCoach = homePlayers.where((p) => p.lineupMember.isCoach).toList();
    final awayCoach = awayPlayers.where((p) => p.lineupMember.isCoach).toList();

    final homeColor = ('#${homeTeam.color ?? homeTeam.awayColor ?? "1E5631"}').toColor;
    final awayColor = ('#${awayTeam.color ?? awayTeam.awayColor ?? "FFFFFF"}').toColor;

    final isBoth = _selectedTeam == 2;

    final Color teamColor;
    final String formation;

    if (isBoth) {
      teamColor = const Color(0xFFD4A843);
      formation = '';
    } else if (_selectedTeam == 0) {
      teamColor = homeColor;
      formation = homeTeam.lineup?.formation ?? '';
    } else {
      teamColor = awayColor;
      formation = awayTeam.lineup?.formation ?? '';
    }

    final coaches = _selectedTeam == 0
        ? homeCoach
        : _selectedTeam == 1
            ? awayCoach
            : [...homeCoach, ...awayCoach];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TeamSelector(
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            selected: _selectedTeam,
            onSelect: (i) => setState(() => _selectedTeam = i),
          ),
          if (!isBoth && formation.isNotEmpty) ...[
            const SizedBox(height: 10),
            _FormationBadge(formation: formation, teamColor: teamColor),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: isBoth ? 420 : 340,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: isBoth
                    ? _BothPitchView(
                        homeStarters: homeStarters,
                        awayStarters: awayStarters,
                        homeColor: homeColor,
                        awayColor: awayColor,
                      )
                    : _PitchView(
                        starters: _selectedTeam == 0 ? homeStarters : awayStarters,
                        formation: formation,
                        teamColor: teamColor,
                      ),
              ),
            ),
          ),
          if (coaches.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...coaches.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _CoachTile(
                coach: c,
                teamColor: _selectedTeam == 0
                    ? homeColor
                    : _selectedTeam == 1
                        ? awayColor
                        : Colors.grey,
              ),
            )),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TeamSelector extends StatelessWidget {
  final dynamic homeTeam;
  final dynamic awayTeam;
  final int selected;
  final ValueChanged<int> onSelect;

  const _TeamSelector({
    required this.homeTeam,
    required this.awayTeam,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TeamTab(
            name: homeTeam.name,
            logo: homeTeam.logo,
            formation: homeTeam.lineup?.formation ?? '',
            isSelected: selected == 0,
            color: const Color(0xFF6366F1),
            onTap: () => onSelect(0),
          ),
          GestureDetector(
            onTap: () => onSelect(2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected == 2 ? const Color(0xFFF59E0B).withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: selected == 2 ? Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)) : null,
              ),
              child: Icon(
                Icons.groups,
                color: selected == 2 ? const Color(0xFFF59E0B) : Colors.grey[600],
                size: 18,
              ),
            ),
          ),
          _TeamTab(
            name: awayTeam.name,
            logo: awayTeam.logo,
            formation: awayTeam.lineup?.formation ?? '',
            isSelected: selected == 1,
            color: const Color(0xFFD4A843),
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}

class _TeamTab extends StatelessWidget {
  final String name;
  final String logo;
  final String formation;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TeamTab({
    required this.name,
    required this.logo,
    required this.formation,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: color.withValues(alpha: 0.4)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: logo,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(width: 20, height: 20, color: Colors.grey[800]),
                  errorWidget: (_, __, ___) => Container(width: 20, height: 20, color: Colors.grey[800]),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey[500],
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (formation.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  formation,
                  style: TextStyle(
                    color: isSelected ? color : Colors.grey[600],
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FormationBadge extends StatelessWidget {
  final String formation;
  final Color teamColor;
  const _FormationBadge({required this.formation, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: teamColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: teamColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_soccer, color: teamColor, size: 12),
          const SizedBox(width: 4),
          Text(formation, style: TextStyle(color: teamColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

List<List<FixturePlayerInfo>> _groupByLine(List<FixturePlayerInfo> starters, {bool reverseWithinLine = false}) {
  final sorted = List<FixturePlayerInfo>.from(starters);
  sorted.sort((a, b) {
    final aLine = a.lineupMember.yardInfo?.line ?? 0;
    final bLine = b.lineupMember.yardInfo?.line ?? 0;
    if (aLine != bLine) return aLine.compareTo(bLine);
    final aPos = a.lineupMember.yardInfo?.fieldPosition ?? 0;
    final bPos = b.lineupMember.yardInfo?.fieldPosition ?? 0;
    return reverseWithinLine ? bPos.compareTo(aPos) : aPos.compareTo(bPos);
  });

  final lines = <List<FixturePlayerInfo>>[];
  int currentLine = -1;
  for (final p in sorted) {
    final line = p.lineupMember.yardInfo?.line ?? 0;
    if (line != currentLine) {
      currentLine = line;
      lines.add([p]);
    } else {
      lines.last.add(p);
    }
  }
  return lines;
}

class _PitchView extends StatelessWidget {
  final List<FixturePlayerInfo> starters;
  final String formation;
  final Color teamColor;

  const _PitchView({required this.starters, required this.formation, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    if (starters.isEmpty) return const SizedBox.shrink();

    final hasYardInfo = starters.any((p) => p.lineupMember.yardInfo != null);

    if (hasYardInfo) {
      final lines = _groupByLine(starters);
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: CustomPaint(
          painter: PitchPainter(pitchColor: const Color(0xFF1E5631)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: lines.map((linePlayers) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: linePlayers.map((p) {
                    return Expanded(
                      child: _PlayerMarker(player: p, teamColor: teamColor),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    final plan = formation.split('-').map((e) => int.tryParse(e) ?? 0).toList();
    int playerIndex = 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: CustomPaint(
        painter: PitchPainter(pitchColor: const Color(0xFF1E5631)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (playerIndex < starters.length)
                _PlayerMarker(player: starters[playerIndex++], teamColor: teamColor),
              ...plan.where((n) => n > 0).map((count) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(count, (_) {
                    if (playerIndex >= starters.length) return const Expanded(child: SizedBox());
                    return Expanded(
                      child: _PlayerMarker(player: starters[playerIndex++], teamColor: teamColor),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _BothPitchView extends StatelessWidget {
  final List<FixturePlayerInfo> homeStarters;
  final List<FixturePlayerInfo> awayStarters;
  final Color homeColor;
  final Color awayColor;

  const _BothPitchView({
    required this.homeStarters,
    required this.awayStarters,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasHomeYardInfo = homeStarters.any((p) => p.lineupMember.yardInfo != null);
    final hasAwayYardInfo = awayStarters.any((p) => p.lineupMember.yardInfo != null);

    // Home (bottom half): reverse lines so GK is at bottom, forwards near center.
    final homeLinesRaw = hasHomeYardInfo
        ? _groupByLine(homeStarters, reverseWithinLine: false)
        : _fallbackGrouping(homeStarters, isReversed: false);
    final homeLines = homeLinesRaw.reversed.toList();

    // Away (top half): normal line order so GK is at top, forwards near center.
    final awayLines = hasAwayYardInfo
        ? _groupByLine(awayStarters, reverseWithinLine: false)
        : _fallbackGrouping(awayStarters, isReversed: false);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: CustomPaint(
        painter: PitchPainter(pitchColor: const Color(0xFF1E5631)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            children: [
              Expanded(
                child: _HalfPitchLines(lines: awayLines, teamColor: awayColor),
              ),
              Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _HalfPitchLines(lines: homeLines, teamColor: homeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<List<FixturePlayerInfo>> _fallbackGrouping(List<FixturePlayerInfo> starters, {required bool isReversed}) {
    final sorted = List<FixturePlayerInfo>.from(starters);
    if (isReversed) {
      sorted.sort((a, b) => b.lineupMember.jerseyNumber.compareTo(a.lineupMember.jerseyNumber));
    }
    final lines = <List<FixturePlayerInfo>>[];
    for (int i = 0; i < sorted.length; i += 3) {
      final end = (i + 3 > sorted.length) ? sorted.length : i + 3;
      lines.add(sorted.sublist(i, end));
    }
    if (isReversed) lines.sort((a, b) => b.length.compareTo(a.length));
    return lines;
  }
}

class _HalfPitchLines extends StatelessWidget {
  final List<List<FixturePlayerInfo>> lines;
  final Color teamColor;

  const _HalfPitchLines({required this.lines, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: lines.map((linePlayers) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: linePlayers.map((p) {
            return Expanded(
              child: _SmallPlayerMarker(player: p, teamColor: teamColor),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _SmallPlayerMarker extends StatelessWidget {
  final FixturePlayerInfo player;
  final Color teamColor;
  const _SmallPlayerMarker({required this.player, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    final int? imageId = player.player.imageId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: teamColor.withValues(alpha: 0.9),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageId != null
                      ? CachedNetworkImage(
                          imageUrl: AppConstants.athleteImage(imageId, size: '60'),
                          fit: BoxFit.cover,
                          memCacheWidth: 48,
                          memCacheHeight: 48,
                          placeholder: (_, __) => Center(
                            child: Text('${player.player.number}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 8)),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Text('${player.player.number}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 8)),
                          ),
                        )
                      : Center(
                          child: Text('${player.player.number}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${player.player.number}',
                      style: TextStyle(color: teamColor, fontSize: 5, fontWeight: FontWeight.bold, height: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            player.player.shortName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 6, fontWeight: FontWeight.w600, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _PlayerMarker extends StatelessWidget {
  final FixturePlayerInfo player;
  final Color teamColor;
  const _PlayerMarker({required this.player, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    final int? imageId = player.player.imageId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: teamColor.withValues(alpha: 0.9),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                clipBehavior: Clip.antiAlias,
                child: imageId != null
                    ? CachedNetworkImage(
                        imageUrl: AppConstants.athleteImage(imageId, size: '100'),
                        fit: BoxFit.cover,
                        memCacheWidth: 64,
                        memCacheHeight: 64,
                        placeholder: (_, __) => Center(
                          child: Text('${player.player.number}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Text('${player.player.number}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      )
                    : Center(
                        child: Text('${player.player.number}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
              ),
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${player.player.number}',
                    style: TextStyle(color: teamColor, fontSize: 7, fontWeight: FontWeight.bold, height: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            player.player.shortName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 7, fontWeight: FontWeight.w600, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _CoachTile extends StatelessWidget {
  final FixturePlayerInfo coach;
  final Color teamColor;
  const _CoachTile({required this.coach, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colorsExt.dividerSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, color: teamColor, size: 16),
          const SizedBox(width: 6),
          Text(
            coach.player.name.isNotEmpty ? coach.player.name : coach.player.shortName,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
