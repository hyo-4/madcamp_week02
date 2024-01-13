import 'dart:async';

import 'package:client/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool isListViewVisible = false;
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

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = position;
        _updateMarkers();
        _updateCameraPosition();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _updateMarkers() {
    markers.clear();
    if (currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId("myLocation"),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: const InfoWindow(title: "Current Location"),
      ));

      for (var markerData in dummyMarkerData) {
        double distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          markerData["latitude"],
          markerData["longitude"],
        );
        //일정범위 이내의 마커만 불러옴
        if (distance <= 120) {
          markers.add(Marker(
            markerId: MarkerId(markerData["name"]),
            position: LatLng(markerData["latitude"], markerData["longitude"]),
            infoWindow: InfoWindow(
              title: markerData["name"],
              snippet: 'Additional Info: ${markerData["placename"]}',
            ),
            onTap: () {
              _toggleListViewVisibility();
            },
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

    // Delay the showInfoWindow call to ensure the camera animation is complete
    Future.delayed(const Duration(milliseconds: 500), () {
      mapController.showMarkerInfoWindow(MarkerId(markerId));
      _toggleListViewVisibility();
    });
  }

  void _toggleListViewVisibility() {
    setState(() {
      isListViewVisible = !isListViewVisible;
    });
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
                      itemCount: dummyMarkerData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: ListTile(
                              title: Text(dummyMarkerData[index]["name"]),
                              subtitle: Text(
                                  "Book Owner: ${dummyMarkerData[index]["owner"]}"),
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
                                _focusMarkerOnListViewItemClick(
                                  LatLng(
                                    dummyMarkerData[index]["latitude"],
                                    dummyMarkerData[index]["longitude"],
                                  ),
                                  dummyMarkerData[index]['name'],
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
