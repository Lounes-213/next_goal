import 'package:equatable/equatable.dart';
import 'package:next_goal/src/core/domain/entities/soccer_fixture.dart';
import 'package:next_goal/src/features/fixture/domain/entities/event.dart';
import 'package:next_goal/src/features/fixture/domain/entities/lineups.dart';

import 'player.dart';

/// Represents the fixture details entity/model.
class FixtureDetails extends Equatable {
  final SoccerFixture fixture;
  final List<Event> events;
  final List<Player> members;
  final Venue? venue;

  const FixtureDetails({
    required this.fixture,
    required this.events,
    required this.members,
    this.venue,
  });

  /// Build player info list for a team, matching lineup members to top-level players.
  List<FixturePlayerInfo> _buildPlayersInfo(
    List<LineupMember> lineupMembers,
    int teamId,
  ) {
    final result = <FixturePlayerInfo>[];
    final teamPlayers = members.where((p) => p.competitorId == teamId).toList();

    for (final lm in lineupMembers) {
      Player? matched;

      // Try 1: match by ID
      final byId = teamPlayers.where((p) => p.id == lm.id);
      if (byId.isNotEmpty) {
        matched = byId.first;
      }

      // Try 2: match by jersey number
      if (matched == null && lm.jerseyNumber > 0) {
        final byNumber = teamPlayers.where((p) => p.number == lm.jerseyNumber);
        if (byNumber.isNotEmpty) {
          matched = byNumber.first;
        }
      }

      // Try 3: create Player from LineupMember data
      if (matched == null) {
        matched = Player(
          id: lm.id,
          competitorId: teamId,
          name: lm.name,
          shortName: lm.shortName.isNotEmpty ? lm.shortName : lm.name,
          nameForURL: '',
          number: lm.jerseyNumber,
          imageId: lm.imageId,
        );
      }

      result.add(FixturePlayerInfo(player: matched, lineupMember: lm));
    }
    return result;
  }

  List<FixturePlayerInfo> get homePlayersInfo {
    final homeLineup = fixture.teams.home.lineup;
    if (homeLineup == null) return [];
    return _buildPlayersInfo(homeLineup.members, fixture.teams.home.id);
  }

  List<FixturePlayerInfo> get awayPlayersInfo {
    final awayLineup = fixture.teams.away.lineup;
    if (awayLineup == null) return [];
    return _buildPlayersInfo(awayLineup.members, fixture.teams.away.id);
  }

  List<Event> get sortedEvents {
    final sortedEvents = List<Event>.from(events);
    sortedEvents.sort((a, b) => a.order.compareTo(b.order));
    return sortedEvents;
  }

  @override
  List<Object?> get props => [fixture, events, members, venue];
}

/// Represents the fixture player info entity/model.
class FixturePlayerInfo extends Equatable {
  final Player player;
  final LineupMember lineupMember;

  const FixturePlayerInfo({required this.player, required this.lineupMember});

  @override
  List<Object?> get props => [player, lineupMember];
}

/// Represents the venue entity/model.
class Venue extends Equatable {
  final int id;
  final String name;
  final String shortName;
  final String? googlePlaceId;

  const Venue({
    required this.id,
    required this.name,
    required this.shortName,
    this.googlePlaceId,
  });

  @override
  List<Object?> get props => [id, name, shortName, googlePlaceId];
}
