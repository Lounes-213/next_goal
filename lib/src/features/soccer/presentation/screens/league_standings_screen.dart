import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/domain/entities/league.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../domain/use_cases/standings_usecase.dart';
import '../cubit/leagues/leagues_cubit.dart';
import '../cubit/soccer/soccer_cubit.dart';
import '../cubit/soccer/soccer_state.dart';
import '../../../../core/extensions/context_ext.dart';
import '../widgets/standings_shimmer.dart';

class LeagueStandingsScreen extends StatefulWidget {
  final int competitionId;
  const LeagueStandingsScreen({super.key, required this.competitionId});

  @override
  State<LeagueStandingsScreen> createState() => _LeagueStandingsScreenState();
}

class _LeagueStandingsScreenState extends State<LeagueStandingsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<SoccerCubit>().getStandings(
      StandingsParams(leagueId: widget.competitionId),
    );
  }

  League? _getLeague() {
    return context.read<LeaguesCubit>().availableLeagues
        .where((l) => l.id == widget.competitionId)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final league = _getLeague();
    final leagueName = league?.name ?? '';
    final leagueLogo = league?.logo ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a2a1a), Theme.of(context).scaffoldBackgroundColor],
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: leagueLogo,
                      fit: BoxFit.cover,
                      memCacheWidth: 128,
                      memCacheHeight: 128,
                      placeholder: (_, __) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 40),
                      errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  leagueName,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: context.colorsExt.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? const Color(0xFFD4A843) : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'المجموعات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 0 ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? const Color(0xFFD4A843) : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'أفضل الثوالم',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 1 ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface,
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
          Expanded(
            child: BlocBuilder<SoccerCubit, SoccerState>(
              buildWhen: (_, c) => c is SoccerStandingsLoaded || c is SoccerStandingsLoading || c is SoccerStandingsLoadFailure,
              builder: (context, state) {
                if (state is SoccerStandingsLoading) return const StandingsShimmer(itemCount: 10);
                if (state is SoccerStandingsLoaded) {
                  final groups = state.standings.groups ?? [];
                  final allTeams = state.standings.standings;

                  if (_selectedTab == 0 && groups.isNotEmpty) {
                    return _buildGroupedStandings(groups, allTeams);
                  }
                  return _buildAllStandings(allTeams);
                }
                return const AppEmptyWidget();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedStandings(List groups, List allTeams) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        final groupTeams = allTeams.where((t) => t.groupNum == group.number).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFFD4A843), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'المجموعة ${group.name}',
                    style: const TextStyle(color: Color(0xFFD4A843), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildTableHeaders(),
            ...groupTeams.map((team) => _buildTeamRow(team)),
          ],
        );
      },
    );
  }

  Widget _buildAllStandings(List allTeams) {
    return Column(
      children: [
        _buildTableHeaders(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 40),
            itemCount: allTeams.length,
            itemBuilder: (context, index) => _buildTeamRow(allTeams[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaders() {
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

  Widget _buildTeamRow(dynamic team) {
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
