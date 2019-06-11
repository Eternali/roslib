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
  Ros ros = Ros(url: 'ws://localhost:9090');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roslib Example'),
      ),
      body: StreamBuilder<Object>(
          stream: ros.statusStream,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ActionChip(
                  label: Text(snapshot.data == Status.CONNECTED
                      ? 'DISCONNECT'
                      : 'CONNECT'),
                  onPressed: () {
                    if (snapshot.data == Status.CONNECTED)
                      ros.close();
                    else
                      ros.connect();
                  },
                ),
              ],
            );
          }),
    );
  }
}
