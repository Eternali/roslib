import 'dart:convert';

class Request {

  String op;

  String id;

  String type;

  String topic;

  dynamic msg;

  bool latch;

  String compression;

  int throttleRate;

  int queueLength;
  
  int queueSize;

  String service;

  Map<String, dynamic> args;

  dynamic values;

  bool result;

  Request({
    this.op,
    this.id,
    this.type,
    this.topic,
    this.msg,
    this.latch,
    this.compression,
    this.throttleRate,
    this.queueLength,
    this.queueSize,
    this.service,
    this.args,
    this.values,
    this.result,
  });

  factory Request.fromJson(dynamic jsonData) {
    return Request(
      op: jsonData['op'],
      id: jsonData['id'],
      type: jsonData['type'],
      topic: jsonData['topic'],
      msg: jsonData['msg'],
      latch: jsonData['latch'],
      compression: jsonData['compression'],
      throttleRate: jsonData['throttle_rate'],
      queueLength: jsonData['queue_length'],
      queueSize: jsonData['queue_size'],
      service: jsonData['service'],
      args: jsonData['args'],
      values: jsonData['values'],
      result: jsonData['result'],
    );
  }

  factory Request.decode(String raw) {
    return Request.fromJson(json.decode(raw));
  }

  Map<String, dynamic> toJson() {
    return {
      if (op != null) 'op': op,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (topic != null) 'topic': topic,
      if (msg != null) 'msg': msg,
      if (latch != null) 'latch': latch,
      if (compression != null) 'compression': compression,
      if (throttleRate != null) 'throttle_rate': throttleRate,
      if (queueLength != null) 'queue_length': queueLength,
      if (queueSize != null) 'queue_size': queueSize,
      if (service != null) 'service': service,
      if (args != null) 'args': args,
      if (values != null) 'values': values,
      if (result != null) 'result': result,
    };
  }

  String encode() {
    return json.encode(toJson());
  }

}
