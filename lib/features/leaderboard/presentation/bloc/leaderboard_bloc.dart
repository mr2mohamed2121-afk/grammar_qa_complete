import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/leaderboard_model.dart';
import '../../services/leaderboard_service.dart';

// Events
abstract class LeaderboardEvent {}

class LoadLeaderboard extends LeaderboardEvent {}

class RefreshLeaderboard extends LeaderboardEvent {}

// States
abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final int? currentUserRank;

  LeaderboardLoaded(this.entries, {this.currentUserRank});
}

class LeaderboardError extends LeaderboardState {
  final String message;
  LeaderboardError(this.message);
}

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardService _service;

  LeaderboardBloc(this._service) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoad);
    on<RefreshLeaderboard>(_onLoad);
  }

  Future<void> _onLoad(
    LeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final rank = await _service.getCurrentUserRank();
      await emit.forEach(
        _service.getTopPlayers(),
        onData: (List<LeaderboardEntry> entries) =>
            LeaderboardLoaded(entries, currentUserRank: rank),
        onError: (error, stackTrace) => LeaderboardError(error.toString()),
      );
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}