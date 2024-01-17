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
  String roomid = "";
  bool me = false;
  //late io.Socket _socket;
  late SocketService _socketService;
  String yourid = '';
  String userId = '';
  int? bookid;
  List sendList = [];
  final List messageId = [];

  Future<void> getchat() async {
    const String url = 'http://172.10.7.78/get_chat_content';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? 'qq';
      yourid = widget.yourId;
      bookid = widget.bookIndex;

      if (userId.compareTo(yourid) > 0) {
        roomid = '$bookid|$yourid|$userId';
      } else {
        roomid = '$bookid|$userId|$yourid';
      }
    });

    final Map<String, dynamic> data = {
      'chatroom_id': roomid,
    };

    try {
      print('Sending data: $data');
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
        List contentValues2 = contentList.map((item) => item['myid']).toList();

        if (mounted) {
          setState(() {
            _messages.addAll(contentValues);
            messageId.addAll(contentValues2);
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
    //loadUserId();
    _socketService.initSocket();
  }

  void _displayMessage(String message) {
    if (mounted) {
      setState(() {
        _messages.add(message);
        if (me) {
          messageId.add(userId);
        } else {
          messageId.add(yourid);
        }
        me = false;
      });
    }
  }

  // Future<void> loadUserId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     userId = prefs.getString('user_id') ?? '';
  //     //yourId = widget.yourId;
  //     bookid = widget.bookIndex;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(yourid.toString()),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              bool isCurrentUser =
                  messageId[index] == userId; // 현재 사용자의 메시지 여부 확인

              return Container(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  color: isCurrentUser
                      ? const Color(0xffede9e1)
                      : const Color.fromARGB(255, 255, 238, 205),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 80,
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        _messages[index],
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        messageId[index],
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )),
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
        me = true;
        _socketService.sendMessage(
          userId: userId,
          yourId: yourid,
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
