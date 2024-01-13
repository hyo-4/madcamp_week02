import 'package:flutter/material.dart';

class BookAdd extends StatefulWidget {
  const BookAdd({super.key});

  @override
  State<BookAdd> createState() => _BookAddState();
}

class _BookAddState extends State<BookAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('책 등록하기'),
      ),
      body: const Center(
        child: Text('bookadd'),
      ),
    );
  }
}
