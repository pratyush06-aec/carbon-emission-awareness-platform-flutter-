import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/onboarding_provider.dart';
import 'steps/transport_step.dart';
import 'steps/food_step.dart';
import 'steps/energy_step.dart';
import 'steps/summary_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);

    ref.listen<OnboardingState>(onboardingProvider, (prev, next) {
      if (next.isComplete) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Carbon Twin'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 4,
              effect: WormEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                // Sync with provider if needed
              },
              children: const [
                TransportStep(),
                FoodStep(),
                EnergyStep(),
                SummaryStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (onboarding.currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(onboardingProvider.notifier).previousStep();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (onboarding.currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: onboarding.isLoading
                        ? null
                        : () {
                            if (onboarding.currentStep < 3) {
                              ref.read(onboardingProvider.notifier).nextStep();
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              ref
                                  .read(onboardingProvider.notifier)
                                  .submitOnboarding();
                            }
                          },
                    child: onboarding.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            onboarding.currentStep < 3
                                ? 'Next'
                                : 'Create My Carbon Twin',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
