import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatPage extends StatefulWidget {
  final int bookIndex;
  final String yourId;

  const ChatPage({
    required this.bookIndex,
    required this.yourId,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  late io.Socket _socket;
  String userId = '';
  String yourId = '';
  late int bookid;

  @override
  void initState() {
    super.initState();
    loadUserId();
    _initSocket();
  }

  void _displayMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      yourId = widget.yourId;
      bookid = widget.bookIndex;
    });
  }

  void _initSocket() {
    _socket = io.io('ws://172.10.7.78', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.on('connect', (_) {
      print('Socket connected');
    });

    _socket.on('message', (data) {
      final receivedMessage = data.toString();
      _displayMessage(receivedMessage);
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

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      if (mounted) {
        setState(() {
          _socket.emit('message', {
            'myid': userId,
            'yourid': yourId,
            'content': _messageController.text,
            'bookid': bookid,
            'register_id': userId,
          });
          _messageController.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
