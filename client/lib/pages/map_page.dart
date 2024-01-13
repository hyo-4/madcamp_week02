import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Location {
  double latitude;
  double longitude;

  Location(this.latitude, this.longitude);
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Position? currentPosition;

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
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng = LatLng(currentPosition?.latitude ?? 37.7749,
        currentPosition?.longitude ?? -122.4194);
    print(currentLatLng.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: currentLatLng,
          zoom: 11.0,
        ),
      ),
    );
  }
}
