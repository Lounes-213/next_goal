import 'package:next_goal/src/core/constants/parsers.dart';

import '../../domain/entities/lineups.dart';

class LineupModel extends Lineup {
  const LineupModel({
    required super.status,
    required super.formation,
    required super.members,
  });

  factory LineupModel.fromJson(Map<String, dynamic> json) {
    return LineupModel(
      status: json['status'] ?? '',
      formation: json['formation'] ?? '',
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => LineupMemberModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class YardInfoModel extends YardInfo {
  const YardInfoModel({
    required super.line,
    required super.fieldPosition,
    super.fieldLine,
    super.fieldSide,
  });

  factory YardInfoModel.fromJson(Map<String, dynamic> json) {
    return YardInfoModel(
      line: toInt(json['line']) ?? 0,
      fieldPosition: toInt(json['fieldPosition']) ?? 0,
      fieldLine: toInt(json['fieldLine']),
      fieldSide: toInt(json['fieldSide']),
    );
  }
}

class LineupMemberModel extends LineupMember {
  const LineupMemberModel({
    required super.id,
    required super.status,
    required super.statusText,
    super.yardInfo,
    super.name,
    super.shortName,
    super.jerseyNumber,
    super.imageId,
  });

  factory LineupMemberModel.fromJson(Map<String, dynamic> json) {
    return LineupMemberModel(
      id: toInt(json['id']) ?? 0,
      status: toInt(json['status']) ?? 0,
      statusText: json['statusText'] ?? '',
      yardInfo:
          json['yardFormation'] != null
              ? YardInfoModel.fromJson(json['yardFormation'])
              : null,
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      jerseyNumber: toInt(json['jerseyNumber']) ?? 0,
      imageId: toInt(json['imageId']) ?? toInt(json['athleteId']),
    );
  }
}
