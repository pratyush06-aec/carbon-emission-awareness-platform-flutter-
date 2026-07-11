import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class LearnState {
  final int chatStep;
  final bool showChallenge;
  final int? selectedOption;
  final bool isAwarding;
  final int xpEarned;

  LearnState({
    this.chatStep = 0,
    this.showChallenge = false,
    this.selectedOption,
    this.isAwarding = false,
    this.xpEarned = 0,
  });

  LearnState copyWith({
    int? chatStep,
    bool? showChallenge,
    int? selectedOption,
    bool? isAwarding,
    int? xpEarned,
  }) {
    return LearnState(
      chatStep: chatStep ?? this.chatStep,
      showChallenge: showChallenge ?? this.showChallenge,
      selectedOption: selectedOption,
      isAwarding: isAwarding ?? this.isAwarding,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}

class LearnNotifier extends StateNotifier<LearnState> {
  final Dio dio;

  LearnNotifier(this.dio) : super(LearnState());

  void sendActivity() {
    state = state.copyWith(chatStep: 1);

    // Simulate AI parsing delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      state = state.copyWith(showChallenge: true);
    });
  }

  Future<void> selectOption(int index) async {
    if (state.selectedOption != null) return;

    state = state.copyWith(selectedOption: index);

    // Correct answer is index 2 (Bicycle) - matching web app logic
    if (index == 2) {
      state = state.copyWith(isAwarding: true);
      try {
        await dio.post('/challenges/reward', data: {
          'xpAmount': 20,
          'challengeName': 'Daily Transport Challenge',
        });
        state = state.copyWith(isAwarding: false, xpEarned: 20);
      } catch (e) {
        state = state.copyWith(isAwarding: false);
      }
    }
  }

  void reset() {
    state = LearnState();
  }
}

final learnProvider =
    StateNotifierProvider<LearnNotifier, LearnState>((ref) {
  final dio = ref.watch(dioProvider);
  return LearnNotifier(dio);
});
