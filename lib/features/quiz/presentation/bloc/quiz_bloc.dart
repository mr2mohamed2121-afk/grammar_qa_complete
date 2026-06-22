import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../questions/models/question_model.dart';
import '../../../../services/firestore_service.dart';
import '../../models/quiz_result_model.dart';
import '../../../../injection.dart';
import '../../../leaderboard/services/leaderboard_service.dart';

// ==================== EVENTS ====================
abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

class LoadQuestions extends QuizEvent {
  final String? category;
  final String? difficulty;
  final int? limit;

  const LoadQuestions({this.category, this.difficulty, this.limit});

  @override
  List<Object?> get props => [category, difficulty, limit];
}

class AnswerQuestion extends QuizEvent {
  final int questionIndex;
  final int selectedAnswer;

  const AnswerQuestion({required this.questionIndex, required this.selectedAnswer});

  @override
  List<Object?> get props => [questionIndex, selectedAnswer];
}

class GoToQuestion extends QuizEvent {
  final int questionIndex;
  const GoToQuestion(this.questionIndex);

  @override
  List<Object?> get props => [questionIndex];
}

class SubmitQuiz extends QuizEvent {
  const SubmitQuiz();
}

class ResetQuiz extends QuizEvent {
  const ResetQuiz();
}

// ==================== STATES ====================
abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<QuestionModel> questions;
  final Map<int, int> answers;
  final int currentQuestionIndex;

  const QuizLoaded({
    required this.questions,
    required this.answers,
    this.currentQuestionIndex = 0,
  });

  int get score {
    int total = 0;
    answers.forEach((index, answer) {
      if (index < questions.length && questions[index].correctAnswer == answer) {
        total++;
      }
    });
    return total;
  }

  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get hasAnsweredCurrent => answers.containsKey(currentQuestionIndex);

  QuizLoaded copyWith({
    List<QuestionModel>? questions,
    Map<int, int>? answers,
    int? currentQuestionIndex,
  }) {
    return QuizLoaded(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }

  @override
  List<Object?> get props => [questions, answers, currentQuestionIndex];
}

class QuizCompleted extends QuizState {
  final int score;
  final int totalQuestions;
  final double percentage;
  final String message;

  const QuizCompleted({
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.message,
  });

  @override
  List<Object?> get props => [score, totalQuestions, percentage, message];
}

class QuizError extends QuizState {
  final String message;
  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLoC ====================
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final FirestoreService _firestoreService;

  QuizBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(QuizInitial()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<GoToQuestion>(_onGoToQuestion);
    on<SubmitQuiz>(_onSubmitQuiz);
    on<ResetQuiz>(_onResetQuiz);
  }

  Future<void> _onLoadQuestions(
    LoadQuestions event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final questions = await _firestoreService.getQuestions(
       // category: event.category,
       // difficulty: event.difficulty,
        limit: event.limit ?? 5,
      );
      emit(QuizLoaded(questions: questions, answers: const {}));
    } catch (e) {
      emit(QuizError('فشل تحميل الأسئلة: $e'));
    }
  }

  void _onAnswerQuestion(
    AnswerQuestion event,
    Emitter<QuizState> emit,
  ) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final newAnswers = Map<int, int>.from(currentState.answers);
      newAnswers[event.questionIndex] = event.selectedAnswer;

      if (currentState.isLastQuestion) {
        emit(currentState.copyWith(answers: newAnswers));
      } else {
        emit(currentState.copyWith(
          answers: newAnswers,
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
        ));
      }
    }
  }

  void _onGoToQuestion(
    GoToQuestion event,
    Emitter<QuizState> emit,
  ) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (event.questionIndex >= 0 && 
          event.questionIndex < currentState.questions.length) {
        emit(currentState.copyWith(
          currentQuestionIndex: event.questionIndex,
        ));
      }
    }
  }

  Future<void> _onSubmitQuiz(
    SubmitQuiz event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final score = currentState.score;
      final total = currentState.questions.length;
      final percentage = total > 0 ? (score / total) * 100 : 0;

      String message;
      if (percentage >= 90) {
        message = '🎉 ممتاز! أداء رائع!';
      } else if (percentage >= 70) {
        message = '👏 جيد جداً! استمر!';
      } else if (percentage >= 50) {
        message = '💪 مقبول، تحتاج لمزيد من التدريب';
      } else {
        message = '📚 استمر في التعلم، ستتحسن!';
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final result = QuizResultModel(
            userId: user.uid,
            userEmail: user.email ?? '',
            score: score,
            totalQuestions: total,
            category: currentState.questions.isNotEmpty 
                ? currentState.questions.first.category 
                : 'عام',
            completedAt: DateTime.now(),
          );

          await _firestoreService.saveQuizResult(result);
          await _firestoreService.updateLeaderboard(
            user.uid,
            user.displayName ?? user.email ?? 'User',
            score,
          );
          await _firestoreService.updateUserScore(user.uid, score);

          try {
            final leaderboardService = getIt<LeaderboardService>();
            await leaderboardService.updateUserScore(score, total);
          } catch (e) {
            print('Leaderboard update error: $e');
          }
        }
      } catch (e) {
        print('Error saving quiz result: $e');
      }

      emit(QuizCompleted(
        score: score,
        totalQuestions: total,
        percentage: percentage.toDouble(),
        message: message,
      ));
    }
  }

  void _onResetQuiz(
    ResetQuiz event,
    Emitter<QuizState> emit,
  ) {
    emit(QuizInitial());
  }
}