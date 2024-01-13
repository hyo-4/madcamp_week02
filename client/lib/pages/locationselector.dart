import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapSelectionScreen extends StatefulWidget {
  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? mapController;
  LatLng currentLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }
  Future<void> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      await _initMap();
    } else {
      await Permission.location.request().then((status) {
        if (status == PermissionStatus.granted) {
          _initMap();
        } else {
          // Handle the case when location permission is denied
          // You might want to show a message or request the permission again
        }
      });
    }
  }
  Future<void> _initMap() async {
    await _getCurrentLocation();
  }
  void _updateCameraPosition() {
    if (currentLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentLocation!.latitude, currentLocation!.longitude),
        ),
      );
    }
  }
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {

      currentLocation = LatLng(position.latitude, position.longitude);
      print(currentLocation);
      _updateCameraPosition();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onSelectLocation() {
    if (mapController != null) {
      mapController!.getLatLng(ScreenCoordinate(x: 0, y: 0)).then((LatLng latLng) {
        print("Center Latitude: ${latLng.latitude}");
        print("Center Longitude: ${latLng.longitude}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: currentLocation, // Set initial camera position to the current location
          zoom: 15.0,
        ),
        myLocationButtonEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSelectLocation,
        child: Icon(Icons.location_on),
      ),
    );
  }
}
