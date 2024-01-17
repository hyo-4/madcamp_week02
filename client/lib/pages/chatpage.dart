import 'dart:convert';
import 'dart:io';

import 'package:client/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

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
  final List _messages = [];
  //late io.Socket _socket;
  late SocketService _socketService;
  String userId = '';
  String yourId = '';
  int? bookid;
  List sendList = [];

  Future<void> getchat() async {
    const String url = 'http://172.10.7.78/get_chat_content';

    final Map<String, dynamic> data = {
      'myid': 'qq',
      'yourid': 'sh',
      'bookid': 28
    };
    print('Sending data: $data');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List contentList = data['content_list'];
        List contentValues =
            contentList.map((item) => item['content']).toList();

        if (mounted) {
          setState(() {
            _messages.addAll(contentValues);
          });
        }
      } else {
        throw Exception('Failed to load chat list');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getchat();
    _socketService = SocketService(onMessageReceived: _displayMessage);
    loadUserId();
    _socketService.initSocket();
  }

  void _displayMessage(String message) {
    if (mounted) {
      setState(() {
        _messages.add(message);
        Map<String, dynamic> messageMap = json.decode(message);
        String myId = messageMap["myid"];
        print("Received message from $myId");
      });
    }
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
    if (_messageController.text.isNotEmpty && mounted) {
      setState(() {
        _socketService.sendMessage(
          userId: userId,
          yourId: yourId,
          message: _messageController.text,
          bookId: bookid!,
        );
        _messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _socketService.disconnectSocket(); // Disconnect the socket
    super.dispose();
  }
}
