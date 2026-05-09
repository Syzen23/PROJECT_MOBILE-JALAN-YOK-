import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jalanyok2/core/models/destination_model.dart';

// Top-level function for background JSON parsing
List<LatLng> parseRouteJson(String responseBody) {
  final data = json.decode(responseBody);
  List<LatLng> points = [];
  if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
    final geometry = data['routes'][0]['geometry']['coordinates'];
    for (var coord in geometry) {
      points.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
    }
  }
  return points;
}

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
      // 1. Get current location with safety timeout wrapper
      Position? position;
      try {
        position = await _determinePosition().timeout(const Duration(seconds: 5));
      } catch (e) {
        // Fallback Monas, Jakarta if Geolocator completely hangs
        position = Position(
          latitude: -6.175392,
          longitude: 106.827153,
          timestamp: DateTime.now(),
          accuracy: 100,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
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

    // Coba ambil lokasi terakhir yang diketahui (lebih cepat untuk emulator)
    Position? lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      return lastKnown;
    }

    try {
      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );
    } catch (e) {
      // Jika GPS Emulator tersangkut/timeout, gunakan lokasi default (Monas, Jakarta)
      return Position(
        latitude: -6.175392,
        longitude: 106.827153,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  Future<LatLng?> _geocodeDestination(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'JalanYokApp/1.0'}).timeout(const Duration(seconds: 10));
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
    // Menggunakan overview=simplified agar tidak mendownload puluhan ribu titik yang bikin ngelag (ANR)
    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=simplified&geometries=geojson');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        // Parse JSON in background isolate to prevent ANR (UI thread block)
        final points = await compute(parseRouteJson, response.body);
        setState(() {
          _routePoints = points;
        });
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
                    if (_routePoints.isNotEmpty)
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
