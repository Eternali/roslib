import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

WebSocketChannel initializeWebSocketChannel(String url) {
  return IOWebSocketChannel.connect(url);
}
