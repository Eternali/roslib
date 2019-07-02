import 'package:flutter_web/material.dart';
import 'package:roslib/roslib.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roslib Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key) {}

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Ros ros;
  Topic chatter;

  @override
  void initState() {
    ros = Ros(url: 'ws://127.0.0.1:9090');
    chatter = Topic(
        ros: ros, name: '/chatter', type: "std_msgs/String", reconnectOnClose: true, queueLength: 10, queueSize: 10);
    this.initConnection();
    super.initState();
  }

  void initConnection() {
    setState(() {
      ros.connect();
      chatter.subscribe();
    });
  }

  void destroyConnection() async {
    setState(() {
      chatter.unsubscribe();
      ros.close();
    });
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
                      if (snapshot.data == Status.CONNECTED) {
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
