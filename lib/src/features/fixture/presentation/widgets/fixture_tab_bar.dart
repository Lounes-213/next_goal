import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next_goal/src/core/extensions/context_ext.dart';
import 'package:next_goal/src/core/extensions/date_time.dart';
import 'package:next_goal/src/core/extensions/fixture.dart';
import 'package:next_goal/src/container_injector.dart';
import 'package:next_goal/src/features/soccer/domain/entities/team_rank.dart';
import 'package:next_goal/src/features/soccer/domain/use_cases/standings_usecase.dart';
import 'package:next_goal/src/features/streams/presentation/widgets/highlights_view.dart';

import '../../domain/entities/fixture_details.dart';
import '../../domain/entities/statistics.dart';
import '../widgets/events_view.dart';
import '../widgets/lineups_view.dart';
import '../widgets/statistics_view.dart';

class FixtureTabBar extends StatelessWidget {
  const FixtureTabBar({
    super.key,
    required this.selectedIndex,
    required this.fixtureColor,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final Color fixtureColor;
  final void Function(int) onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _TabItem(title: 'المشاهدات', index: 5, selected: selectedIndex == 0, onTap: () => onTabSelected(0)),
          _TabItem(title: 'الترتيب', index: 4, selected: selectedIndex == 1, onTap: () => onTabSelected(1)),
          _TabItem(title: 'الإحصائيات', index: 3, selected: selectedIndex == 2, onTap: () => onTabSelected(2)),
          _TabItem(title: 'التشكيلة', index: 2, selected: selectedIndex == 3, onTap: () => onTabSelected(3)),
          _TabItem(title: 'التفاصيل', index: 1, selected: selectedIndex == 4, onTap: () => onTabSelected(4)),
          _TabItem(title: 'الأحداث', index: 0, selected: selectedIndex == 5, onTap: () => onTabSelected(5)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({required this.title, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFD4A843), width: 3),
                  ),
                )
              : null,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? const Color(0xFFD4A843) : context.colorsExt.textMuted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class FixtureTabContent extends StatelessWidget {
  const FixtureTabContent({
    super.key,
    required this.selectedIndex,
    this.statistics,
    this.fixtureDetails,
    required this.fixtureColor,
    required this.fixture,
  });

  final int selectedIndex;
  final Statistics? statistics;
  final FixtureDetails? fixtureDetails;
  final Color fixtureColor;
  final dynamic fixture;

  @override
  Widget build(BuildContext context) {
    final fixture = fixtureDetails?.fixture ?? this.fixture;
    final competitionId = fixture?.fixtureLeague.id;
    final homeTeamId = fixture?.teams.home.id;
    final awayTeamId = fixture?.teams.away.id;
    return switch (selectedIndex) {
      0 => HighlightsView(fixture: fixture),
      1 => _RankingTab(competitionId: competitionId, homeTeamId: homeTeamId, awayTeamId: awayTeamId),
      2 => StatisticsView(
        key: ValueKey(statistics?.hashCode ?? 'no_statistics'),
        statistics: statistics,
      ),
      3 => LineupsView(
        key: ValueKey(fixtureDetails?.hashCode ?? 'no_details'),
        fixtureDetails: fixtureDetails,
        color: fixtureColor,
      ),
      4 => _DetailsTab(fixtureDetails: fixtureDetails),
      _ => EventsView(
        key: ValueKey(fixtureDetails?.hashCode ?? 'no_details'),
        fixtureDetails: fixtureDetails,
        color: fixtureColor,
      ),
    };
  }
}

class _RankingTab extends StatefulWidget {
  final int? competitionId;
  final int? homeTeamId;
  final int? awayTeamId;
  const _RankingTab({this.competitionId, this.homeTeamId, this.awayTeamId});

  @override
  State<_RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<_RankingTab> {
  List<TeamRank> _standings = [];
  String _groupName = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStandings();
  }

  Future<void> _fetchStandings() async {
    if (widget.competitionId == null) {
      setState(() { _isLoading = false; _error = 'لا توجد بيانات'; });
      return;
    }
    final useCase = sl<StandingsUseCase>();
    final result = await useCase(StandingsParams(leagueId: widget.competitionId!));
    result.fold(
      (failure) => setState(() { _isLoading = false; _error = 'خطأ في تحميل البيانات'; }),
      (standings) {
        final allTeams = standings.standings;
        final homeMatch = allTeams.where((t) => t.team.id == widget.homeTeamId).toList();
        final awayMatch = allTeams.where((t) => t.team.id == widget.awayTeamId).toList();

        int? targetGroup;
        if (homeMatch.isNotEmpty) targetGroup = homeMatch.first.groupNum;
        if (targetGroup == null && awayMatch.isNotEmpty) targetGroup = awayMatch.first.groupNum;

        List<TeamRank> filtered;
        if (targetGroup != null) {
          filtered = allTeams.where((t) => t.groupNum == targetGroup).toList();
          _groupName = 'المجموعة $targetGroup';
        } else {
          filtered = allTeams;
          _groupName = 'الترتيب العام';
        }

        setState(() { _standings = filtered; _isLoading = false; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFD4A843))),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text(_error!, style: TextStyle(color: context.colorsExt.textMuted, fontSize: 14))),
      );
    }
    if (_standings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('الترتيب غير متوفر', style: TextStyle(color: context.colorsExt.textMuted, fontSize: 14))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.colorsExt.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colorsExt.dividerSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A843).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4A843).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.leaderboard_outlined, color: Color(0xFFD4A843), size: 14),
                  const SizedBox(width: 6),
                  Text(_groupName, style: const TextStyle(color: Color(0xFFD4A843), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _StandingsHeader(),
            const SizedBox(height: 4),
            ...List.generate(_standings.length, (i) {
              final t = _standings[i];
              final isHome = t.team.id == widget.homeTeamId || t.team.id == widget.awayTeamId;
              return _StandingRow(rank: i + 1, team: t, isHighlighted: isHome);
            }),
          ],
        ),
      ),
    );
  }
}

