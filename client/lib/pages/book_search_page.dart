import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Book Search App',
      home: BookSearchScreen(),
    );
  }
}

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];
  Timer? _debounce;

  void _searchBooks(String keyword) async {
    final response = await http
        .get(Uri.parse('http://172.10.7.78/search_books?keyword=$keyword'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Book> results =
          List<Book>.from(data['books'].map((book) => Book.fromJson(book)));

      setState(() {
        _searchResults = results;
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  void _onSearchTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchBooks(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('책 검색하기'),
        backgroundColor: const Color(0xFFEEE9E0),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEE9E0),
                borderRadius:
                    BorderRadius.circular(8.0), // Optional: Add rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a keyword',
                    icon: Icon(Icons.search,
                        color: Color.fromARGB(
                            255, 40, 24, 24)), // Icon on the left
                    border: InputBorder.none, // Remove border
                  ),
                  onChanged: _onSearchTextChanged,
                  onSubmitted: (value) {
                    _searchBooks(value);
                  },
                  style: const TextStyle(color: Colors.black), // Set text color
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchResults[index].bookName),
                  subtitle: Text(_searchResults[index].author),
                  leading: SizedBox(
                    width: 80.0, // Set the width as per your requirement
                    height: 80.0, // Set the height as per your requirement
                    child: Image.network(
                      _searchResults[index].imgUrl,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  // Add more fields as needed
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Book {
  final int bookIndex;
  final String bookName;
  final String author;
  final String publisher;
  final String publishedYear;
  final String latitude;
  final String longitude;
  final String imgUrl;
  final String registerDate;

  Book({
    required this.bookIndex,
    required this.bookName,
    required this.author,
    required this.publisher,
    required this.publishedYear,
    required this.latitude,
    required this.longitude,
    required this.imgUrl,
    required this.registerDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookIndex: json['book_index'],
      bookName: json['book_name'],
      author: json['author'],
      publisher: json['publisher'],
      publishedYear: json['published_year'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imgUrl: json['img_url'],
      registerDate: json['register_date'],
    );
  }
}
