part of '../../client.dart';

/// Base Class for IRC Events
abstract class Event {
  /// Client associated with the Event
  Client client;

  bool isBatched = false;
  String batchId;

  Event(this.client, {required this.batchId});

  get capabilities => null;
}

/// Connect Event is dispatched when the client connects to the server
class ConnectEvent extends Event {
  ConnectEvent(super.client) : super(batchId: '');
}

class BatchStartEvent extends Event {
  String id;
  String get type => body.parameters[1];
  Message body;

  BatchStartEvent(super.client, this.id, this.body) : super(batchId: id);

  Future<BatchEndEvent> waitForEnd() {
    return client.onEvent<BatchEndEvent>().where((it) => it.id == id).first;
  }
}

class BatchEndEvent extends Event {
  String id;
  List<Message> messages;
  List<Event> events;

  BatchEndEvent(super.client, this.id, this.messages, this.events)
      : super(batchId: id);
}

class MessageSentEvent extends Event {
  String message;
  String target;

  MessageSentEvent(super.client, this.message, this.target)
      : super(batchId: '');
}

class NetSplitEvent extends Event {
  String hub;
  String host;
  List<QuitEvent> quits;

  NetSplitEvent(super.client, this.hub, this.host, this.quits)
      : super(batchId: '');
}

class NetJoinEvent extends Event {
  String hub;
  String host;
  List<JoinEvent> joins;

  NetJoinEvent(super.client, this.hub, this.host, this.joins)
      : super(batchId: '');
}

class QuitPartEvent extends Event {
  final Channel channel;
  final String user;

  QuitPartEvent(super.client, this.channel, this.user) : super(batchId: '');
}

/// Ready Event is dispatched when the client is ready to join channels
class ReadyEvent extends Event {
  ReadyEvent(super.client) : super(batchId: '');

  /// Joins the specified [channel].
  void join(String channel) {
    client.join(channel);
  }
}

class IsOnEvent extends Event {
  final List<String> users;

  IsOnEvent(super.client, this.users) : super(batchId: '');
}

class ServerOperatorEvent extends Event {
  ServerOperatorEvent(super.client) : super(batchId: '');
}

class ServerTlsEvent extends Event {
  ServerTlsEvent(super.client) : super(batchId: '');
}

class ServerVersionEvent extends Event {
  final String version;
  final String server;
  final String comments;

  ServerVersionEvent(super.client, this.server, this.version, this.comments)
      : super(batchId: '');
}

/// Line Receive Event is dispatched when a line is received from the server
class LineReceiveEvent extends Event {
  /// Line from the Server
  String line;

  late Message _message;

  Message get message => _message;

  LineReceiveEvent(super.client, this.line) : super(batchId: '') {
    _message = client.parser.convert(line);
  }
}

class UserOnlineEvent extends Event {
  String user;

  UserOnlineEvent(super.client, this.user) : super(batchId: '');
}

class UserOfflineEvent extends Event {
  String user;

  UserOfflineEvent(super.client, this.user) : super(batchId: '');
}

class MonitorListEvent extends Event {
  List<String> users;

  MonitorListEvent(super.client, this.users) : super(batchId: '');
}

class ChangeHostEvent extends Event {
  String host;
  String user;
  String username;

  ChangeHostEvent(super.client, this.user, this.username, this.host)
      : super(batchId: '');
}

/// Message Event is dispatched when a message is received from the server (includes private messages)
class MessageEvent extends Event {
  /// Who sent the message
  Entity from;

  /// Where the message was sent to
  Entity target;

  /// The message that was received
  String message;

  /// Message Intent
  String intent;

  MessageEvent(super.client, this.from, this.target, this.message,
      {required this.intent, required String batchId})
      : super(batchId: '');

  /// Replies to the Event
  void reply(String message) {
    if (target.isUser) {
      client.sendMessage(from.name, message);
    } else if (target.isChannel) {
      client.sendMessage(target.name, message);
    } else {
      // Ignore server replies.
    }
  }

  /// If this event is a private message
  bool get isPrivate => target.isUser;

  Channel? get channel => target.isChannel ? target as Channel : null;
}

/// Notice Event is dispatched when a notice is received
class NoticeEvent extends MessageEvent {
  /// Returns whether the notice is from the system or not.
  bool get isSystem => from.isServer;

  bool get isServer => isSystem;

  NoticeEvent(super.client, super.from, super.target, super.message,
      {required super.intent})
      : super(batchId: '');

  bool get isChannel => target.isChannel;

  /// Sends [message] to [target] as a notice.
  @override
  void reply(String message) {
    if (!from.isServer) {
      client.sendNotice(from.name, message);
    }
  }
}

/// Join Event is dispatched when another user joins a channel we are in
class JoinEvent extends Event {
  /// Channel they joined
  Channel channel;

  /// User who joined
  String user;

