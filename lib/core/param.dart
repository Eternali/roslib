import 'dart:async';
import 'ros.dart';
import 'service.dart';

class Param {

  Ros ros;
  
  String name;

  Param({ this.ros, this.name });

  Future get() {
    final client = Service(
      ros: ros,
      name: '/rosapi/get_param',
      type: 'rosapi/GetParam',
    );
    return client.call({ 'name': name });
  }

  Future set(dynamic value) {
    final client = Service(
      ros: ros,
      name: '/rosapi/set_param',
      type: 'rosapi/SetParam',
    );
    return client.call({
      'name': name,
      'value': value,
    });
  }

  Future delete() {
    final client = Service(
      ros: ros,
      name: '/rosapi/delete_param',
      type: 'rosapi/DeleteParam',
    );
    return client.call({ 'name': name });
  }

}