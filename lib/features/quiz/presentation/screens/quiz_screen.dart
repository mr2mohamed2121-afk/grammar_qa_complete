import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../bloc/quiz_bloc.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<QuizBloc>()..add(const LoadQuestions(limit: 5)),
      child: const _QuizScreenContent(),
    );
  }
}

class _QuizScreenContent extends StatelessWidget {
  const _QuizScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
  title: const Text(
    'اختبار النحو',
    style: TextStyle(color: Colors.white),
  ),
  centerTitle: true,
  backgroundColor: const Color(0xFF2E7D32), // أخضر فاتح
  iconTheme: const IconThemeData(color: Colors.white),
),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
            print('📊 QuizState: ${state.runtimeType}');
          if (state is QuizError) {
            print('❌ Quiz Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
            print('🏗️ Building: ${state.runtimeType}');
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizLoaded) {
            return _buildQuizContent(context, state);
          }

          if (state is QuizCompleted) {
            return _buildResults(context, state);
          }

          return const Center(child: Text('اضغط لبدء الاختبار'));
        },
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizLoaded state) {
    final question = state.questions[state.currentQuestionIndex];
    final progress = (state.currentQuestionIndex + 1) / state.questions.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          Text(
            'السؤال ${state.currentQuestionIndex + 1} من ${state.questions.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Question
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final isSelected = state.answers[state.currentQuestionIndex] == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<QuizBloc>().add(
                        AnswerQuestion(
                          questionIndex: state.currentQuestionIndex,
                          selectedAnswer: index,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.white,
                      foregroundColor: isSelected
                          ? Colors.white
                          : const Color(0xFF1E3A5F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: Text(
                      question.options[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!state.isFirstQuestion)
                ElevatedButton.icon(
                  onPressed: () {
                    // Previous question logic
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('السابق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                )
              else
                const SizedBox(),

              if (state.isLastQuestion)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<QuizBloc>().add(const SubmitQuiz());
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('إنهاء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: state.hasAnsweredCurrent
                      ? () {
                          // Move to next
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('التالي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, QuizCompleted state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.percentage >= 70 ? Icons.emoji_events : Icons.school,
              size: 80,
              color: state.percentage >= 70 ? Colors.amber : const Color(0xFF1E3A5F),
            ),
            const SizedBox(height: 24),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${state.score} / ${state.totalQuestions}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            Text(
              '${state.percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<QuizBloc>().add(const ResetQuiz());
                context.read<QuizBloc>().add(const LoadQuestions(limit: 5));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('اختبار جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}