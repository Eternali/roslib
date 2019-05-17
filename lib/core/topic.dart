import 'dart:async';
import 'ros.dart';
import 'request.dart';

class Topic {

  Ros ros;

  Stream subscription;

  String name;

  String type;

  String subscribeId;

  String advertiseId;

  bool get isAdvertised => advertiseId != null;

  String publishId;

  String compression;

  int throttleRate;

  bool latch;

  int queueSize;

  int queueLength;

  bool reconnectOnClose;

  Topic({
    this.ros,
    this.name,
    this.type,
    this.compression = 'none',
    this.throttleRate = 0,
    this.latch = false,
    this.queueSize = 100,
    this.queueLength = 0,
    this.reconnectOnClose = true,
  }) : assert([ 'png', 'cbor', 'none' ].contains(compression)), assert(throttleRate >= 0);

  Future<void> subscribe() async {
    if (subscribeId == null) {
      subscription = ros.stream.where((message) => message['topic'] == name);
      subscribeId = ros.requestSubscriber(name);
      await safeSend(Request(
        op: 'subscribe',
        id: subscribeId,
        type: type,
        topic: name,
        compression: compression,
        throttleRate: throttleRate,
        queueLength: queueLength,
      ));
    }
  }

  Future<void> unsubscribe() async {
    if (subscribeId != null) {
      await safeSend(Request(
        op: 'unsubscribe',
        id: subscribeId,
        topic: name,
      ));
      // await ros.requestUnsubscribe(id);
      subscription = null;
      subscribeId = null;
    }
  }

  Future<void> publish(message) async {
    await advertise();
    publishId = ros.requestPublisher(name);
    await safeSend(Request(
      op: 'publish',
      topic: name,
      id: publishId,
      msg: message,
      latch: latch,
    ));
  }

  Future<void> advertise() async {
    if (!isAdvertised) {
      advertiseId = ros.requestAdvertiser(name);
      await safeSend(Request(
        op: 'advertise',
        id: advertiseId,
        type: type,
        topic: name,
        latch: latch,
        queueSize: queueSize,
      ));
      watchForClose();
    }
  }

  Future<void> watchForClose() async {
    if (!reconnectOnClose) {
      await ros.statusStream.firstWhere((s) => s == Status.CLOSED);
      advertiseId = null;
    }
  }

  Future<void> unadvertise() async {
    if (isAdvertised) {
      await safeSend(Request(
        op: 'unadvertise',
        id: advertiseId,
        topic: name,
      ));
      advertiseId = null;
    }
  }

  Future<void> safeSend(Request message) async {
    ros.send(message.toJson());
    if (reconnectOnClose && ros.status != Status.CONNECTED) {
      await ros.statusStream.firstWhere((s) => s == Status.CONNECTED);
      ros.send(message.toJson());
    }
  }

}
