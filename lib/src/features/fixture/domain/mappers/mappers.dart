import '../../data/models/event_model.dart';
import '../../data/models/lineups_model.dart';
import '../../data/models/player_model.dart';
import '../entities/event.dart';
import '../entities/lineups.dart';
import '../entities/player.dart';

extension PlayerExtension on PlayerModel {
  Player toDomain() => Player(
    id: id,
    name: name,
    number: number,
    competitorId: competitorId,
    shortName: shortName,
    nameForURL: nameForURL,
    imageId: imageId,
  );
}

extension LineupExtension on LineupModel {
  Lineup toDomain() {
    return Lineup(
      formation: formation,
      status: status,
      members: members.map((m) => (m as LineupMemberModel).toDomain()).toList(),
    );
  }
}

extension LineupMemberExtension on LineupMemberModel {
  LineupMember toDomain() {
    return LineupMember(
      id: id,
      status: status,
      statusText: statusText,
      yardInfo: yardInfo,
    );
  }
}

extension EventExtension on EventModel {
  Event toDomain() {
    return Event(
      addedTime: addedTime,
      gameTime: gameTime,
      gameTimeAndStatusDisplayType: gameTimeAndStatusDisplayType,
      gameTimeDisplay: gameTimeDisplay,
      order: order,
      playerId: playerId,
      teamId: teamId,
      type: type,
    );
  }
}
