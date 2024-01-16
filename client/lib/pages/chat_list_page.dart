import 'dart:convert';

import 'package:client/pages/chatpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String userId = "";
  List<Map<String, dynamic>> chatList = [];

  @override
  void initState() {
    super.initState();
    loadUserId();
    getlist();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? 'qq';
    });
    print(userId);
  }

  Future<void> getlist() async {
    const String url = 'http://172.10.7.78/get_chat_list';

    final Map<String, dynamic> data = {
      'myid': 'qq',
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
        setState(() {
          chatList = List<Map<String, dynamic>>.from(data['chat_list']);
        });
      } else {
        throw Exception('Failed to load chat list');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    bookIndex: chatList[index]['bookid'],
                    yourId: userId,
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text('Your ID: ${chatList[index]['yourid']}'),
              subtitle: Text('Book ID: ${chatList[index]['bookid']}'),
              // Add more widgets or customize as needed
            ),
          );
        },
      ),
    );
  }
}
