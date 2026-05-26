import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_data_model.dart';

class NopolService {
  static const String _baseUrl = 'https://www.nopol.id/api/reg.asmx/CheckIndonesia';
  static const String _username = 'Erwin';

  /// Lookup vehicle data by Indonesian plate number.
  /// Returns [VehicleData] on success, null on failure.
  static Future<VehicleData?> lookupPlate(String plateNumber) async {
    try {
      // Clean the plate number: remove spaces, dashes
      final cleanPlate = plateNumber.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

      if (cleanPlate.isEmpty) return null;

      final url = Uri.parse(
        '$_baseUrl?RegistrationNumber=$cleanPlate&username=$_username',
      );

      final response = await http.get(
        url,
        headers: {'Accept': 'application/xml'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      // Parse XML response → extract vehicleJson
      final body = response.body;

      // Extract JSON from <vehicleJson> tag
      final jsonStart = body.indexOf('<vehicleJson>');
      final jsonEnd = body.indexOf('</vehicleJson>');

      if (jsonStart == -1 || jsonEnd == -1) return null;

      final jsonString = body.substring(
        jsonStart + '<vehicleJson>'.length,
        jsonEnd,
      ).trim();

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Check if we got valid data
      if (jsonData['Description'] == null || jsonData['Description'].toString().isEmpty) {
        return null;
      }

      return VehicleData.fromJson(jsonData);
    } catch (e) {
      print('NopolService Error: $e');
      return null;
    }
  }
}
