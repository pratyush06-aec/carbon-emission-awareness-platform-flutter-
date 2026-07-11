import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CarbonTwin AI'),
        centerTitle: true,
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load dashboard',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(dashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Carbon Score Card
              _CarbonScoreCard(data: data),
              const SizedBox(height: 16),

              // Breakdown Chips
              _BreakdownRow(breakdown: data.breakdown),
              const SizedBox(height: 16),

              // XP Progress
              _XpCard(xpBalance: data.xpBalance),
              const SizedBox(height: 16),

              // Weekly Trend Chart
              _WeeklyTrendCard(activities: data.recentActivities),
              const SizedBox(height: 16),

              // Recent Activities
              _RecentActivitiesCard(activities: data.recentActivities),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarbonScoreCard extends StatelessWidget {
  final DashboardData data;
  const _CarbonScoreCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Today\'s Emissions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.todayEmissions.toStringAsFixed(1)} kg',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'CO₂ equivalent',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total',
                  value: '${data.totalEmissions.toStringAsFixed(0)} kg',
                ),
                _StatItem(
                  label: 'XP Balance',
                  value: '${data.xpBalance}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final Map<String, double> breakdown;
  const _BreakdownRow({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final items = [
      _BreakdownItem(Icons.directions_car, 'Transport',
          breakdown['TRANSPORT'] ?? 0, Colors.blue),
      _BreakdownItem(
          Icons.restaurant, 'Food', breakdown['FOOD'] ?? 0, Colors.orange),
      _BreakdownItem(
          Icons.bolt, 'Energy', breakdown['ENERGY'] ?? 0, Colors.amber),
    ];

    return Row(
      children: items
          .map((item) => Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Icon(item.icon, color: item.color),
                        const SizedBox(height: 4),
                        Text(
                          '${item.value.toStringAsFixed(0)} kg',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(item.label,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _BreakdownItem {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  _BreakdownItem(this.icon, this.label, this.value, this.color);
}

class _XpCard extends StatelessWidget {
  final int xpBalance;
  const _XpCard({required this.xpBalance});

  @override
  Widget build(BuildContext context) {
    final level = (xpBalance / 100).floor() + 1;
    final progress = (xpBalance % 100) / 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 35,
              lineWidth: 6,
              percent: progress.clamp(0.0, 1.0),
              center: Text(
                'Lv$level',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: Theme.of(context).colorScheme.primary,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$xpBalance XP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${100 - (xpBalance % 100)} XP to Level ${level + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyTrendCard extends StatelessWidget {
  final List<dynamic> activities;
  const _WeeklyTrendCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    // Create simple spots from recent activities
    final spots = <FlSpot>[];
    for (int i = 0; i < activities.length && i < 7; i++) {
      final carbonValue =
          (activities[i]['carbonValue'] as num?)?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), carbonValue));
    }

    if (spots.isEmpty) {
      spots.addAll([
        const FlSpot(0, 0),
        const FlSpot(1, 0),
      ]);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  final List<dynamic> activities;
  const _RecentActivitiesCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No activities yet. Complete onboarding to get started!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...activities.take(5).map((act) {
              final type = act['type'] as String? ?? '';
              final desc = act['description'] as String? ?? '';
              final carbon = (act['carbonValue'] as num?)?.toDouble() ?? 0;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(_getIconForType(type)),
                title: Text(desc),
                trailing: Text(
                  '${carbon.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'TRANSPORT':
        return Icons.directions_car;
      case 'FOOD':
        return Icons.restaurant;
      case 'ENERGY':
        return Icons.bolt;
      default:
        return Icons.eco;
    }
  }
}
