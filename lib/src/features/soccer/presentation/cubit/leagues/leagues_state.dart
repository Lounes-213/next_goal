import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/domain/entities/league.dart';

@immutable
sealed class LeaguesState extends Equatable {
  const LeaguesState();

  @override
  List<Object?> get props => [];
}

/// Represents the leagues initial entity/model.
class LeaguesInitial extends LeaguesState {
  const LeaguesInitial();
}

/// Represents the leagues loading entity/model.
class LeaguesLoading extends LeaguesState {
  const LeaguesLoading();
}

/// Represents the leagues loaded entity/model.
class LeaguesLoaded extends LeaguesState {
  final List<League> leagues;

  const LeaguesLoaded(this.leagues);

  @override
  List<Object?> get props => [leagues];
}

/// Represents the leagues load failure entity/model.
class LeaguesLoadFailure extends LeaguesState {
  final String message;

  const LeaguesLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
