import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'ros_stub.dart';

WebSocketChannel initializeWebSocketChannel(String url) {
  return IOWebSocketChannel.connect(url);
}

var socketPlatform = SocketPlatform.IO;
