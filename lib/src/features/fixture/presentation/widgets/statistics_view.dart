import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/statistics.dart';
import 'no_statistics.dart';

class StatisticsView extends StatelessWidget {
  final Statistics? statistics;

  const StatisticsView({super.key, this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics?.statistics == null ||
        (statistics?.statistics ?? []).isEmpty ||
        statistics?.teams == null) {
      return const NoStatistics();
    }

    final homeStats = statistics!.homeStatistics ?? [];
    final awayStats = statistics!.awayStatistics ?? [];

    double homePossession = 50;
    double awayPossession = 50;
    for (int i = 0; i < homeStats.length; i++) {
      if (homeStats[i].name.contains('الاستحواذ') || homeStats[i].name.toLowerCase().contains('possession')) {
        homePossession = double.tryParse(homeStats[i].value.replaceAll('%', '')) ?? 50;
        awayPossession = i < awayStats.length ? (double.tryParse(awayStats[i].value.replaceAll('%', '')) ?? 50) : 50;
        break;
      }
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PossessionChart(
              homePercent: homePossession,
              awayPercent: awayPossession,
              homeColor: const Color(0xFF6366F1),
              awayColor: const Color(0xFFD4A843),
            ),
            const SizedBox(height: 32),
            ...List.generate(homeStats.length, (index) {
              if (index == 0 && homeStats[index].name.contains('الاستحواذ')) {
                return const SizedBox.shrink();
              }
              return _StatBar(
                homeValue: homeStats[index].value,
                awayValue: index < awayStats.length ? awayStats[index].value : '0',
                label: homeStats[index].name,
                homeColor: const Color(0xFF6366F1),
                awayColor: const Color(0xFFD4A843),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PossessionChart extends StatelessWidget {
  final double homePercent;
  final double awayPercent;
  final Color homeColor;
  final Color awayColor;

  const _PossessionChart({
    required this.homePercent,
    required this.awayPercent,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _DonutPainter(
                homePercent: homePercent,
                awayPercent: awayPercent,
                homeColor: homeColor,
                awayColor: awayColor,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الاستحواذ',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${awayPercent.toInt()}%',
                    style: TextStyle(color: awayColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${homePercent.toInt()}%',
                    style: TextStyle(color: homeColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double homePercent;
  final double awayPercent;
  final Color homeColor;
  final Color awayColor;

  _DonutPainter({
    required this.homePercent,
    required this.awayPercent,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    final homePaint = Paint()
      ..color = homeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final awayPaint = Paint()
      ..color = awayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final homeAngle = (homePercent / 100) * 2 * math.pi;
    final awayAngle = (awayPercent / 100) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      homeAngle,
      false,
      homePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + homeAngle,
      awayAngle,
      false,
      awayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}

class _StatBar extends StatelessWidget {
  final String homeValue;
  final String awayValue;
  final String label;
  final Color homeColor;
  final Color awayColor;

  const _StatBar({
    required this.homeValue,
    required this.awayValue,
    required this.label,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  Widget build(BuildContext context) {
    final homeNum = double.tryParse(homeValue.replaceAll('%', '').trim()) ?? 0;
    final awayNum = double.tryParse(awayValue.replaceAll('%', '').trim()) ?? 0;
    final total = homeNum + awayNum;
    final homeFlex = total > 0 ? homeNum / total : 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  homeValue,
                  style: TextStyle(
                    color: homeNum > awayNum ? homeColor : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  awayValue,
                  style: TextStyle(
                    color: awayNum > homeNum ? awayColor : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: homeFlex,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [homeColor, homeColor.withValues(alpha: 0.6)],
                        ),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 1 - homeFlex,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [awayColor.withValues(alpha: 0.6), awayColor],
                        ),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
