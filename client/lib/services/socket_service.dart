import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket _socket;
  late Function(String) onMessageReceived; // Callback to notify ChatPage

  SocketService({required this.onMessageReceived});

  void initSocket() {
    _socket = io.io('ws://172.10.7.78', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.on('connect', (_) {
      print('Socket connected');
    });

    _socket.on('message', (data) {
      final receivedMessage = data.toString();
      onMessageReceived(receivedMessage);
    });

    _socket.on('disconnect', (_) {
      print('Socket disconnected');
    });

    _socket.connect();
  }

  void sendMessage({
    required String userId,
    required String yourId,
    required String message,
    required int bookId,
  }) {
    _socket.emit('message', {
      'myid': userId,
      'yourid': yourId,
      'content': message,
      'bookid': bookId,
      'register_id': yourId,
    });
  }

  void disconnectSocket() {
    _socket.disconnect();
  }
}