  String username;
  String realname;

  bool get isExtended => realname.isNotEmpty;
  bool get isRegistered => username != '*';

  JoinEvent(super.client, this.user, this.channel,
      {required this.username, required this.realname})
      : super(batchId: '');

  /// Replies to this Event by sending [message] to the channel
  void reply(String message) => channel.sendMessage(message);
}

/// Nick In Use Event is dispatched when a nickname is in use when trying to switch usernames
class NickInUseEvent extends Event {
  /// Original Nickname
  String original;

  NickInUseEvent(super.client, this.original) : super(batchId: '');
}

/// Fired when the Client joins a Channel.
class ClientJoinEvent extends Event {
  /// Channel we joined
  Channel channel;

  ClientJoinEvent(super.client, this.channel) : super(batchId: '');
}

/// Part Event is dispatched when a user parts a channel that the Client is in
class PartEvent extends Event {
  /// Channel that the user left
  Channel channel;

  /// The user that left
  String user;

  PartEvent(super.client, this.user, this.channel) : super(batchId: '');

  /// Replies to the Event by sending [message] to the channel the user left
  void reply(String message) => channel.sendMessage(message);
}

/// Fired when the Client parts a channel
class ClientPartEvent extends Event {
  /// Channel we left
  Channel channel;

  ClientPartEvent(super.client, this.channel) : super(batchId: '');
}

/// Quit Event is dispatched when a user quits the server
class QuitEvent extends Event {
  /// User who quit
  String user;

  QuitEvent(super.client, this.user) : super(batchId: '');
}

/// Disconnect Event is dispatched when we disconnect from the server
class DisconnectEvent extends Event {
  DisconnectEvent(super.client) : super(batchId: '');
}

/// Error Event is dispatched when there is any error in the Client or Server
class ErrorEvent extends Event {
  /// Error Message
  String message;

  /// Error Object (possibly null)
  Error err;

  /// Type of Error
  String type;

  ErrorEvent(super.client,
      {required this.message, required this.err, this.type = 'unspecified'})
      : super(batchId: '');
}

/// Mode Event is dispatched when we are notified of a mode change
class ModeEvent extends Event {
  /// Channel we received the change from (possibly null)
  Channel? channel;

  /// Mode that was changed
  ModeChange mode;

  /// User the mode was changed on
  String user;

  bool get isClient => user == client.nickname;
  bool get hasChannel => channel != null;
  bool get isChannel => hasChannel && user.isNotEmpty;

  ModeEvent(super.client, this.mode, this.user, [this.channel])
      : super(batchId: '');
}

/// Line Sent Event is dispatched when the Client sends a line to the server
class LineSentEvent extends Event {
  /// Line that was sent
  String line;

  late final Message _message = client.parser.convert(line);

  Message get message => _message;

  LineSentEvent(super.client, this.line) : super(batchId: '');
}

/// Topic Event is dispatched when the topic changes or is received in a channel
class TopicEvent extends Event {
  /// Channel we received the event from
  Channel channel;

  /// The Topic
  String topic;

  /// The old Topic.
  String oldTopic;

  /// The User
  User user;

  bool isChange;

  TopicEvent(super.client, this.channel, this.user, this.topic, this.oldTopic,
      [this.isChange = false])
      : super(batchId: '');

  void revert() {
    channel.topic = oldTopic;
  }
}

class ServerCapabilitiesEvent extends Event {
  @override
  Set<String> capabilities;

  ServerCapabilitiesEvent(super.client, this.capabilities) : super(batchId: '');
}

class AcknowledgedCapabilitiesEvent extends Event {
  @override
  Set<String> capabilities;

  AcknowledgedCapabilitiesEvent(super.client, this.capabilities)
      : super(batchId: '');
}

class NotAcknowledgedCapabilitiesEvent extends Event {
  @override
  Set<String> capabilities;

  NotAcknowledgedCapabilitiesEvent(super.client, this.capabilities)
      : super(batchId: '');
}

class AwayEvent extends Event {
  User user;
  String? message;
  bool get isAway => message != null;
  bool get isBack => message == null;

  AwayEvent(super.client, this.user, this.message) : super(batchId: '');
}

class CurrentCapabilitiesEvent extends Event {
  @override
  Set<String> capabilities;

  CurrentCapabilitiesEvent(super.client, this.capabilities)
      : super(batchId: '');
}

class WhowasEvent extends Event {
  final String nickname;
  final String user;
  final String host;
  final String realname;

  WhowasEvent(super.client, this.nickname, this.user, this.host, this.realname)
      : super(batchId: '');
}

/// Nick Change Event is dispatched when a nickname changes (possibly the Client's nickname)
class NickChangeEvent extends Event {
  /// User object
  User user;

  /// Original Nickname
  String original;

  /// New Nickname
  String now;

