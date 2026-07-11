import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class OnboardingState {
  final int currentStep;
  final bool isLoading;
  final String? error;
  final bool isComplete;

  // Transport
  final String transportMode; // car, metro, bicycle, walk
  final double commuteDistanceKm;

  // Food
  final String dietType; // vegetarian, mixed, highMeat
  final int foodDeliveryPerWeek;

  // Energy
  final double acHoursPerDay;
  final bool usesGeyser;
  final bool usesHeater;

  OnboardingState({
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
    this.isComplete = false,
    this.transportMode = 'car',
    this.commuteDistanceKm = 10,
    this.dietType = 'mixed',
    this.foodDeliveryPerWeek = 3,
    this.acHoursPerDay = 4,
    this.usesGeyser = false,
    this.usesHeater = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    bool? isLoading,
    String? error,
    bool? isComplete,
    String? transportMode,
    double? commuteDistanceKm,
    String? dietType,
    int? foodDeliveryPerWeek,
    double? acHoursPerDay,
    bool? usesGeyser,
    bool? usesHeater,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isComplete: isComplete ?? this.isComplete,
      transportMode: transportMode ?? this.transportMode,
      commuteDistanceKm: commuteDistanceKm ?? this.commuteDistanceKm,
      dietType: dietType ?? this.dietType,
      foodDeliveryPerWeek: foodDeliveryPerWeek ?? this.foodDeliveryPerWeek,
      acHoursPerDay: acHoursPerDay ?? this.acHoursPerDay,
      usesGeyser: usesGeyser ?? this.usesGeyser,
      usesHeater: usesHeater ?? this.usesHeater,
    );
  }

  // Carbon calculation logic
  double get transportScore {
    const emissionFactors = {
      'car': 0.21,
      'metro': 0.03,
      'bicycle': 0.0,
      'walk': 0.0,
    };
    return commuteDistanceKm * (emissionFactors[transportMode] ?? 0.21) * 365;
  }

  double get foodScore {
    const dietFactors = {
      'vegetarian': 1.5,
      'mixed': 2.5,
      'highMeat': 3.3,
    };
    double base = (dietFactors[dietType] ?? 2.5) * 365;
    double deliveryExtra = foodDeliveryPerWeek * 0.5 * 52;
    return base + deliveryExtra;
  }

  double get energyScore {
    double acEmissions = acHoursPerDay * 0.9 * 365;
    double geyserEmissions = usesGeyser ? 1.5 * 365 : 0;
    double heaterEmissions = usesHeater ? 2.0 * 120 : 0;
    return acEmissions + geyserEmissions + heaterEmissions;
  }

  double get totalFootprint => transportScore + foodScore + energyScore;
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Dio dio;

  OnboardingNotifier(this.dio) : super(OnboardingState());

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setTransportMode(String mode) {
    state = state.copyWith(transportMode: mode);
  }

  void setCommuteDistance(double distance) {
    state = state.copyWith(commuteDistanceKm: distance);
  }

  void setDietType(String diet) {
    state = state.copyWith(dietType: diet);
  }

  void setFoodDeliveryFrequency(int freq) {
    state = state.copyWith(foodDeliveryPerWeek: freq);
  }

  void setAcHours(double hours) {
    state = state.copyWith(acHoursPerDay: hours);
  }

  void setUsesGeyser(bool val) {
    state = state.copyWith(usesGeyser: val);
  }

  void setUsesHeater(bool val) {
    state = state.copyWith(usesHeater: val);
  }

  Future<bool> submitOnboarding() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await dio.post('/carbontwin', data: {
        'transportScore': state.transportScore,
        'foodScore': state.foodScore,
        'energyScore': state.energyScore,
        'totalFootprint': state.totalFootprint,
      });

      state = state.copyWith(isLoading: false, isComplete: true);
      return true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['error'] ?? 'Submission failed';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final dio = ref.watch(dioProvider);
  return OnboardingNotifier(dio);
});
