import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

enum Status { NONE, CONNECTING, CONNECTED, CLOSED, ERRORED }
enum TopicStatus { SUBSCRIBED, UNSUBSCRIBED, PUBLISHER, ADVERTISED, UNADVERTISED }

class Ros {

  dynamic url;

  int subscribers = 0;
  
  int advertisers = 0;

  int publishers = 0;

  int serviceCallers = 0;

  int get ids => subscribers + advertisers + publishers + serviceCallers;

  IOWebSocketChannel _channel;

  StreamSubscription _channelListener;

  Stream stream;

  StreamController<Status> _statusController;

  Stream<Status> get statusStream => _statusController?.stream;

  Status status = Status.NONE;

  Ros({ this.url }) {
    _statusController = StreamController<Status>.broadcast();
  }

  void connect({ dynamic url }) {
    url ??= this.url;
    _channel = IOWebSocketChannel.connect(url);
    stream = _channel.stream.asBroadcastStream().map((raw) => json.decode(raw));
    _statusController.add(Status.CONNECTED);
    status = Status.CONNECTED;
    _channelListener = stream.listen(
      (data) {
        print('INCOMING: $data');
        if (status != Status.CONNECTED) {
          _statusController.add(Status.CONNECTED);
          status = Status.CONNECTED;
        }
      },
      onError: (error) {
        _statusController.add(Status.ERRORED);
        status = Status.ERRORED;
      },
      onDone: () {
        _statusController.add(Status.CLOSED);
        status = Status.CLOSED;
      }
    );
  }

  Future<void> close([ int code, String reason ]) async {
    _statusController.add(Status.CLOSED);
    status = Status.CLOSED;
    await _channelListener.cancel();
    await _channel.sink.close(code, reason);
  }

  bool send(dynamic message) {
    if (status != Status.CONNECTED) return false;
    final toSend = (message is Map || message is List) ? json.encode(message) : message;
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
  void setStatusLevel({ String level, int id }) {
    send({
      'op': 'set_level',
      'level': level,
      'id': id,
    });
  }

  String requestSubscriber(String name) {
    return 'subscribe:' + name + ':' + (++subscribers).toString();
  }

  String requestAdvertiser(String name) {
    return 'advertise:' + name + ':' + (++advertisers).toString();
  }

  String requestPublisher(String name) {
    return 'publish:' + name + ':' + (++publishers).toString();
  }

  String requestServiceCaller(String name) {
    return 'call_service:' + name + ':' + (++serviceCallers).toString();
  }

  @override
  int get hashCode => url.hashCode +
    subscribers.hashCode +
    advertisers.hashCode +
    publishers.hashCode +
    _channel.hashCode +
    _channelListener.hashCode +
    stream.hashCode +
    _statusController.hashCode +
    status.hashCode;

}
