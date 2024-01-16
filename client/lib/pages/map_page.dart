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
  double minHeight = 0.4;
  double maxHeight = 0.4;
  final GlobalKey _listItemKey = GlobalKey();

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

  void onMarkerTapped() {}

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

  void _animateSheetSize() {
    final RenderBox renderBox =
        _listItemKey.currentContext!.findRenderObject() as RenderBox;
    final listItemHeight = renderBox.size.height;

    setState(() {
      minHeight = listItemHeight / MediaQuery.of(context).size.height;
    });
  }

  void _updateMarkers(List<dynamic> books) {
    markers.clear();
    List<dynamic> updatedBooks = List.from(books);

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
        //if (distance <= 1200) {
        markers.add(
          Marker(
            markerId: MarkerId(markerData["book_name"]),
            position: LatLng(double.parse(markerData["latitude"]),
                double.parse(markerData["longitude"])),
            infoWindow: InfoWindow(
              title: markerData["book_name"],
              snippet: '작가: ${markerData["publisher"]}',
            ),
            onTap: () {},
          ),
        );
        //}
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
    List<Map<String, dynamic>> Listbooks = [...books];
    int? selectedItemIndex;
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
            child: DraggableScrollableSheet(
              initialChildSize: minHeight,
              minChildSize: minHeight,
              maxChildSize: maxHeight,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return ClipRRect(
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: Listbooks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: ListTile(
                              title: Text(
                                Listbooks[index]["book_name"],
                                style: const TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Book Owner: ${Listbooks[index]["register_id"]}"),
                                  Text(
                                      "Publisher: ${Listbooks[index]["publisher"]}"),
                                  Text(
                                      "Published Year: ${Listbooks[index]["published_year"]}"),
                                ],
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                ),
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: Listbooks[index]['img_url'] != null
                                      ? NetworkImage(
                                          Listbooks[index]['img_url'])
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
                                setState(() {
                                  selectedItemIndex = index;
                                  // if (index >= 0 &&
                                  //     index < Listbooks.length &&
                                  //     selectedItemIndex != null) {
                                  //   if (minHeight > 0.2 && maxHeight > 0.2) {
                                  //     minHeight = 0.2;
                                  //     maxHeight = 0.2;
                                  //   } else {
                                  //     minHeight = 0.4;
                                  //     maxHeight = 0.4;
                                  //   }
                                  // }
                                });
                                _focusMarkerOnListViewItemClick(
                                  LatLng(
                                    double.parse(Listbooks[index]["latitude"]),
                                    double.parse(Listbooks[index]["longitude"]),
                                  ),
                                  Listbooks[index]['book_name'],
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
                                                bookIndex: Listbooks[index]
                                                    ['book_index'],
                                                yourId: Listbooks[index]
                                                    ['register_id'],
                                              ),
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
