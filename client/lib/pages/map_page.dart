import 'dart:async';
import 'dart:convert';

import 'package:client/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'chatpage.dart';

class Book {
  String name;
  String ownername;
  double latitude;
  double longitude;

  Book(this.name, this.ownername, this.latitude, this.longitude);
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Position? currentPosition;
  List<Map<String, dynamic>> books = [];
  Set<Marker> markers = {};
  List<Map<String, dynamic>> dummyMarkerData = [
    {
      "name": "book1",
      "placename": "교수회관",
      "latitude": 36.3746367,
      "longitude": 127.3648061,
      "owner": "책주인이름",
      "image": "/asset/images/image1.jpg"
    },
    {
      "name": "book2",
      "placename": "한국원자력안전기술원",
      "latitude": 36.3746164,
      "longitude": 127.3689033,
      "owner": "책주인이름",
      "image": "/asset/images/image1.jpg"
    },
    {
      "name": "book3",
      "placename": "카이스트 후문",
      "latitude": 36.3742223,
      "longitude": 127.3657778,
      "owner": "책주인이름",
      "image": "/asset/images/image1.jpg"
    },
    {
      "name": "book4",
      "placename": "N5 융합연구동",
      "latitude": 36.3742222,
      "longitude": 127.3657778,
      "owner": "책주인이름",
      "image": "/asset/images/image1.jpg"
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    getallbooks();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getallbooks() async {
    try {
      final response =
          await http.get(Uri.parse('http://172.10.7.78/get_all_books'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Access the 'books' key from the response and convert it to List<Map<String, dynamic>>
        final List<dynamic> booksData = responseData['books'];
        // print(booksData);
        // Convert the data to the desired format (List<Map<String, dynamic>>)
        setState(() {
          books = List<Map<String, dynamic>>.from(booksData);
          print(books);
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

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      _getCurrentLocation();
    } else {
      await Permission.location.request();
    }
  }

  // Future<void> fetchBookData() async {
  //   final Uri url = Uri.parse('http://172.10.7.78/get_all_books');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         books = json.decode(response.body)['books'];
  //       });
  //     } else {
  //       print(
  //           'Failed to load books. Status Code: ${response.statusCode}, Response: ${response.body}');
  //       throw Exception('Failed to load books');
  //     }
  //   } catch (error) {
  //     // Handle other errors, such as network errors.
  //     print('Error during book data fetch: $error');
  //     throw Exception('Failed to load books');
  //   }
  // }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = position;
        _updateCameraPosition();
        _updateMarkers(books);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _updateMarkers(List<dynamic> books) {
    markers.clear();
    List<dynamic> updatedBooks = List.from(books); // books 리스트를 변경하지 않도록 복사

    if (currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId("myLocation"),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: const InfoWindow(title: "Current Location"),
      ));

      for (var markerData in books) {
        print(markerData);
        double distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          double.parse(markerData["latitude"]),
          double.parse(markerData["longitude"]),
        );
        //일정범위 이내의 마커만 불러옴
        if (distance <= 1200) {
          markers.add(Marker(
            markerId: MarkerId(markerData["book_name"]),
            position: LatLng(double.parse(markerData["latitude"]),
                double.parse(markerData["longitude"])),
            infoWindow: InfoWindow(
              title: markerData["book_name"],
              snippet: 'Additional Info: ${markerData["placename"]}',
            ),
            onTap: () {},
          ));
        }
      }
    }
  }

  void _updateCameraPosition() {
    if (currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
        ),
      );
    }
  }

  void _focusMarkerOnListViewItemClick(LatLng markerPosition, String markerId) {
    mapController.animateCamera(
      CameraUpdate.newLatLng(markerPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng = LatLng(
      currentPosition?.latitude ?? 36.37422,
      currentPosition?.longitude ?? 127.3658,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentLatLng,
              zoom: 16.0,
            ),
            markers: markers,
            circles: {
              Circle(
                circleId: const CircleId('circle'),
                center: currentLatLng,
                radius: 120,
                fillColor: Colors.blue.withOpacity(0.2),
                strokeColor: Colors.blue,
                strokeWidth: 2,
              ),
            },
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.4,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: books.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: ListTile(
                              title: Text(books[index]["book_name"]),
                              subtitle: Text(
                                  "Book Owner: ${books[index]["register_id"]}"),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                ),
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: books[index]['img_url'] != null
                                      ? NetworkImage(books[index]['img_url'])
                                      : const AssetImage(
                                              'assets/placeholder_image.png')
                                          as ImageProvider,
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    print('Error loading image: $error');
                                    // Return a placeholder image or handle the error as needed
                                    return Image.asset(
                                        'assets/images/image1.jpg',
                                        fit: BoxFit.cover);
                                  },
                                ),
                              ),
                              onTap: () {
                                _focusMarkerOnListViewItemClick(
                                  LatLng(
                                    double.parse(books[index]["latitude"]),
                                    double.parse(books[index]["longitude"]),
                                  ),
                                  books[index]['book_name'],
                                  // 'Test'
                                );
                              },
                            ),
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text("이 책을 읽고 싶어요!"),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 30.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  bookIndex: books[index]
                                                      ['book_index']),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          backgroundColor: Colors.amber,
                                        ),
                                        child: const Text("1:1채팅방으로 이동하기")),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
