import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';

class FoodStep extends ConsumerWidget {
  const FoodStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.restaurant, size: 48),
          const SizedBox(height: 16),
          Text(
            'Food Habits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your diet and food delivery habits.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Diet type',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                avatar: const Icon(Icons.eco),
                label: const Text('Vegetarian'),
                selected: onboarding.dietType == 'vegetarian',
                onSelected: (_) =>
                    ref.read(onboardingProvider.notifier).setDietType('vegetarian'),
                showCheckmark: false,
              ),
              FilterChip(
                avatar: const Icon(Icons.lunch_dining),
                label: const Text('Mixed'),
                selected: onboarding.dietType == 'mixed',
                onSelected: (_) =>
                    ref.read(onboardingProvider.notifier).setDietType('mixed'),
                showCheckmark: false,
              ),
              FilterChip(
                avatar: const Icon(Icons.kebab_dining),
                label: const Text('High Meat'),
                selected: onboarding.dietType == 'highMeat',
                onSelected: (_) =>
                    ref.read(onboardingProvider.notifier).setDietType('highMeat'),
                showCheckmark: false,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Food delivery orders per week: ${onboarding.foodDeliveryPerWeek}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: onboarding.foodDeliveryPerWeek.toDouble(),
            min: 0,
            max: 14,
            divisions: 14,
            label: '${onboarding.foodDeliveryPerWeek}',
            onChanged: (val) => ref
                .read(onboardingProvider.notifier)
                .setFoodDeliveryFrequency(val.toInt()),
          ),
        ],
      ),
    );
  }
}
