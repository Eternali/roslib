import 'dart:async';
import 'dart:convert';
import 'ros.dart';
import 'service.dart';

class Param {

  Ros ros;
  
  String name;

  Param({ this.ros, this.name });

  Future get() async {
    final client = Service(
      ros: ros,
      name: '/rosapi/get_param',
      type: 'rosapi/GetParam',
    );
    return json.decode(await client.call({ 'name': name }));
  }

}