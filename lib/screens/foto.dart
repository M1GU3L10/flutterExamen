import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class FotoMapaScreen extends StatefulWidget {
  @override
  _FotoMapaScreenState createState() => _FotoMapaScreenState();
}

class _FotoMapaScreenState extends State<FotoMapaScreen> {
  LatLng? _currentLocation;
  Uint8List? _imageFile;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  void _checkLocationPermission() async {
    loc.Location location = loc.Location();

    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    loc.PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    loc.Location location = loc.Location();
    try {
      loc.LocationData _locationData = await location.getLocation();
      setState(() {
        _currentLocation =
            LatLng(_locationData.latitude!, _locationData.longitude!);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = imageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar Foto y Geolocalización'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageFile != null) ...[
              Image.memory(_imageFile!, height: 200),
              SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _takePicture,
              child: const Text('Tomar Foto'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Obtener Ubicación'),
            ),
            const SizedBox(height: 20),
            if (_currentLocation != null) ...[
              Text(
                'Lat: ${_currentLocation!.latitude}, Lng: ${_currentLocation!.longitude}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.8,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 15,
                  ),
                  markers: Set.from([
                    Marker(
                      markerId: MarkerId('current-location'),
                      position: _currentLocation!,
                    ),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
