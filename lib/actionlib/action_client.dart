// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';
import 'package:roslib/core/core.dart';

class ActionClient {

  ActionClient({
    this.ros,
    this.serverName,
    this.actionName,
    this.timeout,
    this.omitFeedback,
    this.omitStatus,
    this.omitResult,
  });

  Ros ros;

  String serverName;

  String actionName;

  int timeout;

  bool omitFeedback;

  bool omitStatus;

  bool omitResult;

  Map<String, StreamController> goals = {};

  Topic feedbacker;

  Topic statuser;

  Topic resulter;

  Topic goaler;

  Topic canceler;

  List<StreamSubscription> subs = [];

  Future<void> init() async {
    feedbacker = Topic(
      ros: ros,
      name: '$serverName/feedback',
      type: '${actionName}Feedback',
    );
    statuser = Topic(
      ros: ros,
      name: '$serverName/status',
      type: 'actionlib_msgs/GoalStatusArray',
    );
    resulter = Topic(
      ros: ros,
      name: '$serverName/result',
      type: '${actionName}Result',
    );
    goaler = Topic(
      ros: ros,
      name: '$serverName/goal',
      type: '${actionName}Goal',
    );
    canceler = Topic(
      ros: ros,
      name: '$serverName/cancel',
      type: 'actionlib_msgs/GoalID',
    );

    await goaler.advertise();
    await canceler.advertise();

    if (!omitStatus) {
      await statuser.subscribe();
      subs.add(statuser.subscription.listen((message) {
        for (var status in message['status_list']) {
          String g = status['goal_id']['id'];
          goals[g] ??= StreamController.broadcast();
          goals[g].add({ 'status': status });
        }
      }));
    }

    if (!omitFeedback) {
      await feedbacker.subscribe();
      subs.add(feedbacker.subscription.listen((message) {
        String g = message['status']['goal_id']['id'];
        goals[g] ??= StreamController.broadcast();
        goals[g].add({ 'status': message['status'] });
        goals[g].add({ 'feedback': message['feedback'] });
      }));
    }

    if (!omitResult) {
      await resulter.subscribe();
      subs.add(resulter.subscription.listen((message) {
        String g = message['status']['goal_id']['id'];
        goals[g] ??= StreamController.broadcast();
        goals[g].add({ 'status': message['status'] });
        goals[g].add({ 'result': message['result'] });
      }));
    }
  }

  void cancel() {

  }

  void dispose() {

  }

}
