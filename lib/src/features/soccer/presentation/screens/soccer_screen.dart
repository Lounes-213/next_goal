import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:next_goal/src/core/constants/app_spacing.dart';
import 'package:next_goal/src/core/widgets/app_error_dialog.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/utils/app_animations.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/settings_language_listener.dart';
import '../cubit/leagues/leagues_cubit.dart';
import '../cubit/leagues/leagues_state.dart';
import '../cubit/soccer/soccer_cubit.dart';
import '../cubit/soccer/soccer_state.dart';
import '../widgets/view_fixtures.dart';

class SoccerScreen extends StatefulWidget {
  const SoccerScreen({super.key});

  @override
  State<SoccerScreen> createState() => _SoccerScreenState();
}

class _SoccerScreenState extends State<SoccerScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<SoccerCubit>().getTodayFixtures();
  }

  void _activateTimerFetching() {
    _timer ??= Timer.periodic(const Duration(minutes: 1), (_) {
      context.read<SoccerCubit>().getTodayFixtures(isTimerLoading: true);
    });
  }

  void _onSoccerStateChange(BuildContext context, SoccerState state) {
    switch (state) {
      case SoccerCurrentRoundFixturesLoadFailure():
        AppErrorDialog.show(
          context: context,
          message: state.message,
          onRetry: () {
            if (state.competitionId != null) {
              context.read<SoccerCubit>().getCurrentRoundFixtures(
                competitionId: state.competitionId!,
              );
            }
          },
        );
      case SoccerTodayFixturesLoadFailure():
        AppErrorDialog.show(
          context: context,
          message: state.message,
          onRetry: context.read<SoccerCubit>().getTodayFixtures,
        );
      case SoccerTodayFixturesLoaded():
        if (state.liveFixtures.isNotEmpty) {
          _activateTimerFetching();
        } else {
          _timer?.cancel();
        }
      default:
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        SettingsLanguageListener(
          onLanguageChanged: (context, state) {
            context.read<LeaguesCubit>().getLeagues(forceRefresh: true);
            context.read<SoccerCubit>().getTodayFixtures();
          },
        ),
        BlocListener<SoccerCubit, SoccerState>(listener: _onSoccerStateChange),
        BlocListener<LeaguesCubit, LeaguesState>(
          listener: (context, state) {
            if (state is LeaguesLoadFailure) {
              AppErrorDialog.show(
                context: context,
                message: state.message,
                onRetry:
                    () => context.read<LeaguesCubit>().getLeagues(
                      forceRefresh: true,
                    ),
              );
            }
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => context.read<SoccerCubit>().getTodayFixtures(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.only(bottom: 120, top: MediaQuery.of(context).padding.top + kToolbarHeight - 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _DaySelector(),
              const SizedBox(height: 16),
              const _ViewFixtures(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector();

  static const _arabicDays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SoccerCubit>();
    final selectedDate = cubit.selectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if selected date is one of the 3 default days
    final isDefaultDay = DateUtils.isSameDay(selectedDate, today) ||
        DateUtils.isSameDay(selectedDate, today.subtract(const Duration(days: 1))) ||
        DateUtils.isSameDay(selectedDate, today.add(const Duration(days: 1)));

    if (isDefaultDay) {
      // Show the 3 default buttons: yesterday, today, tomorrow
      return _buildDefaultDays(context, cubit, selectedDate, today);
    } else {
      // Show selected date + "اليوم" button
      return _buildCustomDate(context, cubit, selectedDate, today);
    }
  }

  Widget _buildDefaultDays(BuildContext context, SoccerCubit cubit, DateTime selectedDate, DateTime today) {
    final days = [
      today.subtract(const Duration(days: 1)),
      today,
      today.add(const Duration(days: 1)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: days.map((day) {
                final isSelected = DateUtils.isSameDay(day, selectedDate);
                final isToday = DateUtils.isSameDay(day, today);
                final dayName = _arabicDays[day.weekday - 1];
                final label = isToday ? 'اليوم' : dayName;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => cubit.setSelectedDate(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD4A843)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d', 'en').format(day),
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          _CalendarButton(cubit: cubit, selectedDate: selectedDate),
        ],
      ),
    );
  }

  Widget _buildCustomDate(BuildContext context, SoccerCubit cubit, DateTime selectedDate, DateTime today) {
    final dayName = _arabicDays[selectedDate.weekday - 1];
    final dateStr = DateFormat('dd/MM', 'en').format(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Selected date button
          Expanded(
            child: GestureDetector(
              onTap: () {}, // Already selected
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A843),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // "اليوم" button to go back to today
          GestureDetector(
            onTap: () => cubit.setSelectedDate(today),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.today_rounded,
                    color: Color(0xFFD4A843),
                    size: 18,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'اليوم',
                    style: TextStyle(
                      color: Color(0xFFD4A843),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CalendarButton(cubit: cubit, selectedDate: selectedDate),
        ],
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  final SoccerCubit cubit;
  final DateTime selectedDate;

  const _CalendarButton({required this.cubit, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Color(0xFFD4A843),
                  surface: Theme.of(context).colorScheme.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) cubit.setSelectedDate(picked);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colorsExt.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colorsExt.dividerSubtle,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.calendar_today_rounded,
          color: Color(0xFFD4A843),
          size: 22,
        ),
      ),
    );
  }
}

class _ViewFixtures extends StatelessWidget {
  const _ViewFixtures();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoccerCubit, SoccerState>(
      buildWhen: (_, state) {
        if (state is SoccerTodayFixturesLoading && !state.isTimerLoading) {
          return true;
        }
        return state is SoccerTodayFixturesLoaded ||
            state is SoccerTodayFixturesLoadFailure;
      },
      builder:
          (context, state) => switch (state) {
            SoccerTodayFixturesLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
              child:
                  ShimmerList(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
            ),
            SoccerTodayFixturesLoaded(
              liveFixtures: final live,
              todayFixtures: final today,
            )
                when today.isNotEmpty =>
              StaggeredList(
                children: [
                  if (live.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: RepaintBoundary(child: ViewLiveFixtures(fixtures: live)),
                    ),
                  if (today.isNotEmpty) ViewDayFixtures(fixtures: today),
                ],
              ),
            SoccerTodayFixturesLoaded() =>
              const AppEmptyWidget().animate().fade().scale(),
            _ => const SizedBox.shrink(),
          },
    );
  }
}
