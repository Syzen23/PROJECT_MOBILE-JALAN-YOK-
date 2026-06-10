import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/api_destination_model.dart';
import '../../../../core/repositories/destination_repository.dart';
import '../../../../core/widgets/cached_app_image.dart';
import 'destination_detail_screen.dart';

class AllDestinationsScreen extends StatefulWidget {
  const AllDestinationsScreen({super.key});

  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen> {
  List<ApiDestination> _allDestinations = [];
  List<ApiDestination> _filteredDestinations = [];
  bool _isLoading = true;

  // Filter state
  final TextEditingController _searchController = TextEditingController();
  String? _selectedKategori;
  String? _selectedProvinsi;
  String _sortBy = 'rating'; // 'rating', 'nama', 'provinsi'
  bool _showFilters = false;
  Timer? _filterDebounce;

  // Available filter options (populated from API data)
  List<String> _kategoriList = [];
  List<String> _provinsiList = [];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _searchController.addListener(_onSearchFilterChanged);
  }

  @override
  void dispose() {
    _filterDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    setState(() => _isLoading = true);

    final data = await DestinationRepository.instance.getAllDestinations();

    // Extract unique kategori & provinsi dari data API
    final kategoriSet = <String>{};
    final provinsiSet = <String>{};
    for (var dest in data) {
      if (dest.kategori.isNotEmpty) kategoriSet.add(dest.kategori);
      if (dest.provinsi.isNotEmpty) provinsiSet.add(dest.provinsi);
    }

    setState(() {
      _allDestinations = data;
      _kategoriList = kategoriSet.toList()..sort();
      _provinsiList = provinsiSet.toList()..sort();
      _isLoading = false;
    });

    _applyFilters();
  }

  void _onSearchFilterChanged() {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(const Duration(milliseconds: 250), _applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<ApiDestination> results = List.from(_allDestinations);

    // Filter by search query
    if (query.isNotEmpty) {
      results = results.where((d) {
        return d.nama.toLowerCase().contains(query) ||
            d.kota.toLowerCase().contains(query) ||
            d.provinsi.toLowerCase().contains(query) ||
            d.kategori.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by kategori
    if (_selectedKategori != null) {
      results = results.where((d) => d.kategori == _selectedKategori).toList();
    }

    // Filter by provinsi
    if (_selectedProvinsi != null) {
      results = results.where((d) => d.provinsi == _selectedProvinsi).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'nama':
        results.sort((a, b) => a.nama.compareTo(b.nama));
        break;
      case 'provinsi':
        results.sort((a, b) => a.provinsi.compareTo(b.provinsi));
        break;
    }

    setState(() {
      _filteredDestinations = results;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedKategori = null;
      _selectedProvinsi = null;
      _sortBy = 'rating';
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _selectedKategori != null ||
      _selectedProvinsi != null ||
      _searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Semua Destinasi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Filter toggle button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                setState(() => _showFilters = !_showFilters);
              },
              icon: Badge(
                isLabelVisible: _hasActiveFilters,
                backgroundColor: const Color(0xFF007AFF),
                smallSize: 8,
                child: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: _showFilters
                      ? const Color(0xFF007AFF)
                      : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Cari nama, kota, atau provinsi...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 18,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Filter Panel (collapsible)
          if (_showFilters) _buildFilterPanel(),

          // Result count + sort
          _buildResultHeader(),

          // Destinations Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF007AFF)),
                  )
                : _filteredDestinations.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    color: const Color(0xFF007AFF),
                    onRefresh: _loadDestinations,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _filteredDestinations.length,
                      itemBuilder: (context, index) {
                        return _buildGridCard(_filteredDestinations[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),

          // Header with clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_hasActiveFilters)
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: const Text(
                    'Reset Filter',
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

          // Kategori chips
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _kategoriList.length,
              itemBuilder: (context, index) {
                final kategori = _kategoriList[index];
                final isSelected = _selectedKategori == kategori;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedKategori = isSelected ? null : kategori;
                      });
                      _applyFilters();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF007AFF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF007AFF)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getKategoriIcon(kategori),
                            size: 14,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            kategori,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Provinsi dropdown
          const Text(
            'Provinsi',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedProvinsi != null
                    ? const Color(0xFF007AFF)
                    : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProvinsi,
                isExpanded: true,
                hint: Text(
                  'Semua Provinsi',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Semua Provinsi',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  ..._provinsiList.map((prov) {
                    return DropdownMenuItem<String>(
                      value: prov,
                      child: Text(prov),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedProvinsi = value);
                  _applyFilters();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredDestinations.length} destinasi ditemukan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Sort dropdown
          PopupMenuButton<String>(
            initialValue: _sortBy,
            onSelected: (value) {
              setState(() => _sortBy = value);
              _applyFilters();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(0, 36),
            itemBuilder: (context) => [
              _buildSortItem('rating', 'Rating Tertinggi', Icons.star),
              _buildSortItem('nama', 'Nama A-Z', Icons.sort_by_alpha),
              _buildSortItem('provinsi', 'Provinsi A-Z', Icons.map),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 14, color: Color(0xFF007AFF)),
                  const SizedBox(width: 4),
                  Text(
                    _getSortLabel(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: Color(0xFF007AFF),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortItem(
    String value,
    String label,
    IconData icon,
  ) {
    final isActive = _sortBy == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? const Color(0xFF007AFF) : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? const Color(0xFF007AFF) : Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'rating':
        return 'Rating';
      case 'nama':
        return 'Nama';
      case 'provinsi':
        return 'Provinsi';
      default:
        return 'Urutkan';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada destinasi yang cocok',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset Filter', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildGridCard(ApiDestination dest) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(destination: dest),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badges
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedAppImage(
                      imageUrl: dest.gambar,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      memCacheWidth: 360,
                      memCacheHeight: 280,
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            dest.rating.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Kategori badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dest.kategori,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            dest.lokasi,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DestinationDetailScreen(destination: dest),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Lihat Detail',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getKategoriIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'pantai':
        return Icons.beach_access;
      case 'gunung':
        return Icons.terrain;
      case 'danau':
        return Icons.water;
      case 'budaya':
        return Icons.temple_buddhist;
      case 'taman nasional':
        return Icons.park;
      case 'air terjun':
        return Icons.waterfall_chart;
      case 'pulau':
        return Icons.sailing;
      default:
        return Icons.place;
    }
  }
}
