import 'package:flutter/material.dart';
import 'package:roslib/roslib.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roslib Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Ros ros;
  Topic chatter;

  @override
  void initState() {
    ros = Ros(url: 'ws://10.0.2.2:9090');
    chatter = Topic(
        ros: ros, name: '/chatter', type: "std_msgs/String", reconnectOnClose: true, queueLength: 10, queueSize: 10);
    super.initState();
  }

  void initConnection() async {
    ros.connect();
    await chatter.subscribe();
    setState(() {});
  }

  void destroyConnection() async {
    await chatter.unsubscribe();
    await ros.close();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roslib Example'),
      ),
      body: StreamBuilder<Object>(
          stream: ros.statusStream,
          builder: (context, snapshot) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder(
                    stream: chatter.subscription,
                    builder: (context2, snapshot2) {
                      if (snapshot2.hasData) {
                        return Text('${snapshot2.data['msg']}');
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  ActionChip(
                    label: Text(snapshot.data == Status.CONNECTED ? 'DISCONNECT' : 'CONNECT'),
                    backgroundColor: snapshot.data == Status.CONNECTED ? Colors.green[300] : Colors.grey[300],
                    onPressed: () {
                      print(snapshot.data);
                      if (snapshot.data != Status.CONNECTED) {
                        this.initConnection();
                      } else {
                        this.destroyConnection();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
