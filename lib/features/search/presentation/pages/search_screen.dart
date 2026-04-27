import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showResults = false;

  final List<String> _riwayatPencarian = [
    'Pantai Marina',
    'Gunung Bromo',
    'Pantai Kuta',
  ];

  final List<String> _pencarianPopuler = [
    'Pantai Kelingking',
    'Pantai',
    'Pulau Pahawang',
    'Tari Kecak',
    'Candi Borobudur',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showResults = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 8,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 8.0),
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
            ),
          ),
        ),
        leadingWidth: 64, // 24 padding + 40 width
        title: const Text(
          'Pencarian',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blue.shade400, width: 1.0),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Cari destinasi wisata....',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          
          Divider(color: Colors.blue.shade100, thickness: 1, height: 1),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _showResults ? _buildSearchResults() : _buildInitialState(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riwayat Pencarian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat pencarian',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _riwayatPencarian.clear();
                  });
                },
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _riwayatPencarian.map((item) {
              return _buildChip(item, isHistory: true);
            }).toList(),
          ),
          
          const SizedBox(height: 32),

          // Pencarian populer
          const Text(
            'Pencarian populer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _pencarianPopuler.map((item) {
              return _buildChip(item, isHistory: false);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required bool isHistory}) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHistory) ...[
              const Icon(Icons.history, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // Dummy results matching the figma
    final resultTemplate = {
      'title': 'Pantai Marina',
      'location': 'Kalianda, Lampung',
      'image': 'assets/images/Pantai.png',
      'rating': 4.8,
      'visitors': '1K+ Pengunjung',
      'price': 'Tiket masuk: Rp 45.000',
    };

    final results = List.generate(5, (index) => resultTemplate);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item['image'],
                width: 80,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 90,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, right: 12.0, bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.location_on, Colors.black87, item['location']),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.star, Colors.amber, "${item['rating']} (Grade)"),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.people_outline, const Color(0xFF007AFF), item['visitors']),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.confirmation_num_outlined, Colors.green, item['price']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 12),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
