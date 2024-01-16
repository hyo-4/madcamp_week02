import 'dart:io';

import 'package:client/services/socket_service.dart';
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
  //late io.Socket _socket;
  late SocketService _socketService;
  String userId = '';
  String yourId = '';
  late int bookid;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService(onMessageReceived: _displayMessage);
    loadUserId();
    _socketService.initSocket();
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
          _socketService.sendMessage(
            userId: userId,
            yourId: yourId,
            message: _messageController.text,
            bookId: bookid,
          );
          _messageController.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    _socketService.disconnectSocket(); // Disconnect the socket
    super.dispose();
  }
}
