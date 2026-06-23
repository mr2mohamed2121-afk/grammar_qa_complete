import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/leaderboard_model.dart';
import '../../services/leaderboard_service.dart';

// ==================== EVENTS ====================
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  final int limit;
  const LoadLeaderboard({this.limit = 50});
  @override
  List<Object?> get props => [limit];
}

class RefreshLeaderboard extends LeaderboardEvent {}

// ==================== STATES ====================
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();
  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final int? currentUserRank;

  const LeaderboardLoaded(this.entries, {this.currentUserRank});

  @override
  List<Object?> get props => [entries, currentUserRank];
}

class LeaderboardError extends LeaderboardState {
  final String message;
  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLoC ====================
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardService _service;

  LeaderboardBloc(this._service) : super(const LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoad);
    on<RefreshLeaderboard>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final rank = await _service.getCurrentUserRank();
      await emit.forEach<List<LeaderboardEntry>>(
        _service.getTopPlayers(limit: event.limit),
        onData: (entries) => LeaderboardLoaded(entries, currentUserRank: rank),
        onError: (error, stackTrace) => LeaderboardError(error.toString()),
      );
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (state is LeaderboardLoaded) {
      add(const LoadLeaderboard());
    }
  }
}