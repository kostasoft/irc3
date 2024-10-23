part of '../../event.dart';

class Subscribe<T> {
  final int priority;
  final EventFilter<T> filter;
  final EventFilter<T> when;
  final bool always;

  const Subscribe(
      {required this.priority,
      required this.filter,
      required this.when,
      this.always = false});
}
