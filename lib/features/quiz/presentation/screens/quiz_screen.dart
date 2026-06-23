import 'package:flutter/material.dart';
import '../../../levels/domain/entities/quiz_entity.dart';        // ✅ تعديل
import '../../../levels/domain/entities/question_entity.dart';    // ✅ تعديل
import '../../../../core/utils/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final QuizEntity quiz;
  final Color levelColor;

  const QuizScreen({
    Key? key,
    required this.quiz,
    required this.levelColor,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _correctAnswers = 0;
  bool _quizCompleted = false;

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildResultScreen();
    }

    final question = widget.quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: widget.levelColor,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${_currentQuestionIndex + 1} / ${widget.quiz.questions.length}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(widget.levelColor),
            minHeight: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(question),
                  const SizedBox(height: 24),
                  ...List.generate(
                    question.options.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildOptionCard(
                        index,
                        question.options[index],
                        question.correct,
                        _showExplanation,
                      ),
                    ),
                  ),
                  if (_showExplanation)
                    _buildExplanationCard(question),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomButton(question),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionEntity question) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'سؤال ${_currentQuestionIndex + 1}',
                style: TextStyle(
                  color: widget.levelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    int index,
    String text,
    int correct,
    bool showResult,
  ) {
    Color? borderColor;
    Color? backgroundColor;

    if (showResult) {
      if (index == correct) {
        borderColor = Colors.green;
        backgroundColor = Colors.green[50];
      } else if (index == _selectedAnswer && index != correct) {
        borderColor = Colors.red;
        backgroundColor = Colors.red[50];
      }
    } else if (_selectedAnswer == index) {
      borderColor = widget.levelColor;
      backgroundColor = widget.levelColor.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: showResult ? null : () => setState(() => _selectedAnswer = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? Colors.grey[300]!,
            width: borderColor != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _selectedAnswer == index
                    ? widget.levelColor
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: _selectedAnswer == index
                        ? Colors.white
                        : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: showResult && index == correct
                      ? Colors.green[700]
                      : Colors.grey[800],
                  fontWeight: showResult && index == correct
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (showResult && index == correct)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (showResult && index == _selectedAnswer && index != correct)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(QuestionEntity question) {
    final isCorrect = _selectedAnswer == question.correct;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'إجابة صحيحة!' : 'إجابة خاطئة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(QuestionEntity question) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedAnswer == null
                ? null
                : _showExplanation
                    ? _nextQuestion
                    : _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.levelColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _showExplanation
                  ? _currentQuestionIndex < widget.quiz.questions.length - 1
                      ? 'السؤال التالي →'
                      : 'عرض النتائج 🎯'
                  : 'تحقق من الإجابة',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    final question = widget.quiz.questions[_currentQuestionIndex];
    setState(() {
      _showExplanation = true;
      if (_selectedAnswer == question.correct) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      setState(() => _quizCompleted = true);
    }
  }

  Widget _buildResultScreen() {
    final percentage = (_correctAnswers / widget.quiz.questions.length * 100).round();
    final isPassed = percentage >= 60;
    final points = isPassed
        ? widget.quiz.questions.length * 10
        : widget.quiz.questions.length * 5;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isPassed ? Colors.green[50] : Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events : Icons.school,
                  size: 64,
                  color: isPassed ? Colors.amber : Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green : Colors.orange,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_correctAnswers / ${widget.quiz.questions.length} إجابات صحيحة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Text(
                isPassed
                    ? '🎉 ممتاز! لقد نجحت في الاختبار!'
                    : '💪 حاول مرة أخرى! أنت قادر على النجاح!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isPassed
                    ? 'لقد حصلت على $points نقطة إضافية!'
                    : 'حصلت على $points نقطة. حاول مرة أخرى للحصول على المزيد!',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (isPassed)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/certificate');
                  },
                  icon: const Icon(Icons.card_membership),
                  label: const Text('عرض الشهادة 🏆'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.levelColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = 0;
                      _selectedAnswer = null;
                      _showExplanation = false;
                      _correctAnswers = 0;
                      _quizCompleted = false;
                    });
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('إعادة الاختبار'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة للمستويات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}