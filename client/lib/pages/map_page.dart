import 'dart:async';
import 'dart:convert';

import 'package:client/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Position? currentPosition;
  List<dynamic> books = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    fetchBookData();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      _getCurrentLocation();
    } else {
      await Permission.location.request();
    }
  }

  Future<void> fetchBookData() async {
    final Uri url = Uri.parse('http://172.10.7.78:80/get_all_books');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          books = json.decode(response.body)['books'];
        });
      } else {
        print(
            'Failed to load books. Status Code: ${response.statusCode}, Response: ${response.body}');
        throw Exception('Failed to load books');
      }
    } catch (error) {
      // Handle other errors, such as network errors.
      print('Error during book data fetch: $error');
      throw Exception('Failed to load books');
    }
  }

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

      for (var book in updatedBooks) {
        double distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          double.parse(book["latitude"]),
          double.parse(book["longitude"]),
        );

        markers.add(Marker(
          markerId: MarkerId(book["book_name"]),
          position: LatLng(
            double.parse(book["latitude"]),
            double.parse(book["longitude"]),
          ),
          infoWindow: InfoWindow(
            title: book["book_name"],
            snippet: 'Author: ${book["author"]}',
          ),
          onTap: () {},
        ));
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
                                title: Text(books[index]['book_name']),
                                subtitle: Text(books[index]['author']),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          'assets/images/blankimg.png'),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (books[index] != null &&
                                      books[index]['book_name'] != null) {
                                    _focusMarkerOnListViewItemClick(
                                      LatLng(
                                        double.parse(books[index]["latitude"]),
                                        double.parse(books[index]["longitude"]),
                                      ),
                                      books[index]['book_name'],
                                    );
                                  }
                                }),
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
                                                builder: (context) =>
                                                    const MainPage()),
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
