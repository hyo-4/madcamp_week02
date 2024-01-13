import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'locationselector.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
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
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      height: 300,
                      child: Center(
                        child: Text('Tap to pick an image'),
                      ),
                    ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _bookNameController,
              decoration: InputDecoration(labelText: '책 이름'),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: '작가'),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _publisherController,
              decoration: InputDecoration(labelText: '출판사명'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () => _selectYear(context),
              child: Text(_selectedDate == null
                  ? 'Select Year'
                  : 'Selected Year: ${_selectedDate!.year}'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapSelectionScreen()),
                );
              },
              child: Text(_selectedLocationAddress == null
                  ? 'Pick Location'
                  : 'Selected Location: $_selectedLocationAddress'),
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
