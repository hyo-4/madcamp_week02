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
  Marker? centerMarker;

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
      _updateCenterMarker(currentLocation);
    });
  }

  void _updateCenterMarker(LatLng position) {
    setState(() {
      centerMarker = Marker(
        markerId: MarkerId("centerMarker"),
        position: position,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Center Marker"),
      );
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
        // print("Center Latitude: ${latLng.latitude}");
        // print("Center Longitude: ${latLng.longitude}");
        Navigator.pop(context,latLng);
      });
    }
  }
  void _onCameraMove(CameraPosition position) {
    _updateCenterMarker(position.target);
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
        markers: Set.of([if (centerMarker != null) centerMarker!]),
        onCameraMove: _onCameraMove,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Adjust the bottom padding as needed
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 200,
            child: FloatingActionButton(
              onPressed: _onSelectLocation,
              child: Text('대여 장소를 현재 워치로 설정'),
            ),
          ),
        ),
      ),
    );
  }
}
