import 'dart:async';
import 'ros.dart';
import 'request.dart';

typedef ServiceHandler = Future Function(dynamic request);

class Service {

  Ros ros;

  String name;

  String type;

  Stream _advertiser;

  bool get isAdvertised => _advertiser != null;

  Service({
    this.ros,
    this.name,
    this.type,
  });

  Future call(dynamic req) {
    if (isAdvertised) return Future.value(false);
    final callId = ros.requestServiceCaller(name);
    final receiver = ros.stream.where((message) {
      print(message.toString());
      return message['id'] == callId; }).map((message) =>
      message['result'] == null ? Future.error(message['values']) : Future.value(message['values'])
    );
    final completer = Completer();
    StreamSubscription listener;
    listener = receiver.listen((d) {
      listener.cancel();
      completer.complete(d);
    });
    ros.send(Request(
      op: 'call_service',
      id: callId,
      service: name,
      type: type,
      args: req,
    ));
    return completer.future;
  }

  Future<void> advertise(ServiceHandler handler) async {
    if (isAdvertised) return;
    ros.send(Request(
      op: 'advertise_service',
      type: type,
      service: name,
    ));
    _advertiser = ros.stream
      .where((message) => message['service'] == name)
      .asyncMap((req) => handler(req['args']).then((resp) {
        ros.send(Request(
          op: 'service_response',
          id: req.id,
          service: name,
          values: resp ?? {},
          result: resp != null,
        ));
      }));
  }

  void unadvertise() {
    if (!isAdvertised) return;
    ros.send(Request(
      op: 'unadvertise_service',
      service: name,
    ));
    _advertiser = null;
  }


}