class _StandingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('#', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(flex: 4, child: Text('الفريق', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold))),
          _StatCell(label: 'ن', isHeader: true),
          _StatCell(label: 'خ', isHeader: true),
          _StatCell(label: 'ت', isHeader: true),
          _StatCell(label: 'هـ', isHeader: true),
          _StatCell(label: '+', isHeader: true),
          _StatCell(label: '−', isHeader: true),
          _StatCell(label: 'diff', isHeader: true),
          _StatCell(label: 'نق', isHeader: true, isBold: true),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final int rank;
  final TeamRank team;
  final bool isHighlighted;

  const _StandingRow({
    required this.rank,
    required this.team,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF6366F1).withValues(alpha: 0.15) : null,
        borderRadius: BorderRadius.circular(6),
        border: isHighlighted ? Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4), width: 1) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStyle(
                color: isHighlighted ? const Color(0xFF818CF8) : context.colorsExt.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: team.team.logo,
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(width: 20, height: 20, color: Colors.grey[800]),
                    errorWidget: (_, __, ___) => Container(width: 20, height: 20, color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    team.team.displayName,
                    style: TextStyle(
                      color: isHighlighted ? Theme.of(context).colorScheme.onSurface : Colors.grey[300],
                      fontSize: 11,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          _StatCell(value: '${team.stats.played}'),
          _StatCell(value: '${team.stats.win}'),
          _StatCell(value: '${team.stats.draw}'),
          _StatCell(value: '${team.stats.lose}'),
          _StatCell(value: '${team.stats.scored}'),
          _StatCell(value: '${team.stats.received}'),
          _StatCell(
            value: team.goalsDiff >= 0 ? '+${team.goalsDiff}' : '${team.goalsDiff}',
            color: team.goalsDiff > 0
                ? const Color(0xFFD4A843)
                : team.goalsDiff < 0
                    ? const Color(0xFFE11D48)
                    : context.colorsExt.textMuted,
          ),
          _StatCell(value: '${team.points}', isBold: true),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String? value;
  final String? label;
  final bool isHeader;
  final bool isBold;
  final Color? color;

  const _StatCell({this.value, this.label, this.isHeader = false, this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final text = isHeader ? (label ?? '') : (value ?? '0');
    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? (isHeader ? Colors.grey[600] : context.colorsExt.textMuted),
          fontSize: 10,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final FixtureDetails? fixtureDetails;
  const _DetailsTab({this.fixtureDetails});

  @override
  Widget build(BuildContext context) {
    if (fixtureDetails == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text('لا توجد بيانات', style: TextStyle(color: context.colorsExt.textMuted, fontSize: 14)),
        ),
      );
    }

    final fixture = fixtureDetails!.fixture;
    final venue = fixtureDetails!.venue;
    final leagueName = fixture.fixtureLeague.name;
    final roundNum = fixture.roundNum;
    final startTime = fixture.startTime;

    final String formattedTime;
    final String formattedDate;
    if (startTime != null) {
      formattedTime = startTime.formatForLocale('en', pattern: 'HH:mm');
      formattedDate = startTime.formatForLocale('ar', pattern: 'EEEE ( dd-MM-yyyy )');
    } else {
      formattedTime = 'TBD';
      formattedDate = 'TBD';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('معلومات اللقاء', style: TextStyle(color: context.colorsExt.textMuted, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _DetailRow(label: 'البطولة', value: leagueName, icon: Icons.emoji_events_outlined),
          _DetailRow(label: 'الحالة', value: fixture.statusTextAr, icon: Icons.info_outline),
          if (roundNum != null)
            _DetailRow(label: 'الجولة', value: 'الجولة $roundNum', icon: Icons.numbers),
          if (venue != null)
            _DetailRow(label: 'الملعب', value: venue.name, icon: Icons.stadium_outlined),
          _DetailRow(label: 'الوقت', value: formattedTime, icon: Icons.access_time_rounded),
          _DetailRow(label: 'التاريخ', value: formattedDate, icon: Icons.calendar_today_outlined),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? trailing;
  final IconData? icon;

  const _DetailRow({required this.label, required this.value, this.trailing, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (trailing != null)
            Text(trailing!, style: TextStyle(color: context.colorsExt.textMuted, fontSize: 12))
          else if (icon != null)
            Icon(icon, color: const Color(0xFFD4A843), size: 18)
          else
            Icon(Icons.chevron_left, color: context.colorsExt.textMuted, size: 18),
          const Spacer(),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: context.colorsExt.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}
