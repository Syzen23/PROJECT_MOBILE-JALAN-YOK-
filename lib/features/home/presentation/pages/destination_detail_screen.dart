import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/api_destination_model.dart';
import '../../../../core/widgets/cached_app_image.dart';

class DestinationDetailScreen extends StatelessWidget {
  final ApiDestination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background sedikit off-white
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: false,
                backgroundColor: const Color(0xFFF8F9FA),
                elevation: 0,
                automaticallyImplyLeading:
                    false, // Disembunyikan karena kita buat tombol custom di Stack
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedAppImage(
                        imageUrl: destination.gambar,
                        fit: BoxFit.cover,
                        memCacheWidth: 900,
                        memCacheHeight: 640,
                      ),
                      // Lengkungan bagian bawah gambar (berwarna putih membulat tumpul)
                      Positioned(
                        bottom: -1, // Menghindari garis celah pixel
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                40,
                              ), // Dibuat lebih tumpul dan rapi
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFF8F9FA),
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        destination.nama,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF007AFF),
                              fontSize: 28,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Kategori badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFF007AFF,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          destination.kategori,
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Meta (Lokasi, Rating)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.black87,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              destination.lokasi,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${destination.rating} (Grade)',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Tentang Wisata
                      const Text(
                        'Tentang wisata',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Deskripsi dari API
                      Text(
                        destination.deskripsi.isNotEmpty
                            ? destination.deskripsi
                            : 'Deskripsi belum tersedia untuk destinasi ini.',
                        style: const TextStyle(
                          color: Colors.black87,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tombol Kembali (Custom Fixed Position)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 4.0,
                  ), // Agar panah berada pas di tengah lingkaran
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // Tombol Bawah Tetap (Rencanakan Perjalanan)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24,
                top: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFF8F9FA).withValues(alpha: 0.8),
                    const Color(0xFFF8F9FA).withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/plan');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Rencanakan Perjalanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
