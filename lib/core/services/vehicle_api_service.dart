import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/vehicle_database.dart';

class VehicleApiService {
  static const String _baseUrl = 'https://mobile-api-beryl.vercel.app';

  static List<VehicleEntry>? _cache;

  static Future<List<VehicleEntry>> getAllVehicles({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/kendaraan'), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('VehicleApiService Error: ${response.statusCode} - ${response.body}');
        return VehicleDatabase.vehicles;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (body['success'] != true || data == null) return VehicleDatabase.vehicles;

      final vehicles = <VehicleEntry>[
        ..._parseVehicleList(data['mobil']),
        ..._parseVehicleList(data['motor']),
      ];

      _cache = vehicles;
      return vehicles;
    } catch (e) {
      print('VehicleApiService Error: $e');
      return VehicleDatabase.vehicles;
    }
  }

  static Future<List<String>> getMakes({required bool isMotorcycle}) async {
    final vehicles = await getAllVehicles();
    final makes = vehicles
        .where((vehicle) => vehicle.isMotorcycle == isMotorcycle)
        .map((vehicle) => vehicle.make)
        .where((make) => make.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return makes;
  }

  static Future<List<VehicleEntry>> searchVehicle({
    required String make,
    String? model,
    bool? isMotorcycle,
  }) async {
    final query = (model ?? '').toLowerCase();
    final vehicles = await getAllVehicles();

    return vehicles.where((vehicle) {
      final matchesKind = isMotorcycle == null || vehicle.isMotorcycle == isMotorcycle;
      final matchesMake = vehicle.make.toLowerCase() == make.toLowerCase();
      final matchesModel = query.isEmpty || vehicle.model.toLowerCase().contains(query);
      return matchesKind && matchesMake && matchesModel;
    }).toList();
  }

  static List<VehicleEntry> _parseVehicleList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(VehicleEntry.fromApiJson)
        .toList();
  }
}
