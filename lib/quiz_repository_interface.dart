
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/question_entity.dart';
import '../entities/quiz_result_entity.dart';

abstract class QuizRepositoryInterface {
  Future<Either<Failure, List<QuestionEntity>>> getQuestions({
    String? category,
    DifficultyLevel? difficulty,
    int limit = 50,
  });
  Future<Either<Failure, QuestionEntity?>> getQuestion(String questionId);
  Future<Either<Failure, void>> saveQuizResult(QuizResultEntity result);
  Future<Either<Failure, List<QuizResultEntity>>> getUserQuizResults(String userId, {int limit = 50});
  Future<Either<Failure, List<Map<String, dynamic>>>> getCategories();
}
