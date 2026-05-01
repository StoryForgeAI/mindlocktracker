import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(weeklyMinutesProvider);
    final focusScore = ref.watch(focusScoreProvider);
    final blockedAttempts = ref.watch(blockedAttemptsProvider);
    final streak = ref.watch(streakProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Mind Lock Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _StatsRow(
            focusScore: focusScore,
            blockedAttempts: blockedAttempts,
            streak: streak,
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: [
                          for (var i = 0; i < weekly.length; i++) FlSpot(i.toDouble(), weekly[i].toDouble()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      for (var i = 0; i < weekly.length; i++)
                        BarChartGroupData(x: i, barRods: [BarChartRodData(toY: weekly[i].toDouble())]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.focusScore,
    required this.blockedAttempts,
    required this.streak,
  });

  final int focusScore;
  final int blockedAttempts;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Focus score', value: '$focusScore%')),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(label: 'Blocked attempts', value: '$blockedAttempts')),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(label: 'Streak', value: '$streak days')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
