import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jalanyok2/core/models/destination_model.dart';

class MapScreen extends StatefulWidget {
  final Destination destination;

  const MapScreen({super.key, required this.destination});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  Future<void> _initMapData() async {
    try {
      // 1. Get current location
      Position position = await _determinePosition();
      _currentPosition = LatLng(position.latitude, position.longitude);

      // 2. Geocode destination
      _destinationPosition = await _geocodeDestination('${widget.destination.title} ${widget.destination.location}');

      if (_destinationPosition != null && _currentPosition != null) {
        // 3. Get Route
        await _fetchRoute(_currentPosition!, _destinationPosition!);
      } else {
        setState(() {
          _errorMessage = "Gagal menemukan lokasi tujuan di peta.";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi dinonaktifkan. Aktifkan GPS Anda.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Buka pengaturan aplikasi.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<LatLng?> _geocodeDestination(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'JalanYokApp/1.0'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
        }
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
    return null;
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry']['coordinates'];
          List<LatLng> points = [];
          for (var coord in geometry) {
            points.add(LatLng(coord[1].toDouble(), coord[0].toDouble())); // OSRM returns [lon, lat]
          }
          setState(() {
            _routePoints = points;
          });
        }
      }
    } catch (e) {
      debugPrint("Routing error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Perjalanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF007AFF)),
                  SizedBox(height: 16),
                  Text('Menyiapkan peta dan rute...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.jalanyok2',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: const Color(0xFF007AFF),
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                        ),
                        Marker(
                          point: _destinationPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