  NickChangeEvent(super.client, this.user, this.original, this.now)
      : super(batchId: '');
}

class UserLoggedInEvent extends Event {
  /// User that logged in.
  User user;

  /// Account name for the user.
  String account;

  UserLoggedInEvent(super.client, this.user, this.account) : super(batchId: '');
}

class UserLoggedOutEvent extends Event {
  User user;

  UserLoggedOutEvent(super.client, this.user) : super(batchId: '');
}

/// Whois Event is dispatched when a WHOIS query is completed
class WhoisEvent extends Event {
  WhoisBuilder builder;

  WhoisEvent(super.client, this.builder) : super(batchId: '');

  /// The Channels the user is a member in
  List<String> get memberChannels {
    var list = <String>[];
    list.addAll(builder.channels.where((i) =>
        !operatorChannels.contains(i) &&
        !voicedChannels.contains(i) &&
        !ownerChannels.contains(i) &&
        !halfOpChannels.contains(i)));
    return list;
  }

  /// The Channels the user is an operator in
  List<String> get operatorChannels => builder.opIn;

  /// The Channels the user is a voice in
  List<String> get voicedChannels => builder.voiceIn;

  List<String> get ownerChannels => builder.ownerIn;
  List<String> get halfOpChannels => builder.halfOpIn;

  /// If the user is away
  bool get away => builder.away;

  /// If the user is away
  bool get isAway => away;

  /// If the user is away, then this is the message that was set
  String get awayMessage => builder.awayMessage;

  /// If this user is a server operator
  bool get isServerOperator => builder.isServerOperator;

  /// The name of the server this user is on
  String get serverName => builder.serverName;

  bool get secure => builder.secure;

  /// The Server Information (message) for the server this user is on
  String get serverInfo => builder.serverInfo;

  /// The User's Username
  String get username => builder.username;

  /// The User's Hostname
  String get hostname => builder.hostname;

  /// If the user is idle
  bool get idle => builder.idle;

  /// If the user is idle, then this is the amount of time that the user has been idle
  int get idleTime => builder.idleTime;

  /// The User's Real Name
  String get realname => builder.realName;

  /// The User's Nickname
  String get nickname => builder.nickname;

  @override
  String toString() => builder.toString();
}

class PongEvent extends Event {
  /// Message in the PONG
  String message;

  PongEvent(super.client, this.message) : super(batchId: '');
}

/// An Action Event
class ActionEvent extends MessageEvent {
  ActionEvent(super.client, User super.from, super.target, super.message,
      {required super.intent})
      : super(batchId: '');

  /// Sends [message] to [target] as a action.
  @override
  void reply(String message) => client.sendAction(from.name, message);
}

/// A Kick Event
class KickEvent extends Event {
  /// The Channel where the event is from
  Channel channel;

  /// The User who was kicked
  User user;

  /// The User who kicked the other user
  User by;

  /// The Reason Given for [by] kicking [user]
  String reason;

  KickEvent(super.client, this.channel, this.user, this.by, [this.reason = ''])
      : super(batchId: '');
}

/// A Client to Client Protocol Event.
/// ActionEvent is executed on this event as well.
class CTCPEvent extends Event {
  /// The User who sent the message
  User user;

  /// The Target of the message
  Entity target;

  /// The Message sent
  String message;

  CTCPEvent(super.client, this.user, this.target, this.message)
      : super(batchId: '');
}

/// Server MOTD Recieved
class MOTDEvent extends Event {
  /// MOTD Message
  String message;

  MOTDEvent(super.client, this.message) : super(batchId: '');
}

/// Server ISUPPORT Event
class ServerSupportsEvent extends Event {
  /// Supported Stuff
  Map<String, dynamic> supported = {};

  ServerSupportsEvent(super.client, String message) : super(batchId: '') {
    var split = message.split(' ');
    split.forEach((it) {
      if (it.contains('=')) {
        var keyValue = it.split('=');
        var key = keyValue[0];

        dynamic value = keyValue[1];
        var numeric = num.tryParse(value);
        if (numeric != null) {
          value = numeric;
        }
        supported[key] = value;
      } else {
        supported[it] = true;
      }
    });
  }
}

/// Invite Event
class InviteEvent extends Event {
  /// The Channel that the client was invited to
  String channel;

  /// The user who invited the client
  String user;

  InviteEvent(super.client, this.channel, this.user) : super(batchId: '');

  /// Joins the Channel
  void join() => client.join(channel);

  /// Sends a Message to the User
  void reply(String message) => client.sendMessage(user, message);
}

class UserInvitedEvent extends Event {
  /// The Channel that this invite was issued for.
  Channel channel;

  /// The user who was invited.
  String user;

  /// The user who invited.
  User inviter;

  UserInvitedEvent(super.client, this.channel, this.user, this.inviter)
      : super(batchId: '');
}
