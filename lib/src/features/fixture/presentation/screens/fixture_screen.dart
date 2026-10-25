import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:next_goal/src/config/app_route.dart';
import 'package:next_goal/src/core/layout/adaptive_layout.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/settings_language_listener.dart';
import '../../domain/entities/fixture_details.dart';
import '../../domain/entities/statistics.dart';
import '../cubit/fixture/fixture_cubit.dart';
import '../cubit/statistics/statistics_cubit.dart';
import '../widgets/fixture_details.dart' as detail_widget;
import '../widgets/fixture_tab_bar.dart';

class FixtureScreen extends StatefulWidget {
  final SoccerFixture soccerFixture;

  const FixtureScreen({super.key, required this.soccerFixture});

  @override
  State<FixtureScreen> createState() => _FixtureScreenState();
}

class _FixtureScreenState extends State<FixtureScreen> {
  int _selectedTabIndex = 1;
  Timer? _timer;

  Statistics? _statistics;
  FixtureDetails? _fixtureDetails;

  late ScrollController _scrollController;
  double _appBarOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    if (widget.soccerFixture.status.isLive) _activateTimerFetching();
    context.read<FixtureCubit>().getFixtureDetails(widget.soccerFixture.id);
    context.read<StatisticsCubit>().getStatistics(widget.soccerFixture.id);
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    final double newOpacity = (offset / 100).clamp(0, 1);
    if (newOpacity != _appBarOpacity) {
      setState(() => _appBarOpacity = newOpacity);
    }
  }

  void _activateTimerFetching() {
    _timer ??= Timer.periodic(const Duration(minutes: 1), (timer) {
      context.read<FixtureCubit>().getFixtureDetails(
        widget.soccerFixture.id,
        isTimerLoading: true,
      );
      context.read<StatisticsCubit>().getStatistics(
        widget.soccerFixture.id,
        isTimerLoading: true,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isLiveToday {
    final isLive = widget.soccerFixture.status.isLive;
    if (!isLive) return false;
    final now = DateTime.now();
    final start = widget.soccerFixture.startTime;
    if (start == null) return true;
    return start.year == now.year && start.month == now.month && start.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final homeTeam = widget.soccerFixture.teams.home;
    final awayTeam = widget.soccerFixture.teams.away;
    final fixture = _fixtureDetails?.fixture ?? widget.soccerFixture;

    return SettingsLanguageListener(
      onLanguageChanged: (context, state) {
        context.read<FixtureCubit>().getFixtureDetails(widget.soccerFixture.id);
        context.read<StatisticsCubit>().getStatistics(widget.soccerFixture.id);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: _appBarOpacity > 0.1
                ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha: _appBarOpacity)
                : Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _appBarOpacity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SmallCrest(logo: homeTeam.logo),
                  const SizedBox(width: 8),
                  Text(
                    fixture.status.isLive
                        ? '${homeTeam.score} - ${awayTeam.score}'
                        : '${homeTeam.name} - ${awayTeam.name}',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  _SmallCrest(logo: awayTeam.logo),
                ],
              ),
            ),
            centerTitle: true,
            actions: [
              if (fixture.status.isLive)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fixture.displayMinute,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<StatisticsCubit, StatisticsState>(
                listener: (context, state) {
                  if (state is StatisticsLoaded) {
                    setState(() => _statistics = state.statistics);
                  }
                },
              ),
              BlocListener<FixtureCubit, FixtureState>(
                listener: (context, state) {
                  if (state is FixtureDetailsLoaded) {
                    setState(() => _fixtureDetails = state.fixtureDetails);
                  }
                },
              ),
            ],
            child: BlocBuilder<FixtureCubit, FixtureState>(
              buildWhen: (prev, curr) =>
                  (curr is FixtureDetailsLoading && !curr.isTimerLoading) ||
                  (prev is FixtureDetailsLoading && curr is! FixtureDetailsLoading),
              builder: (context, fixtureState) {
                return BlocBuilder<StatisticsCubit, StatisticsState>(
                  buildWhen: (prev, curr) =>
                      (curr is StatisticsLoading && !curr.isTimerLoading) ||
                      (prev is StatisticsLoading && curr is! StatisticsLoading),
                  builder: (context, statisticsState) {
                    final isLoading =
                        (fixtureState is FixtureDetailsLoading && !fixtureState.isTimerLoading) ||
                        (statisticsState is StatisticsLoading && !statisticsState.isTimerLoading);

                    final fixtureData = _fixtureDetails?.fixture ?? widget.soccerFixture;

                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          context.read<FixtureCubit>().getFixtureDetails(widget.soccerFixture.id),
                          context.read<StatisticsCubit>().getStatistics(widget.soccerFixture.id),
                        ]);
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: detail_widget.FixtureDetails(soccerFixture: fixtureData),
                          ),
                          if (_isLiveToday)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                                child: _LiveStreamButton(fixture: widget.soccerFixture),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                context.pageHorizontalPadding / 2,
                                8,
                                context.pageHorizontalPadding / 2,
                                8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FixtureTabBar(
                                    selectedIndex: _selectedTabIndex,
                                    fixtureColor: const Color(0xFF6366F1),
                                    onTabSelected: (i) => setState(() => _selectedTabIndex = i),
                                  ),
                                  if (isLoading)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: AppLoadingIndicator(
                                        isLinear: true,
                                        color: Color(0xFF6366F1),
                                      ),
                                    )
                                  else
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: FixtureTabContent(
                                        key: ValueKey(_selectedTabIndex),
                                        selectedIndex: _selectedTabIndex,
                                        statistics: _statistics,
                                        fixtureDetails: _fixtureDetails,
                                        fixtureColor: const Color(0xFF6366F1),
                                        fixture: fixtureData,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveStreamButton extends StatelessWidget {
  final SoccerFixture fixture;
  const _LiveStreamButton({required this.fixture});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.watch, extra: fixture),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFBE123C)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: const Color(0xFFE11D48).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.live_tv_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              context.l10n.watchLive,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }
}

class _SmallCrest extends StatelessWidget {
  final String? logo;
  const _SmallCrest({this.logo});

  @override
  Widget build(BuildContext context) {
    if (logo == null || logo!.isEmpty) return const SizedBox(width: 20, height: 20);
    return CachedNetworkImage(
      imageUrl: logo!,
      width: 20,
      height: 20,
      placeholder: (_, __) => const SizedBox(width: 20, height: 20),
      errorWidget: (_, __, ___) => const SizedBox(width: 20, height: 20),
    );
  }
}
