
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  final List<StreamSubscription> _subscriptions = [];

  BaseBloc(super.initialState);

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  @override
  Future<void> close() async {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    return super.close();
  }
}

// Extension for safe stream listening
extension SafeStreamExtension<T> on Stream<T> {
  StreamSubscription<T> listenSafe(
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    required List<StreamSubscription> subscriptions,
  }) {
    final subscription = listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    subscriptions.add(subscription);
    return subscription;
  }
}
