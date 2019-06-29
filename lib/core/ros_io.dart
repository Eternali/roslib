import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'ros.dart';

class Ros_IO extends Ros {
  Ros_IO({String url}) : super(url: url);

  @override
  WebSocketChannel initializeWebSocketChannel() {
    return IOWebSocketChannel.connect(this.url);
  }
}
