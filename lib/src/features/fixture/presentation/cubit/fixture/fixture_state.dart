part of 'fixture_cubit.dart';

@immutable
sealed class FixtureState extends Equatable {
  const FixtureState();

  @override
  List<Object?> get props => [];
}

/// Represents the fixture initial state.
class FixtureInitial extends FixtureState {
  const FixtureInitial();
}

/// Represents the fixture details loading state.
class FixtureDetailsLoading extends FixtureState {
  final bool isTimerLoading;

  const FixtureDetailsLoading({this.isTimerLoading = false});

  @override
  List<Object?> get props => [isTimerLoading];
}

/// Represents the fixture details loaded state.
class FixtureDetailsLoaded extends FixtureState {
  final FixtureDetails fixtureDetails;

  const FixtureDetailsLoaded({required this.fixtureDetails});

  @override
  List<Object?> get props => [fixtureDetails];
}

/// Represents the fixture details loading failure state.
class FixtureDetailsLoadingFailure extends FixtureState {
  final String message;

  const FixtureDetailsLoadingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
