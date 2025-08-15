
import 'dart:async';
import 'package:flutter_quiz_app/presentation/providers/quiz_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/question.dart';
import '../../domain/usecases/get_questions_usecase.dart';

final questionsProvider = FutureProvider<List<Question>>(
      (ref) async {
    final repository = ref.watch(quizRepositoryProvider);
    final useCase = GetQuestionsUseCase(repository);
    return useCase();
  },
  dependencies: [quizRepositoryProvider],
);

class QuizState {
  final int currentIndex;
  final Question currentQuestion;
  final int? selectedIndex;
  final bool? isCorrect;
  final int score;
  final int total;
  final int timeLeft;
  final bool isTimerRunning;

  QuizState({
    required this.currentIndex,
    required this.currentQuestion,
    this.selectedIndex,
    this.isCorrect,
    required this.score,
    required this.total,
    required this.timeLeft,
    required this.isTimerRunning,
  });

  factory QuizState.initial(List<Question> questions) => QuizState(
    currentIndex: 0,
    currentQuestion: questions[0],
    score: 0,
    total: questions.length,
    timeLeft: 15, // 15 seconds per question
    isTimerRunning: true,
  );

  QuizState copyWith({
    int? currentIndex,
    int? selectedIndex,
    bool? isCorrect,
    int? score,
    int? timeLeft,
    bool? isTimerRunning,
  }) {
    return QuizState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentQuestion: currentIndex != null ? questions[currentIndex] : this.currentQuestion,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      total: this.total,
      timeLeft: timeLeft ?? this.timeLeft,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
    );
  }
}

late List<Question> questions; // Set in notifier
Timer? _timer;

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(List<Question> qs)
      : super(QuizState.initial(qs)) {
    questions = qs;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0 && state.isTimerRunning) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else if (state.timeLeft <= 0 && state.isTimerRunning) {
        // Time's up! Auto-advance or mark as incorrect
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    // Stop timer and mark as incorrect if no answer selected
    if (state.selectedIndex == null) {
      state = state.copyWith(
        selectedIndex: -1, // Special value to indicate time's up
        isCorrect: false,
        isTimerRunning: false,
      );
    }
  }

  void selectAnswer(int index) {
    if (state.selectedIndex == null && state.isTimerRunning) {
      final bool correct = index == state.currentQuestion.answerIndex;
      state = state.copyWith(
        selectedIndex: index,
        isCorrect: correct,
        isTimerRunning: false, // Stop timer when answer is selected
      );
      _timer?.cancel();
    }
  }

  void nextQuestion() {
    int newScore = state.score;
    if (state.selectedIndex != null && state.selectedIndex! >= 0 && state.isCorrect == true) {
      newScore += 1;
    }
    final int nextIndex = state.currentIndex + 1;
    if (nextIndex >= questions.length) {
      // End of quiz, keep state as is for result computation
      state = state.copyWith(
        selectedIndex: null,
        isCorrect: null,
        score: newScore,
        isTimerRunning: false,
      );
      _timer?.cancel();
    } else {
      // Move to next question with a fresh state slice
      state = QuizState(
        currentIndex: nextIndex,
        currentQuestion: questions[nextIndex],
        selectedIndex: null,
        isCorrect: null,
        score: newScore,
        total: state.total,
        timeLeft: 15, // Reset timer for new question
        isTimerRunning: true,
      );
      _startTimer(); // Start timer for new question
    }
  }

  int getFinalScore() {
    int finalScore = state.score;
    if (state.selectedIndex != null && state.selectedIndex! >= 0 && state.isCorrect == true) {
      finalScore += 1;
    }
    return finalScore;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final quizProvider = StateNotifierProvider.autoDispose.family<QuizNotifier, QuizState, String>(
  (ref, category) {
    final questions = ref.watch(questionsProvider).value ?? [];
    final filtered = questions.where((q) => q.category == category).toList();
    return QuizNotifier(filtered.isNotEmpty ? filtered : questions);
  },
  dependencies: [questionsProvider],
);