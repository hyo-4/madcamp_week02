import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  final int bookIndex;

  const ChatPage({required this.bookIndex, Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];
  late final WebSocketChannel channel;
  // late final channel = IOWebSocketChannel.connect('ws://172.10.7.78:80');

  @override
  void initState() {
    super.initState();
    // channel = IOWebSocketChannel.connect('ws://172.10.7.78:80');
    channel = WebSocketChannel.connect(
      Uri.parse('ws://172.10.7.78:80'),
    );

    channel.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  void _sendMessage(String message) {

    print('Received message: $message');
    channel.sink.add(message);
    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatting App'),
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
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
