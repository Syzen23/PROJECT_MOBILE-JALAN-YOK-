/// Model untuk destinasi wisata dari API eksternal
/// Base URL: https://mobile-api-beryl.vercel.app
/// Endpoint: GET /api/data
class ApiDestination {
  final int id;
  final String nama;
  final String kategori;
  final String kota;
  final String provinsi;
  final double rating;
  final String gambar;
  final String deskripsi;

  ApiDestination({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.kota,
    required this.provinsi,
    required this.rating,
    required this.gambar,
    required this.deskripsi,
  });

  /// Parse dari JSON response API
  factory ApiDestination.fromJson(Map<String, dynamic> json) {
    return ApiDestination(
      id: json['id'] as int,
      nama: json['nama'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      kota: json['kota'] as String? ?? '',
      provinsi: json['provinsi'] as String? ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      gambar: json['gambar'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
    );
  }

  /// Lokasi gabungan: "Kota, Provinsi"
  String get lokasi {
    if (kota.isNotEmpty && provinsi.isNotEmpty) {
      return '$kota, $provinsi';
    }
    return kota.isNotEmpty ? kota : provinsi;
  }
}
