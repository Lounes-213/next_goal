import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_route.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/app_empty.dart';
import 'fixture_card.dart';
import 'live_fixtures_card.dart';

class ViewDayFixtures extends StatelessWidget {
  final List<SoccerFixture> fixtures;

  const ViewDayFixtures({super.key, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: AppEmptyWidget(),
      );
    }

    final grouped = _groupByLeague(fixtures);

    return Column(
      children: grouped.entries.map((entry) {
        final leagueId = entry.key;
        final leagueName = entry.value.first.fixtureLeague.name;
        final leagueLogo = entry.value.first.fixtureLeague.logo;
        final leagueFixtures = entry.value;

        return _LeagueGroup(
          leagueId: leagueId,
          leagueName: leagueName,
          leagueLogo: leagueLogo,
          fixtures: leagueFixtures,
        );
      }).toList(),
    );
  }

  Map<int, List<SoccerFixture>> _groupByLeague(List<SoccerFixture> fixtures) {
    final map = <int, List<SoccerFixture>>{};
    for (final fixture in fixtures) {
      map.putIfAbsent(fixture.fixtureLeague.id, () => []).add(fixture);
    }
    return map;
  }
}

class _LeagueGroup extends StatelessWidget {
  final int leagueId;
  final String leagueName;
  final String leagueLogo;
  final List<SoccerFixture> fixtures;

  const _LeagueGroup({
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
    required this.fixtures,
  });

  String _stripGroupName(String name) {
    // Remove " - Group X" suffix from league names
    final groupPattern = RegExp(r'\s*-\s*Group\s+\w+$', caseSensitive: false);
    return name.replaceAll(groupPattern, '');
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _stripGroupName(leagueName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push(Routes.leagueStandalone, extra: leagueId),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.colorsExt.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.chevron_left, color: Colors.grey[500], size: 20),
                const Spacer(),
                Text(
                  displayName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: leagueLogo,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 20),
                      errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...List.generate(fixtures.length, (index) {
          final fixture = fixtures[index];
          final localTime = fixture.startTime;
          // Always use 'en' locale for Western numerals (12:00 not ١٢:٠٠)
          final formattedTime = localTime == null
              ? null
              : DateFormat('HH:mm', 'en').format(localTime.toLocal());

          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => context.push(Routes.fixtureDetails, extra: fixture),
            child: FixtureCard(soccerFixture: fixture, fixtureTime: formattedTime),
          ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ViewLiveFixtures extends StatefulWidget {
  final List<SoccerFixture> fixtures;

  const ViewLiveFixtures({super.key, required this.fixtures});

  @override
  State<ViewLiveFixtures> createState() => _ViewLiveFixturesState();
}

class _ViewLiveFixturesState extends State<ViewLiveFixtures> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollButtons)
      ..dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final canLeft = position.pixels > 0;
    final canRight = position.pixels < position.maxScrollExtent;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  Future<void> _scrollBy(double offset) async {
    final target = (_scrollController.offset + offset).clamp(0.0, _scrollController.position.maxScrollExtent);
    await _scrollController.animateTo(target, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 1100 ? 220.0 : 190.0;
        final railHeight = constraints.maxWidth >= 760 ? 250.0 : 246.0;
        final scrollAmount = cardWidth + 16;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.play_circle_filled_rounded, color: const Color(0xFFE11D48), size: 20)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .fade(begin: 0.5, end: 1.0, duration: 1.seconds),
                  const SizedBox(width: 6),
                  Text(l10n.liveFixtures, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  _RailArrow(icon: Icons.chevron_left_rounded, enabled: _canScrollLeft, onTap: () => _scrollBy(-scrollAmount)),
                  const SizedBox(width: 4),
                  _RailArrow(icon: Icons.chevron_right_rounded, enabled: _canScrollRight, onTap: () => _scrollBy(scrollAmount)),
                ],
              ),
            ),
            SizedBox(
              height: railHeight,
              child: ListView.separated(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => context.push(Routes.fixtureDetails, extra: widget.fixtures[index]),
                    child: LiveFixtureCard(soccerFixture: widget.fixtures[index], width: cardWidth),
                  ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
                },
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemCount: widget.fixtures.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RailArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _RailArrow({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: context.colorsExt.dividerSubtle,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: enabled ? Theme.of(context).colorScheme.onSurface : Colors.grey[700], size: 16),
      ),
    );
  }
}
