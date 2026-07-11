import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';

class SummaryStep extends ConsumerWidget {
  const SummaryStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assessment, size: 48),
          const SizedBox(height: 16),
          Text(
            'Your Carbon Twin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your estimated annual carbon footprint.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          // Total Footprint Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${(onboarding.totalFootprint / 1000).toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(onboarding.totalFootprint),
                    ),
                  ),
                  Text(
                    'Tons CO₂ / year',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Breakdown
          _BreakdownTile(
            icon: Icons.directions_car,
            label: 'Transport',
            value: onboarding.transportScore,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _BreakdownTile(
            icon: Icons.restaurant,
            label: 'Food',
            value: onboarding.foodScore,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _BreakdownTile(
            icon: Icons.bolt,
            label: 'Energy',
            value: onboarding.energyScore,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          if (onboarding.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                onboarding.error!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(double totalKg) {
    if (totalKg < 2000) return Colors.green;
    if (totalKg < 4000) return Colors.orange;
    return Colors.red;
  }
}

class _BreakdownTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _BreakdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          '${(value / 1000).toStringAsFixed(1)} t',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
