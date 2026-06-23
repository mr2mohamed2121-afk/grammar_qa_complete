import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/level_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../../../services/firestore_service.dart';

// ==================== Events ====================
abstract class LevelsEvent extends Equatable {
  const LevelsEvent();
  @override
  List<Object?> get props => [];
}

class LoadLevels extends LevelsEvent {
  final int userPoints;
  const LoadLevels({required this.userPoints});
  @override
  List<Object?> get props => [userPoints];
}

class UpdateLevelProgress extends LevelsEvent {
  final int levelId;
  final double progress;
  const UpdateLevelProgress({required this.levelId, required this.progress});
  @override
  List<Object?> get props => [levelId, progress];
}

// ==================== States ====================
abstract class LevelsState extends Equatable {
  const LevelsState();
  @override
  List<Object?> get props => [];
}

class LevelsInitial extends LevelsState {}

class LevelsLoading extends LevelsState {}

class LevelsLoaded extends LevelsState {
  final List<LevelEntity> levels;
  const LevelsLoaded({required this.levels});
  @override
  List<Object?> get props => [levels];
}

class LevelsError extends LevelsState {
  final String message;
  const LevelsError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ==================== BLoC ====================
class LevelsBloc extends Bloc<LevelsEvent, LevelsState> {
  final FirestoreService _firestoreService;

  LevelsBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(LevelsInitial()) {
    on<LoadLevels>(_onLoadLevels);
    on<UpdateLevelProgress>(_onUpdateProgress);
  }

  Future<void> _onLoadLevels(LoadLevels event, Emitter<LevelsState> emit) async {
    emit(LevelsLoading());
    
    try {
      final levelsData = await _firestoreService.getLevels();

      // ✅ Check: لو مفيش بيانات في Firestore
      if (levelsData.isEmpty) {
        emit(const LevelsLoaded(levels: []));
        return;
      }

      // ✅ معالجة ID صحيحة
      final levels = levelsData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        
        final isUnlocked = event.userPoints >= (data['required_points'] as int? ?? 0);
        
        return LevelEntity(
          // ✅ الحل: لو ID string (زي "level1")، استخدم index + 1
          id: data['id'] is int 
              ? data['id'] as int 
              : int.tryParse(data['id'].toString()) ?? (index + 1),
          title: data['title'] as String? ?? 'بدون عنوان',
          description: data['description'] as String? ?? '',
          requiredPoints: data['required_points'] as int? ?? 0,
          icon: data['icon'] as String? ?? '📚',
          color: data['color'] as String? ?? '#6B4EFF',
          lessons: [],
          quiz: QuizEntity(id: '', title: '', questions: []),
          isUnlocked: isUnlocked,
          progress: 0.0,
        );
      }).toList();
      
      emit(LevelsLoaded(levels: levels));
      
    } catch (e) {
      emit(LevelsError(message: 'فشل في تحميل المستويات: $e'));
    }
  }

  Future<void> _onUpdateProgress(
    UpdateLevelProgress event,
    Emitter<LevelsState> emit,
  ) async {
    if (state is LevelsLoaded) {
      final currentLevels = (state as LevelsLoaded).levels;
      final updatedLevels = currentLevels.map((level) {
        if (level.id == event.levelId) {
          return level.copyWith(progress: event.progress);
        }
        return level;
      }).toList();
      emit(LevelsLoaded(levels: updatedLevels));
    }
  }
}