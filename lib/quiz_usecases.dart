
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/question_entity.dart';
import '../entities/quiz_result_entity.dart';
import '../repositories/quiz_repository_interface.dart';

@injectable
class GetQuestionsUseCase implements UseCase<List<QuestionEntity>, GetQuestionsParams> {
  final QuizRepositoryInterface _repository;
  GetQuestionsUseCase(this._repository);

  @override
  Future<Either<Failure, List<QuestionEntity>>> call(GetQuestionsParams params) async {
    return await _repository.getQuestions(
      category: params.category,
      difficulty: params.difficulty,
      limit: params.limit,
    );
  }
}

class GetQuestionsParams extends Equatable {
  final String? category;
  final DifficultyLevel? difficulty;
  final int limit;

  const GetQuestionsParams({this.category, this.difficulty, this.limit = 50});

  @override
  List<Object?> get props => [category, difficulty, limit];
}

@injectable
class SubmitQuizUseCase implements UseCase<void, SubmitQuizParams> {
  final QuizRepositoryInterface _repository;
  SubmitQuizUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SubmitQuizParams params) async {
    return await _repository.saveQuizResult(params.result);
  }
}

class SubmitQuizParams extends Equatable {
  final QuizResultEntity result;
  const SubmitQuizParams({required this.result});

  @override
  List<Object?> get props => [result];
}

@injectable
class GetQuizHistoryUseCase implements UseCase<List<QuizResultEntity>, GetQuizHistoryParams> {
  final QuizRepositoryInterface _repository;
  GetQuizHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<QuizResultEntity>>> call(GetQuizHistoryParams params) async {
    return await _repository.getUserQuizResults(params.userId, limit: params.limit);
  }
}

class GetQuizHistoryParams extends Equatable {
  final String userId;
  final int limit;
  const GetQuizHistoryParams({required this.userId, this.limit = 50});

  @override
  List<Object?> get props => [userId, limit];
}
