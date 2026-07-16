import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionText: json['questionText']?.toString() ?? 'Missing Question',
      options: json['options'] != null ? List<String>.from(json['options'].map((e) => e.toString())) : [],
      correctAnswerIndex: int.tryParse(json['correctAnswerIndex']?.toString() ?? '0') ?? 0,
      explanation: json['explanation']?.toString() ?? 'No explanation provided.',
    );
  }
}

class LearnState {
  final int chatStep;
  final bool isLoading;
  final String? error;
  
  final String userActivityInput;
  final String analysisMessage;
  final List<QuizQuestion> questions;
  
  final int currentQuestionIndex;
  final int? selectedOption;
  final bool isAwarding;
  final int xpEarned;
  final bool challengeComplete;

  LearnState({
    this.chatStep = 0,
    this.isLoading = false,
    this.error,
    this.userActivityInput = '',
    this.analysisMessage = '',
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedOption,
    this.isAwarding = false,
    this.xpEarned = 0,
    this.challengeComplete = false,
  });

  LearnState copyWith({
    int? chatStep,
    bool? isLoading,
    String? error,
    String? userActivityInput,
    String? analysisMessage,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? selectedOption,
    bool clearSelectedOption = false,
    bool? isAwarding,
    int? xpEarned,
    bool? challengeComplete,
  }) {
    return LearnState(
      chatStep: chatStep ?? this.chatStep,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userActivityInput: userActivityInput ?? this.userActivityInput,
      analysisMessage: analysisMessage ?? this.analysisMessage,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOption: clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      isAwarding: isAwarding ?? this.isAwarding,
      xpEarned: xpEarned ?? this.xpEarned,
      challengeComplete: challengeComplete ?? this.challengeComplete,
    );
  }
}

class LearnNotifier extends StateNotifier<LearnState> {
  final Dio dio;

  LearnNotifier(this.dio) : super(LearnState());

  Future<void> sendActivity(String input) async {
    if (input.trim().isEmpty) return;

    state = state.copyWith(
      chatStep: 1,
      userActivityInput: input,
      isLoading: true,
      error: null,
    );

    try {
      final response = await dio.post(
        '/learn/daily-checkin', 
        data: {
          'activityText': input,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final data = response.data;
      final analysisMessage = data['analysisMessage'] as String;
      final questionsList = (data['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList();

      state = state.copyWith(
        chatStep: 2,
        isLoading: false,
        analysisMessage: analysisMessage,
        questions: questionsList,
        currentQuestionIndex: 0,
        clearSelectedOption: true,
        challengeComplete: false,
        xpEarned: 0,
      );
    } catch (e, stacktrace) {
      print('Daily Check-in Error: $e');
      print(stacktrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed: ${e.toString()}',
        chatStep: 0,
      );
    }
  }

  Future<void> selectOption(int index) async {
    if (state.selectedOption != null || state.challengeComplete) return;

    state = state.copyWith(selectedOption: index);

    // Wait a few seconds for user to read explanation
    await Future.delayed(const Duration(seconds: 4));

    if (state.currentQuestionIndex < state.questions.length - 1) {
      // Go to next question
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        clearSelectedOption: true,
      );
    } else {
      // Completed all questions
      state = state.copyWith(isAwarding: true, challengeComplete: true);
      try {
        await dio.post('/challenges/reward', data: {
          'xpAmount': 50,
          'challengeName': 'Daily Carbon Check-in Challenge',
        });
        state = state.copyWith(isAwarding: false, xpEarned: 50);
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
