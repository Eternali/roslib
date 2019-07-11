// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

// ignore: uri_does_not_exist
// ignore: unused_import
import 'ros_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'ros_html.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'ros_io.dart';

import 'request.dart';

/// Status enums.
enum Status { NONE, CONNECTING, CONNECTED, CLOSED, ERRORED }
enum TopicStatus { SUBSCRIBED, UNSUBSCRIBED, PUBLISHER, ADVERTISED, UNADVERTISED }

/// The class through which all data to and from a ROS node goes through.
/// Manages status and key information about the connection and node.
class Ros {
  /// Initializes the [_statusController] as a broadcast.
  /// The [url] of the ROS node can be optionally specified at this point.
  Ros({this.url}) {
    _statusController = StreamController<Status>.broadcast();
  }

  /// The url of ROS node running the rosbridge server.
  dynamic url;

  /// Total subscribers to ever connect.
  int subscribers = 0;

  /// Total number of advertisers to ever connect.
  int advertisers = 0;

  /// Total number of publishers to ever connect.
  int publishers = 0;

  /// Total number of callers to ever call a service.
  int serviceCallers = 0;

  /// The sum to generate IDs with.
  int get ids => subscribers + advertisers + publishers + serviceCallers;

  /// The websocket connection to communicate with the ROS node.
  WebSocketChannel _channel;

  /// Subscription to the websocket stream.
  StreamSubscription _channelListener;

  /// JSON broadcast websocket stream.
  Stream stream;

  /// The controller to update subscribers on the state of the connection.
  StreamController<Status> _statusController;

  /// Subscribable stream to listen for connection status changes.
  Stream<Status> get statusStream => _statusController?.stream;

  /// Status variable that can be used when not interested in getting live updates.
  Status status = Status.NONE;

  /// Connect to the ROS node, the [url] can override what was provided in the constructor.
  void connect({dynamic url}) {
    this.url = url ?? this.url;
    url ??= this.url;
    try {
      // Initialize the connection to the ROS node with a Websocket channel.
      _channel = initializeWebSocketChannel(url);
      stream = _channel.stream.asBroadcastStream().map((raw) => json.decode(raw));
      // Update the connection status.
      status = Status.CONNECTED;
      _statusController.add(status);
      // Listen for messages on the connection to update the status.
      _channelListener = stream.listen((data) {
        print('INCOMING: $data');
        if (status != Status.CONNECTED) {
          status = Status.CONNECTED;
          _statusController.add(status);
        }
      }, onError: (error) {
        status = Status.ERRORED;
        _statusController.add(status);
      }, onDone: () {
        status = Status.CLOSED;
        _statusController.add(status);
      });
    } on WebSocketChannelException catch (e) {
      status = Status.ERRORED;
      _statusController.add(status);
    }
  }

  /// Close the connection to the ROS node, an exit [code] and [reason] can
  /// be optionally specified.
  Future<void> close([int code, String reason]) async {
    /// Close listener and websocket.
    await _channelListener?.cancel();
    await _channel?.sink?.close(code, reason);

    /// Update the connection status.
    _statusController.add(Status.CLOSED);
    status = Status.CLOSED;
  }

  /// Send a [message] to the ROS node
  bool send(dynamic message) {
    // If we're not connected give up.
    if (status != Status.CONNECTED) return false;
    // Format the message into JSON and then stringify.
    final toSend = (message is Request)
        ? json.encode(message.toJson())
        : (message is Map || message is List) ? json.encode(message) : message;
    print('OUTGOING: $toSend');
    // Actually send it to the node.
    _channel.sink.add(toSend);
    return true;
  }

  void authenticate({
    String mac,
    String client,
    String dest,
    String rand,
    DateTime t,
    String level,
    DateTime end,
  }) async {
    send({
      'mac': mac,
      'client': client,
      'dest': dest,
      'rand': rand,
      't': t.millisecondsSinceEpoch,
      'level': level,
      'end': end.millisecondsSinceEpoch,
    });
  }

  /// Sends a set_level request to the server.
  /// [level] can be one of {none, error, warning, info}, and
  /// [id] is the optional operation ID to change status level on
  void setStatusLevel({String level, int id}) {
    send({
      'op': 'set_level',
      'level': level,
      'id': id,
    });
  }

  /// Request a subscription ID.
  String requestSubscriber(String name) {
    subscribers++;
    return 'subscribe:' + name + ':' + ids.toString();
  }

  /// Request an advertiser ID.
  String requestAdvertiser(String name) {
    advertisers++;
    return 'advertise:' + name + ':' + ids.toString();
  }

  /// Request a publisher ID.
  String requestPublisher(String name) {
    publishers++;
    return 'publish:' + name + ':' + ids.toString();
  }

  /// Request a service caller ID.
  String requestServiceCaller(String name) {
    serviceCallers++;
    return 'call_service:' + name + ':' + ids.toString();
  }

  bool operator ==(other) {
    return other.hashCode == hashCode;
  }

  @override
  int get hashCode =>
      url.hashCode +
      subscribers.hashCode +
      advertisers.hashCode +
      publishers.hashCode +
      _channel.hashCode +
      _channelListener.hashCode +
      stream.hashCode +
      _statusController.hashCode +
      status.hashCode;
}
