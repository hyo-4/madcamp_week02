import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyprofilePage extends StatefulWidget {
  const MyprofilePage({Key? key}) : super(key: key);
  @override
  _MyprofileState createState() => _MyprofileState();
}

class _MyprofileState extends State<MyprofilePage> {
  String userId = ''; // Initialize with an empty string
  List<Map<String, dynamic>> mybooks = [];
  @override
  void initState() {
    super.initState();
    // loadUserId();
    getmybooks(); // Load the user ID when the widget is initialized
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ??
          ''; // Assign the user ID or an empty string if it's not available
    });
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


  Future<void> getmybooks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('user_id') ??
            ''; // Assign the user ID or an empty string if it's not available
      });
      final response = await http
          .get(Uri.parse('http://172.10.7.78/get_my_books?user_id=$userId'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Access the 'books' key from the response and convert it to List<Map<String, dynamic>>
        final List<dynamic> booksData = responseData['books'];
        // print(booksData);
        // Convert the data to the desired format (List<Map<String, dynamic>>)
        setState(() {
          mybooks = List<Map<String, dynamic>>.from(booksData);
          print(mybooks);
        });
      } else {
        // Handle the error
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> Listbooks = [...mybooks];
    print(Listbooks);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: const Color(0xFFEEE9E0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    // backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '$userId님',
                    // 'User Name: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Implement logout logic
                      Navigator.of(context).pop(); // Pop once to close the current screen
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Change button color
                      onPrimary: Colors.white, // Change text color
                    ),
                    child: Text('Logout'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '등록한 책',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${Listbooks.length}',
                          // 'tmp register num',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '읽은 책',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          // '$읽은책Number',
                          'tmp read num',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '내가 등록한 책',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
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
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
