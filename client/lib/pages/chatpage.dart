import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatPage extends StatefulWidget {
  final int bookIndex;

  const ChatPage({required this.bookIndex, Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  late io.Socket _socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    //_socket = io.io('ws://172.10.7.78');
    _socket = io.io('ws://172.10.7.78', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false, // Set this to false to manually connect later
    });

    _socket.on('connect', (_) {
      print('Socket connected');
    });

    _socket.on('message', (data) {
      final receivedMessage = data.toString();
      setState(() {
        _messages.add(receivedMessage);
      });
    });

    _socket.on('disconnect', (_) {
      print('Socket disconnected');
    });

    _socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatting App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 메시지 전송 메서드
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _socket.emit('message', _messageController.text);
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
