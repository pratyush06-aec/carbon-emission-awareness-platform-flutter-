import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';

class TransportStep extends ConsumerWidget {
  const TransportStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.directions_car, size: 48),
          const SizedBox(height: 16),
          Text(
            'Transportation Habits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How do you usually commute?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Primary mode of transport',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ModeChip(
                icon: Icons.directions_car,
                label: 'Car / Cab',
                value: 'car',
                selected: onboarding.transportMode == 'car',
                onSelected: () =>
                    ref.read(onboardingProvider.notifier).setTransportMode('car'),
              ),
              _ModeChip(
                icon: Icons.train,
                label: 'Metro',
                value: 'metro',
                selected: onboarding.transportMode == 'metro',
                onSelected: () =>
                    ref.read(onboardingProvider.notifier).setTransportMode('metro'),
              ),
              _ModeChip(
                icon: Icons.pedal_bike,
                label: 'Bicycle',
                value: 'bicycle',
                selected: onboarding.transportMode == 'bicycle',
                onSelected: () =>
                    ref.read(onboardingProvider.notifier).setTransportMode('bicycle'),
              ),
              _ModeChip(
                icon: Icons.directions_walk,
                label: 'Walk',
                value: 'walk',
                selected: onboarding.transportMode == 'walk',
                onSelected: () =>
                    ref.read(onboardingProvider.notifier).setTransportMode('walk'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Daily commute distance: ${onboarding.commuteDistanceKm.toStringAsFixed(0)} km',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: onboarding.commuteDistanceKm,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${onboarding.commuteDistanceKm.toStringAsFixed(0)} km',
            onChanged: (val) =>
                ref.read(onboardingProvider.notifier).setCommuteDistance(val),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}
