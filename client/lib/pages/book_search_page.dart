import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'chatpage.dart';

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
  List<Map<String, dynamic>> searchbooks = [];
  List<Book> _searchResults = [];
  Timer? _debounce;
  void initState() {
    super.initState();
    // loadUserId();// Load the user ID when the widget is initialized
  }
  Future<void> _showMapDialog(double latitude, double longitude) async {
    print('showdialog');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            height: 400, // Set your desired height
            width: 400, // Set your desired width
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 13.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('markerId'),
                  position: LatLng(latitude, longitude),
                  icon: BitmapDescriptor.defaultMarker,
                ),
              },
            ),
          ),
          backgroundColor: Colors.blue, // Set your desired background color
        );
      },
    );
  }
  void _searchBooks(String keyword) async {
    final response = await http
        .get(Uri.parse('http://172.10.7.78/search_books?keyword=$keyword'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Access the 'books' key from the response and convert it to List<Map<String, dynamic>>
      final List<dynamic> booksData = responseData['books'];
      // print(booksData);
      // Convert the data to the desired format (List<Map<String, dynamic>>)
      setState(() {
        searchbooks = List<Map<String, dynamic>>.from(booksData);
        print(searchbooks);
      });
    }else {
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
    List<Map<String, dynamic>> Listbooks = [...searchbooks];
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
              shrinkWrap: true, // Important to set shrinkWrap to true
              physics:
              NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
              itemCount: Listbooks.length,
              itemBuilder: (context, index) {
                if (Listbooks[index]['book_status'] == 'available') {
                  return ExpansionTile(
                    tilePadding: EdgeInsets.all(0), // Optional: Adjust padding as needed
                    childrenPadding: EdgeInsets.all(16), // Optional: Adjust padding as needed
                    leading: Image.network(
                      Listbooks[index]['img_url'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      Listbooks[index]['book_name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '저자: ${Listbooks[index]['author']}   출판사: ${Listbooks[index]['publisher']} (${Listbooks[index]['published_year']})',
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '대여 가능',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showMapDialog(
                                    double.parse(Listbooks[index]['latitude']),
                                    double.parse(Listbooks[index]['longitude']),
                                  );
                                },
                                child: Text('장소 보기'),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffede9e1), // Change button color
                                  onPrimary: Colors.black, // Change text color
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // Optional: Adjust spacing between buttons
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        bookIndex: Listbooks[index]
                                        ['book_index'],
                                        yourId: Listbooks[index]
                                        ['register_id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text('1:1 채팅하기'),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xfff3ae2b), // Change button color
                                  onPrimary: Colors.black, // Change text color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (Listbooks[index]['book_status'] == 'reading') {
                  return ExpansionTile(
                    tilePadding: EdgeInsets.all(0), // Optional: Adjust padding as needed
                    childrenPadding: EdgeInsets.all(16), // Optional: Adjust padding as needed
                    leading: Image.network(
                      Listbooks[index]['img_url'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      Listbooks[index]['book_name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '저자: ${Listbooks[index]['author']}   출판사: ${Listbooks[index]['publisher']} (${Listbooks[index]['published_year']})',
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '대여중',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showMapDialog(
                                    double.parse(Listbooks[index]['latitude']),
                                    double.parse(Listbooks[index]['longitude']),
                                  );
                                },
                                child: Text('장소 보기'),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffede9e1), // Change button color
                                  onPrimary: Colors.black, // Change text color
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // Optional: Adjust spacing between buttons
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        bookIndex: Listbooks[index]
                                        ['book_index'],
                                        yourId: Listbooks[index]
                                        ['register_id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text('1:1 채팅하기'),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xfff3ae2b), // Change button color
                                  onPrimary: Colors.black, // Change text color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                } else if (Listbooks[index]['book_status'] == 'unavailable') {
                  return ExpansionTile(
                    tilePadding: EdgeInsets.all(0), // Optional: Adjust padding as needed
                    childrenPadding: EdgeInsets.all(16), // Optional: Adjust padding as needed
                    leading: Image.network(
                      Listbooks[index]['img_url'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      Listbooks[index]['book_name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '저자: ${Listbooks[index]['author']}   출판사: ${Listbooks[index]['publisher']} (${Listbooks[index]['published_year']})',
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '대여 불가',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showMapDialog(
                                    double.parse(Listbooks[index]['latitude']),
                                    double.parse(Listbooks[index]['longitude']),
                                  );
                                },
                                child: Text('장소 보기'),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffede9e1), // Change button color
                                  onPrimary: Colors.black, // Change text color
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // Optional: Adjust spacing between buttons
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        bookIndex: Listbooks[index]
                                        ['book_index'],
                                        yourId: Listbooks[index]
                                        ['register_id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text('1:1 채팅하기'),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xfff3ae2b), // Change button color
                                  onPrimary: Colors.black, // Change text color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
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
