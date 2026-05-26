import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_data_model.dart';

class VehicleApiService {
  // API-Ninjas Cars API (Free: 50,000 requests/month)
  // Daftar gratis di https://api-ninjas.com untuk dapat API key
  static const String _baseUrl = 'https://api.api-ninjas.com/v1/cars';
  static const String _apiKey = 'YOUR_API_KEY_HERE'; // Ganti dengan API key kamu

  /// Cari kendaraan berdasarkan merk dan model.
  /// Returns list of [VehicleData] yang cocok.
  static Future<List<VehicleData>> searchVehicle({
    required String make,
    String? model,
    int? year,
  }) async {
    try {
      final params = <String, String>{
        'make': make.toLowerCase(),
        'limit': '30',
      };

      if (model != null && model.isNotEmpty) {
        params['model'] = model.toLowerCase();
      }
      if (year != null) {
        params['year'] = year.toString();
      }

      final url = Uri.parse(_baseUrl).replace(queryParameters: params);

      final response = await http.get(
        url,
        headers: {
          'X-Api-Key': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('VehicleApiService Error: ${response.statusCode} - ${response.body}');
        return [];
      }

      final List<dynamic> data = json.decode(response.body);

      return data.map((item) => VehicleData.fromApiNinjas(item)).toList();
    } catch (e) {
      print('VehicleApiService Error: $e');
      return [];
    }
  }

  /// Daftar merk kendaraan populer di Indonesia
  static const List<String> popularMakes = [
    'Toyota',
    'Honda',
    'Suzuki',
    'Daihatsu',
    'Mitsubishi',
    'Nissan',
    'Hyundai',
    'Kia',
    'Mazda',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Volkswagen',
    'Ford',
    'Chevrolet',
    'Isuzu',
    'Subaru',
    'Wuling',
    'MG',
  ];
}
