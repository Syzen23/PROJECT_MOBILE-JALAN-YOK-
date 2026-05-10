import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_destination_model.dart';

/// Service untuk mengambil data destinasi wisata dari API eksternal
/// API dibuat oleh teman: https://github.com/Thaakie/Mobile_API
/// Base URL: https://mobile-api-beryl.vercel.app
class DestinationApiService {
  static const String _baseUrl = 'https://mobile-api-beryl.vercel.app';

  /// Singleton instance
  static final DestinationApiService instance = DestinationApiService._();
  DestinationApiService._();

  /// GET /api/data - Ambil semua destinasi wisata
  Future<List<ApiDestination>> getAllDestinations() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/data'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> dataList = body['data'];
          return dataList
              .map((json) => ApiDestination.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error fetching destinations from API: $e');
      return [];
    }
  }

  /// GET /api/data/{id} - Ambil satu destinasi by ID
  Future<ApiDestination?> getDestinationById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/data/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          return ApiDestination.fromJson(body['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching destination by id from API: $e');
      return null;
    }
  }

  /// Search destinasi secara lokal (fetch all lalu filter)
  /// API tidak menyediakan endpoint search, jadi filter di client side
  Future<List<ApiDestination>> searchDestinations(String query) async {
    final all = await getAllDestinations();
    if (query.isEmpty) return all;

    final lowerQuery = query.toLowerCase();
    return all.where((dest) {
      return dest.nama.toLowerCase().contains(lowerQuery) ||
          dest.kota.toLowerCase().contains(lowerQuery) ||
          dest.provinsi.toLowerCase().contains(lowerQuery) ||
          dest.kategori.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
