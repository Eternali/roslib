// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';
import 'package:test/test.dart';
import 'package:roslib/roslib.dart';

void main() {
  Ros ros;

  setUp(() {
    ros = Ros(url: 'ws://localhost:9090');
    ros.connect();
  });

  tearDown(() {
    ros.close();
  });

  test('check if a new url is provided upon connection it is used', () async {
    // closes connection created in [setUp] which is retained only to ensure all
    // tests pass regardless of order of execution.
    await ros.close();
    ros = Ros(url: 'ws://127.0.0.1:9090');
    expect(ros.url, 'ws://127.0.0.1:9090');
    ros.connect(url: 'ws://localhost:9090');
    expect(ros.url, 'ws://localhost:9090');
  });

  test('checks ROS websocket', () {
    expect(ros.statusStream, isNotNull);
    expect(ros.stream, isNotNull);
    expect(ros.status, Status.CONNECTED);
  });

  test('subscribe and publish to a topic', () async {
    final cmdVel = Topic(
      ros: ros,
      name: '/cmd_vel',
      type: 'geometry_msgs/Twist',
    );
    final msg = {
      'linear': {'x': 0.1, 'y': 0.2, 'z': 0.3},
      'angular': {'x': -0.1, 'y': -0.2, 'z': -0.3},
    };
    await cmdVel.subscribe();
    expect(cmdVel.subscription, isNotNull);
    // ROS is adding a subscriber, hence number of ids += 1
    expect(cmdVel.subscribeId, 'subscribe:/cmd_vel:1');
    expect(ros.ids, 1);
    final listener = cmdVel.subscription.listen((data) async {
      expect(data['msg'], msg);
      await cmdVel.unsubscribe();
      expect(cmdVel.subscribeId, isNull);
    });
    await cmdVel.publish(msg);
    // ROS is adding an advertiser and publisher, hence number of ids +=2
    expect(cmdVel.publishId, 'publish:/cmd_vel:3');
    expect(ros.ids, 3);
    await Future.delayed(Duration(seconds: 1));
    listener.cancel();
  });

  test('call a service', () async {
    final client = Service(
      ros: ros,
      name: '/add_two_ints',
      type: 'rospy_tutorials/AddTwoInts',
    );
    final req = {'a': 1, 'b': 2};
    final resp = await client.call(req);
    expect(resp, {'sum': 3});
  });

  test('host a service', () async {
    final server = Service(
      ros: ros,
      name: '/add_two_ints_dart',
      type: 'rospy_tutorials/AddTwoInts',
    );
    server.advertise((request) async {
      return {'sum': request['a'] + request['b']};
    });
    final client = Service(
      ros: ros,
      name: '/add_two_ints_dart',
      type: 'rospy_tutorials/AddTwoInts',
    );
    final req = {'a': 1, 'b': 2};
    final resp = await client.call(req);
    expect(resp, {'sum': 3});
  });

  test('get and set a param value', () async {
    final param = Param(
      ros: ros,
      name: 'max_vel_y',
    );
    param.set('0.8');
    expect(await param.get(), {'value': '0.8'});
  });
}
