part of '../../event.dart';

/// Subscribes the method that this is annotated with to the event type of the first parameter.
/// See [EventDispatcher.registerHandlers].
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
