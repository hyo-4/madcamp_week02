import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'locationselector.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookAdd extends StatefulWidget {
  const BookAdd({super.key});

  @override
  State<BookAdd> createState() => _BookAddState();
}

class _BookAddState extends State<BookAdd> {
  String? _selectedLocationAddress;
  TextEditingController _bookNameController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _publisherController = TextEditingController();
  DateTime? _selectedDate;
  String? _imagePath;
  LatLng? selectedLocation;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        print(_imagePath);
      });
    }
  }

  Future<void> _sendbookdata() async {
    final apiUrl = Uri.parse("http://172.10.7.78:80/savebook");

    // Get the selected location
    // LatLng selectedLocation = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => MapSelectionScreen()),
    // );
    // LatLng selectedLocation = await Navigator.pop();
    // Check if all required data is available
    if (_selectedDate != null &&
        _bookNameController.text.isNotEmpty &&
        _authorController.text.isNotEmpty &&
        _publisherController.text.isNotEmpty &&
        _imagePath != null) {
      try {
        // Create a map with your data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var _register_id = (prefs.getString('user_id') ?? '');
        final data = {
          "registerId": _register_id, // Replace with actual registerId
          "bookName": _bookNameController.text,
          "author": _authorController.text,
          "publisher": _publisherController.text,
          "publishedYear": _selectedDate!.year.toString(),
          "latitude": selectedLocation!.latitude.toString(),
          "longitude": selectedLocation!.longitude.toString(),
        };
        print(data);
        // Create a multipart request
        var request = http.MultipartRequest('POST', apiUrl);

        // Add the image file to the request
        request.files
            .add(await http.MultipartFile.fromPath('image', _imagePath!));

        // Add other form data to the request
        request.fields.addAll(data);
        //add image file
        List<int> imageBytes = await File(_imagePath!).readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg', // You can set any filename you prefer
          contentType:
              MediaType('image', 'jpg'), // Adjust the content type accordingly
        ));
        // Send the request
        final response = await request.send();

        // Check the response
        if (response.statusCode == 200) {
          print("Data sent successfully");
          // Handle success
        } else {
          print("Failed to send data. Status code: ${response.statusCode}");
          // Handle failure
        }
      } catch (error) {
        print("Error sending data: $error");
        // Handle error
      }
    } else {
      print("Some required data is missing");
      // Handle missing data
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.teal,
            // accentColor: Colors.teal,
            colorScheme: ColorScheme.light(primary: Colors.teal),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.input,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEDE9E1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('책 등록하기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imagePath != null
                  ? Image.file(
                      File(_imagePath!),
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Color(0xFFEDE9E1),
                      height: 200,
                      width: 200,
                      child: Center(
                        child: Text('탭하여 책 표지 사진 추가하기'),
                      ),
                    ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _bookNameController,
              decoration: InputDecoration(
                labelText: '책 이름',
                labelStyle: TextStyle(color: Color(0xff8f826f)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff8f826f)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xff8f826f)),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: '작가',
                labelStyle: TextStyle(color: Color(0xff8f826f)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff8f826f)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xff8f826f)),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _publisherController,
              decoration: InputDecoration(
                labelText: '출판사명',
                labelStyle: TextStyle(color: Color(0xff8f826f)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff8f826f)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xff8f826f)),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () => _selectYear(context),
              style: ElevatedButton.styleFrom(
                primary: Color(0xffede9e1), // Background color
                onPrimary: Colors.black, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Button border radius
                ),
              ),
              child: Text(_selectedDate == null
                  ? 'Select Year'
                  : 'Selected Year: ${_selectedDate!.year}'),
            ),
            // const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapSelectionScreen()),
                );

                // Use the selectedLocation as needed
                if (selectedLocation != null) {
                  print("Selected Latitude: ${selectedLocation!.latitude}");
                  print("Selected Longitude: ${selectedLocation!.longitude}");
                  // Do something with the selected location
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xffede9e1), // Background color
                onPrimary: Colors.black, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Button border radius
                ),
              ),
              child: Text(_selectedLocationAddress == null
                  ? 'Pick Location'
                  : 'Selected Location: $_selectedLocationAddress'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () => {
                _sendbookdata(),
                Navigator.pop(context),
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xffede9e1), // Background color
                onPrimary: Colors.black, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Button border radius
                ),
              ),
              child: Text('책 등록'),
            ),
          ],
        ),
      ),
    );
  }
}

String _buildAddressString(Placemark placemark) {
  return [
    placemark.thoroughfare,
    placemark.subThoroughfare,
    placemark.locality,
    placemark.subLocality,
    placemark.administrativeArea,
    placemark.subAdministrativeArea,
    placemark.postalCode,
    placemark.country,
  ].where((element) => element != null && element.isNotEmpty).join(', ');
}
