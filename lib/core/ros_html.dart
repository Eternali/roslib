import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';
import 'ros.dart';

class Ros_Html extends Ros {
  Ros_Html({String url}) : super(url: url);

  @override
  WebSocketChannel initializeWebSocketChannel() {
    return HtmlWebSocketChannel.connect(this.url);
  }
}
