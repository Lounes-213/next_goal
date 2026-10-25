part of 'statistics_cubit.dart';

@immutable
sealed class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// Represents the statistics initial state.
class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

/// Represents the statistics loading state.
class StatisticsLoading extends StatisticsState {
  final bool isTimerLoading;

  const StatisticsLoading({this.isTimerLoading = false});

  @override
  List<Object?> get props => [isTimerLoading];
}

/// Represents the statistics loaded state.
class StatisticsLoaded extends StatisticsState {
  final Statistics statistics;

  const StatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

/// Represents the statistics loading failure state.
class StatisticsLoadingFailure extends StatisticsState {
  final String message;

  const StatisticsLoadingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
