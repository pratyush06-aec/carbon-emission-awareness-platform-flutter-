import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';

class EnergyStep extends ConsumerWidget {
  const EnergyStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt, size: 48),
          const SizedBox(height: 16),
          Text(
            'Energy Consumption',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How much energy do you consume daily?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'AC usage: ${onboarding.acHoursPerDay.toStringAsFixed(0)} hours/day',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: onboarding.acHoursPerDay,
            min: 0,
            max: 24,
            divisions: 24,
            label: '${onboarding.acHoursPerDay.toStringAsFixed(0)} hrs',
            onChanged: (val) =>
                ref.read(onboardingProvider.notifier).setAcHours(val),
          ),
          const SizedBox(height: 24),
          Text(
            'Other appliances',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Water Geyser'),
            subtitle: const Text('Daily hot water usage'),
            value: onboarding.usesGeyser,
            onChanged: (val) =>
                ref.read(onboardingProvider.notifier).setUsesGeyser(val),
          ),
          SwitchListTile(
            title: const Text('Room Heater'),
            subtitle: const Text('Winter usage (~4 months)'),
            value: onboarding.usesHeater,
            onChanged: (val) =>
                ref.read(onboardingProvider.notifier).setUsesHeater(val),
          ),
        ],
      ),
    );
  }
}
