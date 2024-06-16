part of '../../client.dart';

/// An abstract class that represents something that sends/receives messages.
abstract class Entity {
  /// Name of the entity.
  String get name;

  /// Is Channel
  bool get isChannel => this is Channel;

  /// Is User
  bool get isUser => this is User;

  /// Is Server
  bool get isServer => this is Server;

  Set<User>? get members => null;

  Set<User>? get ops => null;

  Set<User>? get voices => null;

  Set<User>? get owners => null;

  Set<User>? get halfops => null;

  Set<User>? get allUsers => null;
}
