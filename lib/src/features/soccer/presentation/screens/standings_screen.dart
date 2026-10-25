import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';
import 'package:next_goal/src/core/widgets/app_error_dialog.dart';
import 'package:next_goal/src/features/soccer/domain/use_cases/standings_usecase.dart';
import 'package:next_goal/src/features/soccer/data/datasources/top_scorers_datasource.dart';
import 'package:next_goal/src/features/soccer/data/datasources/soccer_data_source.dart';
import 'package:next_goal/src/core/domain/mappers/mappers.dart';
import 'package:next_goal/src/container_injector.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_ext.dart';

import '../../../../core/domain/entities/league.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/settings_language_listener.dart';
import '../cubit/leagues/leagues_cubit.dart';
import '../cubit/soccer/soccer_cubit.dart';
import '../cubit/soccer/soccer_state.dart';
import '../widgets/standings_shimmer.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key, this.competitionId});

  final int? competitionId;

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> with SingleTickerProviderStateMixin {
  late final int _leagueId;
  late TabController _tabController;
  int _selectedStandingsTab = 0; // 0=groups, 1=all teams
  int _selectedScorersTab = 0; // 0=scorers, 1=assists

  @override
  void initState() {
    super.initState();
    _leagueId = widget.competitionId ?? AppConstants.defaultLeagueId;
    _tabController = TabController(length: 4, vsync: this);
    _fetchStandings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchStandings() {
    context.read<SoccerCubit>().getStandings(
      StandingsParams(leagueId: _leagueId),
    );
  }

  League? _getLeague() {
    return context.read<LeaguesCubit>().availableLeagues
        .where((l) => l.id == _leagueId)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final league = _getLeague();
    final leagueName = league?.name ?? '';
    final leagueLogo = league?.logo ?? '';

    return MultiBlocListener(
      listeners: [
        SettingsLanguageListener(
          onLanguageChanged: (context, _) {
            context.read<LeaguesCubit>().getLeagues(forceRefresh: true);
            _fetchStandings();
          },
        ),
        BlocListener<SoccerCubit, SoccerState>(
          listener: (context, state) {
            if (state is SoccerStandingsLoadFailure) {
              AppErrorDialog.show(
                context: context,
                message: state.message,
                onRetry: _fetchStandings,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Gradient header with logo
            _CompetitionHeader(
              leagueName: leagueName,
              leagueLogo: leagueLogo,
            ),
            // Tab bar
            _buildTabBar(),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MatchesTab(leagueId: _leagueId),
                  _NewsTab(),
                  _StandingsTab(
                    leagueId: _leagueId,
                    selectedTab: _selectedStandingsTab,
                    onTabChanged: (i) => setState(() => _selectedStandingsTab = i),
                  ),
                  _TopScorersTab(
                    competitionId: _leagueId,
                    selectedTab: _selectedScorersTab,
                    onTabChanged: (i) => setState(() => _selectedScorersTab = i),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFFD4A843),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        indicatorColor: const Color(0xFFD4A843),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'المباريات'),
          Tab(text: 'الأخبار'),
          Tab(text: 'الترتيب'),
          Tab(text: 'الهدافون'),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────
class _CompetitionHeader extends StatelessWidget {
  final String leagueName;
  final String leagueLogo;

  const _CompetitionHeader({required this.leagueName, required this.leagueLogo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a2a1a), Theme.of(context).scaffoldBackgroundColor],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.star_border_rounded, color: Colors.white, size: 28),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            height: 80,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: leagueLogo,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 60),
                errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 60),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            leagueName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Matches Tab ─────────────────────────────────────────────────
class _MatchesTab extends StatefulWidget {
  final int leagueId;
  const _MatchesTab({required this.leagueId});

  @override
  State<_MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<_MatchesTab> {
  List _fixtures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ds = sl<SoccerDataSource>();
      final models = await ds.getCompetitionFixtures(widget.leagueId);
      if (mounted) setState(() { _fixtures = models.map((m) => m.toDomain()).toList(); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const StandingsShimmer(itemCount: 8);
    if (_fixtures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, color: Colors.grey[600], size: 48),
            const SizedBox(height: 16),
            Text('مباريات قادمة', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          ],
        ),
      );
    }

    final grouped = _groupByRound(_fixtures);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped[index];
        final header = entry['header'] as String;
        final matches = entry['matches'] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colorsExt.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    header,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ...matches.map((fixture) => _buildMatchRow(fixture)),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupByRound(List fixtures) {
    final map = <String, List>{};
    for (final f in fixtures) {
      final round = f.roundNum ?? 0;
      final key = 'الجولة $round';
      map.putIfAbsent(key, () => []).add(f);
    }

    final result = <Map<String, dynamic>>[];
    for (final entry in map.entries) {
      final matches = entry.value;
      final firstDate = matches.first.startTime;
      String dateStr = '';
      if (firstDate != null) {
        final local = firstDate.toLocal();
        final dayName = _getDayName(local.weekday);
        final month = local.month.toString().padLeft(2, '0');
        final day = local.day.toString().padLeft(2, '0');
        dateStr = '$dayName $day-$month-${local.year}';
      }
      result.add({
        'header': dateStr.isNotEmpty ? '${entry.key}  $dateStr' : entry.key,
        'matches': matches,
      });
    }
    return result;
  }

  String _getDayName(int weekday) {
    const days = {1: 'الإثنين', 2: 'الثلاثاء', 3: 'الأربعاء', 4: 'الخميس', 5: 'الجمعة', 6: 'السبت', 7: 'الأحد'};
    return days[weekday] ?? '';
  }

  Widget _buildMatchRow(dynamic fixture) {
    final home = fixture.teams.home;
    final away = fixture.teams.away;
    final isLive = fixture.status.isLive;
    final isEnded = fixture.status.isEnded;
    final goalsAvailable = home.score != -1 && away.score != -1;
    final now = DateTime.now();
    final matchDate = fixture.startTime?.toLocal();
    final isToday = matchDate != null &&
        matchDate.year == now.year &&
        matchDate.month == now.month &&
        matchDate.day == now.day;

    String centerText;
    Color centerColor;
    Color bgColor = context.colorsExt.dividerSubtle;

    if (isLive) {
      centerText = goalsAvailable ? '${home.score} - ${away.score}' : 'مباشر';
      centerColor = const Color(0xFFFB7185);
      bgColor = const Color(0xFFE11D48).withValues(alpha: 0.15);
    } else if (isEnded && goalsAvailable) {
      centerText = '${home.score} - ${away.score}';
      centerColor = Theme.of(context).colorScheme.onSurface;
    } else if (isToday && matchDate != null) {
      centerText = DateFormat('HH:mm', 'en').format(matchDate);
      centerColor = const Color(0xFFD4A843);
      bgColor = const Color(0xFF0F3D2E);
    } else {
      final local = fixture.startTime?.toLocal();
      if (local != null) {
        final m = local.month.toString().padLeft(2, '0');
        final d = local.day.toString().padLeft(2, '0');
        centerText = '$m/$d';
        centerColor = const Color(0xFFD4A843);
        bgColor = context.colorsExt.dividerSubtle;
      } else {
        centerText = 'TBD';
        centerColor = const Color(0xFFD4A843);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              home.displayName,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 28,
            height: 28,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: home.logo,
                fit: BoxFit.cover,
                memCacheWidth: 56,
                memCacheHeight: 56,
                placeholder: (_, __) => Container(color: context.colorsExt.dividerSubtle),
                errorWidget: (_, __, ___) => Container(color: context.colorsExt.dividerSubtle),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerText,
                  style: TextStyle(color: centerColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                if (isLive) ...[
                  const SizedBox(height: 1),
                  Text(
                    fixture.displayTimeFull,
                    style: const TextStyle(color: Color(0xFFFB7185), fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: away.logo,
                fit: BoxFit.cover,
                memCacheWidth: 56,
                memCacheHeight: 56,
                placeholder: (_, __) => Container(color: context.colorsExt.dividerSubtle),
                errorWidget: (_, __, ___) => Container(color: context.colorsExt.dividerSubtle),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: Text(
              away.displayName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── News Tab ────────────────────────────────────────────────────
class _NewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper_rounded, color: Colors.grey[600], size: 48),
          const SizedBox(height: 16),
          Text('الأخبار', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }
}

// ─── Standings Tab ───────────────────────────────────────────────
class _StandingsTab extends StatelessWidget {
  final int leagueId;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _StandingsTab({
    required this.leagueId,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle: المجموعات / أفضل الثوالم
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: context.colorsExt.surfaceElevated,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 0 ? const Color(0xFFD4A843) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'المجموعات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedTab == 0 ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 1 ? const Color(0xFFD4A843) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'أفضل الثوالم',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedTab == 1 ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Standings table
        Expanded(
          child: BlocBuilder<SoccerCubit, SoccerState>(
            buildWhen: (_, c) => c is SoccerStandingsLoaded || c is SoccerStandingsLoading || c is SoccerStandingsLoadFailure,
            builder: (context, state) {
              if (state is SoccerStandingsLoading) return const StandingsShimmer(itemCount: 10);
              if (state is SoccerStandingsLoaded) {
                final groups = state.standings.groups ?? [];
                final allTeams = state.standings.standings;

                if (selectedTab == 0 && groups.isNotEmpty) {
                  return _buildGroupedStandings(context, groups, allTeams);
                }
                return _buildAllStandings(context, allTeams);
              }
              return const AppEmptyWidget();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedStandings(BuildContext context, List groups, List allTeams) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        final groupTeams = allTeams.where((t) => t.groupNum == group.number).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.keyboard_arrow_up_rounded, color: const Color(0xFFD4A843), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'المجموعة ${group.name}',
                    style: const TextStyle(
                      color: Color(0xFFD4A843),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Headers
            _buildTableHeaders(context),
            // Teams
            ...groupTeams.map((team) => _buildTeamRow(context, team)),
          ],
        );
      },
    );
  }

  Widget _buildAllStandings(BuildContext context, List allTeams) {
    return Column(
      children: [
        _buildTableHeaders(context),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: allTeams.length,
            itemBuilder: (context, index) => _buildTeamRow(context, allTeams[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaders(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: const Row(
        children: [
          SizedBox(width: 24, child: Text('ت', style: _headerStyle)),
          Expanded(flex: 4, child: Text('الفريق', style: _headerStyle)),
          SizedBox(width: 28, child: Text('لعب', style: _headerStyle, textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('ف', style: _headerStyle, textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('ت', style: _headerStyle, textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('خ', style: _headerStyle, textAlign: TextAlign.center)),
          SizedBox(width: 44, child: Text('أهداف', style: _headerStyle, textAlign: TextAlign.center)),
          SizedBox(width: 32, child: Text('الفرق', style: _headerStyle, textAlign: TextAlign.center)),
          SizedBox(width: 32, child: Text('نقاط', style: _headerStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, dynamic team) {
    final stats = team.stats;
    final goalsStr = '${stats.scored}:${stats.received}';
    final diff = team.goalsDiff;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${team.rank}',
              style: TextStyle(
                color: team.rank <= 3 ? const Color(0xFFD4A843) : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: team.team.logo,
                      fit: BoxFit.cover,
                      memCacheWidth: 64,
                      memCacheHeight: 64,
                      placeholder: (_, __) => Container(color: context.colorsExt.dividerSubtle),
                      errorWidget: (_, __, ___) => Container(
                        color: context.colorsExt.dividerSubtle,
                        child: Center(child: Text(team.team.name[0], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    team.team.displayName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 28, child: Text('${stats.played}', style: _cellStyle(context), textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('${stats.win}', style: _cellStyle(context), textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('${stats.draw}', style: _cellStyle(context), textAlign: TextAlign.center)),
          SizedBox(width: 24, child: Text('${stats.lose}', style: _cellStyle(context), textAlign: TextAlign.center)),
          SizedBox(width: 44, child: Text(goalsStr, style: _cellStyle(context), textAlign: TextAlign.center)),
          SizedBox(
            width: 32,
            child: Text(
              diff >= 0 ? '+$diff' : '$diff',
              style: TextStyle(
                color: diff > 0 ? const Color(0xFFD4A843) : diff < 0 ? const Color(0xFFE11D48) : Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${team.points}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500);
TextStyle _cellStyle(BuildContext context) => TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12);

// ─── Top Scorers Tab ─────────────────────────────────────────────
class _TopScorersTab extends StatelessWidget {
  final int competitionId;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _TopScorersTab({
    required this.competitionId,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle: الهدافين / الصانع
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: context.colorsExt.surfaceElevated,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 0 ? const Color(0xFFD4A843) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'الهدافين',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedTab == 0 ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 1 ? const Color(0xFFD4A843) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'الصانع',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedTab == 1 ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Scorers list
        Expanded(
          child: _ScorersList(competitionId: competitionId),
        ),
      ],
    );
  }
}

class _ScorersList extends StatefulWidget {
  final int competitionId;
  const _ScorersList({required this.competitionId});

  @override
  State<_ScorersList> createState() => _ScorersListState();
}

class _ScorersListState extends State<_ScorersList> {
  List _scorers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ds = sl<TopScorersDataSource>();
      final models = await ds.getTopScorers(widget.competitionId);
      if (mounted) setState(() { _scorers = models.map((m) => m.toDomain()).toList(); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const StandingsShimmer(itemCount: 8);

    return Column(
      children: [
        // Headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Row(
            children: [
              SizedBox(width: 30, child: Text('ت', style: _headerStyle)),
              Expanded(flex: 3, child: Text('اللاعب', style: _headerStyle)),
              SizedBox(width: 50, child: Text('الأهداف', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 40, child: Text('جزأ.ه', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 40, child: Text('جزأ.ض', style: _headerStyle, textAlign: TextAlign.center)),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _scorers.length,
            itemBuilder: (context, index) {
              final scorer = _scorers[index];
              return _buildScorerRow(context, scorer, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScorerRow(BuildContext context, dynamic scorer, int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank <= 3 ? const Color(0xFFD4A843) : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipOval(
                    child: scorer.imageId != null
                        ? CachedNetworkImage(
                            imageUrl: AppConstants.athleteImage(scorer.imageId!, size: '80'),
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: context.colorsExt.dividerSubtle),
                            errorWidget: (_, __, ___) => Container(
                              color: context.colorsExt.dividerSubtle,
                              child: Center(child: Text(scorer.name[0], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12))),
                            ),
                          )
                        : Container(
                            color: context.colorsExt.dividerSubtle,
                            child: Center(child: Text(scorer.name[0], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12))),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scorer.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      if (scorer.teamName != null)
                        Text(
                          scorer.teamName!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '${scorer.goals}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 40, child: Text('0', style: _cellStyle(context), textAlign: TextAlign.center)),
          SizedBox(width: 40, child: Text('0', style: _cellStyle(context), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
