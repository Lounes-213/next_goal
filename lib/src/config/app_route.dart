import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:next_goal/src/features/fixture/presentation/cubit/fixture/fixture_cubit.dart';
import 'package:next_goal/src/features/fixture/presentation/cubit/statistics/statistics_cubit.dart';

import '../container_injector.dart';
import '../core/domain/entities/soccer_fixture.dart';
import '../core/l10n/app_l10n.dart';
import '../features/fixture/presentation/screens/fixture_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/soccer/presentation/screens/notifications_screen.dart';
import '../features/soccer/presentation/screens/profile_screen.dart';
import '../features/soccer/presentation/screens/search_screen.dart';
import '../features/soccer/presentation/screens/team_detail_screen.dart';
import '../features/streams/domain/entities/stream_link.dart';
import '../features/streams/presentation/screens/channels_screen.dart';
import '../features/streams/presentation/screens/stream_screen.dart';
import '../features/soccer/presentation/cubit/leagues/leagues_cubit.dart';
import '../features/soccer/presentation/cubit/soccer/soccer_cubit.dart';
import '../features/soccer/presentation/screens/fixtures_screen.dart';
import '../features/soccer/presentation/screens/league_standings_screen.dart';
import '../features/soccer/presentation/screens/soccer_layout.dart';
import '../features/soccer/presentation/screens/soccer_screen.dart';
import '../features/soccer/presentation/screens/standings_screen.dart';

class Routes {
  static const String soccer = '/soccer';
  static const String fixtures = '/fixtures';
  static const String standings = '/standings';
  static const String fixtureDetails = '/fixture_details';
  static const String settings = '/settings';
  static const String watch = '/watch';
  static const String channels = '/channels';
  static const String channelPlayer = '/channel_player';
  static const String search = '/search';
  static const String topScorers = '/top_scorers';
  static const String playerDetail = '/player_detail';
  static const String teamDetail = '/team_detail';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String leagueStandalone = '/league_standalone';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: Routes.soccer,
    routes: [
      ShellRoute(
        builder: (_, _, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => sl<LeaguesCubit>()..getLeagues(),
              ),
              BlocProvider(create: (context) => sl<SoccerCubit>()),
            ],
            child: SoccerLayout(child: child),
          );
        },
        routes: [
          GoRoute(
            path: Routes.soccer,
            pageBuilder: (context, _) {
              return const NoTransitionPage(child: SoccerScreen());
            },
          ),
          GoRoute(
            path: Routes.fixtures,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: FixturesScreen(competitionId: state.extra as int?),
              );
            },
          ),
          GoRoute(
            path: Routes.standings,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: StandingsScreen(competitionId: state.extra as int?),
              );
            },
          ),
          GoRoute(
            path: Routes.channels,
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: ChannelsScreen());
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.leagueStandalone,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<SoccerCubit>()),
                BlocProvider(create: (_) => sl<LeaguesCubit>()..getLeagues()),
              ],
              child: LeagueStandingsScreen(competitionId: state.extra as int),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.fixtureDetails,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<FixtureCubit>()),
                BlocProvider(create: (_) => sl<StatisticsCubit>()),
              ],
              child: FixtureScreen(soccerFixture: state.extra as SoccerFixture),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.settings,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: SettingsScreen());
        },
      ),
      GoRoute(
        path: Routes.search,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: SearchScreen());
        },
      ),
      GoRoute(
        path: Routes.teamDetail,
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return NoTransitionPage(
            child: TeamDetailScreen(
              teamId: data['teamId'] as int,
              teamName: data['teamName'] as String,
              teamLogo: data['teamLogo'] as String?,
              fifaRanking: data['fifaRanking'] as int?,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.watch,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: StreamScreen(fixture: state.extra as SoccerFixture),
          );
        },
      ),
      GoRoute(
        path: Routes.channelPlayer,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: ChannelPlayerScreen(channel: state.extra as StreamLink),
          );
        },
      ),
      GoRoute(
        path: Routes.notifications,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: NotificationsScreen());
        },
      ),
      GoRoute(
        path: Routes.profile,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: ProfileScreen());
        },
      ),
    ],
  );
}

class NoRouteFound extends StatelessWidget {
  const NoRouteFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(context.l10n.noRouteFound)));
  }
}
