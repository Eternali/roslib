import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';
import 'ros_stub.dart';

WebSocketChannel initializeWebSocketChannel(String url) {
  return HtmlWebSocketChannel.connect(url);
}

var socketPlatform = SocketPlatform.WEB;
