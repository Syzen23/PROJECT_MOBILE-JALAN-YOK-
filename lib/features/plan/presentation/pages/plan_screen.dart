import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jalanyok2/core/services/firestore_service.dart';
import 'package:jalanyok2/core/models/destination_model.dart';
import 'package:jalanyok2/core/services/auth_service.dart';
import 'package:jalanyok2/core/models/trip_history_model.dart';
import 'budget_constants.dart';
import 'budget_form_tab.dart';
import 'budget_result_tab.dart';
import 'map_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with SingleTickerProviderStateMixin {
  // Controllers
  final Map<String, TextEditingController> _controllers = {
    'budget': TextEditingController(),
    'bbm': TextEditingController(),
    'jarak': TextEditingController(),
    'tiket': TextEditingController(),
    'parkir': TextEditingController(),
    'makan': TextEditingController(),
    'penumpang': TextEditingController(text: '1'),
    'durasi': TextEditingController(text: '1'),
    'hargaPenginapan': TextEditingController(text: '0'),
    'jumlahMalam': TextEditingController(text: '0'),
    'jumlahKamar': TextEditingController(text: '1'),
    'tol': TextEditingController(),
    'tiketTransport': TextEditingController(),
    'olehOleh': TextEditingController(),
    'lainnya': TextEditingController(),
    'platNomor': TextEditingController(),
    'modelSearch': TextEditingController(),
  };

  // State
  final Map<String, dynamic> _state = {
    'transport': 'Mobil',
    'tipeKendaraan': null,
    'fuelType': 'Pertalite',
    'tipeAkomodasi': 'Tidak Menginap',
    'frekuensiMakan': 3,
    'isTiketOtomatis': true,
    'isParkirOtomatis': true,
    'isDanaDarurat': false,
    'selectedVehicle': null,
    'selectedMake': null,
    'searchResults': <dynamic>[],
  };

  // Results
  final Map<String, double> _biaya = {
    'bbm': 0, 'tol': 0, 'transportUmum': 0, 'tiket': 0, 'parkir': 0,
    'makan': 0, 'penginapan': 0, 'olehOleh': 0, 'lainnya': 0,
    'subtotal': 0, 'danaDarurat': 0, 'total': 0,
  };

  // Destination
  List<Destination> destinations = [];
  Destination? _selectedDestination;
  bool _isLoading = true;

  // Location
  String _currentLocationName = 'Mendeteksi lokasi...';
  bool _locationError = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCurrentLocation();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    final data = await FirestoreService.instance.getAllDestinations();
    setState(() { destinations = data; if (destinations.isNotEmpty) _selectedDestination = destinations[0]; _isLoading = false; });
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _currentLocationName = 'GPS mati. Ketuk untuk coba lagi'; _locationError = true; });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Aktifkan GPS/Lokasi di pengaturan HP Anda'), action: SnackBarAction(label: 'BUKA', onPressed: () => Geolocator.openLocationSettings())));
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { setState(() { _currentLocationName = 'Izin lokasi ditolak'; _locationError = true; }); return; }
      }
      if (permission == LocationPermission.deniedForever) { setState(() { _currentLocationName = 'Izin lokasi ditolak permanen'; _locationError = true; }); return; }
      setState(() { _currentLocationName = 'Mendeteksi lokasi...'; _locationError = false; });
      Position position;
      try { position = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 5)); }
      catch (e) {
        Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) { position = lastKnown; } else { setState(() { _currentLocationName = 'Lokasi tidak ditemukan'; _locationError = true; }); return; }
      }
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&zoom=14');
        final response = await http.get(url, headers: {'User-Agent': 'JalanYokApp/1.0'}).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body); final address = data['address'];
          String placeName = address['suburb'] ?? address['village'] ?? address['city_district'] ?? address['city'] ?? address['town'] ?? address['county'] ?? 'Lokasi Ditemukan';
          String city = address['city'] ?? address['town'] ?? address['county'] ?? '';
          setState(() { _currentLocationName = city.isNotEmpty && placeName != city ? '$placeName, $city' : placeName; _locationError = false; });
        } else { setState(() { _currentLocationName = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}'; _locationError = false; }); }
      } catch (e) { setState(() { _currentLocationName = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}'; _locationError = false; }); }
    } catch (e) { setState(() { _currentLocationName = 'Gagal mendeteksi lokasi'; _locationError = true; }); }
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    _tabController.dispose();
    super.dispose();
  }

  void _onStateChanged(String key, dynamic value) {
    setState(() => _state[key] = value);
  }

  void _hitungBudget() {
    if (_selectedDestination == null) return;
    final transport = _state['transport'] as String;
    final fuelType = _state['fuelType'] as String;
    final isKendaraanPribadi = transport == 'Mobil' || transport == 'Motor';
    final jarak = double.tryParse(_controllers['jarak']!.text) ?? 0;
    final konsumsiBbm = double.tryParse(_controllers['bbm']!.text) ?? 0;
    final penumpang = int.tryParse(_controllers['penumpang']!.text) ?? 1;
    final durasi = int.tryParse(_controllers['durasi']!.text) ?? 1;
    final frekuensiMakan = _state['frekuensiMakan'] as int;

    // Get fuel price
    double hargaBbm = 10000;
    for (var f in fuelTypes) { if (f['label'] == fuelType) { hargaBbm = f['harga'] as double; break; } }

    // 1. BBM
    _biaya['bbm'] = isKendaraanPribadi && konsumsiBbm > 0 ? (jarak / konsumsiBbm) * hargaBbm : 0;
    // 2. Tol
    _biaya['tol'] = isKendaraanPribadi ? (double.tryParse(_controllers['tol']!.text) ?? 0) : 0;
    // 3. Transport umum
    _biaya['transportUmum'] = !isKendaraanPribadi ? (double.tryParse(_controllers['tiketTransport']!.text) ?? 0) : 0;
    // 4. Tiket masuk
    _biaya['tiket'] = (_state['isTiketOtomatis'] as bool) ? _selectedDestination!.tiket : (double.tryParse(_controllers['tiket']!.text) ?? 0);
    // 5. Parkir
    _biaya['parkir'] = (_state['isParkirOtomatis'] as bool) ? (transport == 'Motor' ? 5000 : 10000) : (double.tryParse(_controllers['parkir']!.text) ?? 0);
    // 6. Makan
    final budgetMakan = double.tryParse(_controllers['makan']!.text) ?? 0;
    _biaya['makan'] = budgetMakan * frekuensiMakan * penumpang * durasi;
    // 7. Penginapan
    final hargaMalam = double.tryParse(_controllers['hargaPenginapan']!.text) ?? 0;
    final jumlahMalam = int.tryParse(_controllers['jumlahMalam']!.text) ?? 0;
    final jumlahKamar = int.tryParse(_controllers['jumlahKamar']!.text) ?? 1;
    _biaya['penginapan'] = hargaMalam * jumlahMalam * jumlahKamar;
    // 8. Oleh-oleh
    _biaya['olehOleh'] = double.tryParse(_controllers['olehOleh']!.text) ?? 0;
    // 9. Lain-lain
    _biaya['lainnya'] = double.tryParse(_controllers['lainnya']!.text) ?? 0;
    // Subtotal
    _biaya['subtotal'] = _biaya['bbm']! + _biaya['tol']! + _biaya['transportUmum']! + _biaya['tiket']! + _biaya['parkir']! + _biaya['makan']! + _biaya['penginapan']! + _biaya['olehOleh']! + _biaya['lainnya']!;
    // 10. Dana darurat
    _biaya['danaDarurat'] = (_state['isDanaDarurat'] as bool) ? _biaya['subtotal']! * 0.10 : 0;
    // Total
    _biaya['total'] = _biaya['subtotal']! + _biaya['danaDarurat']!;

    setState(() {});
    _tabController.animateTo(1);
  }

  Future<void> _simpanKeRiwayat() async {
    final user = await AuthService.getCurrentUser();
    if (user == null || _selectedDestination == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap login dan pilih destinasi.')));
      return;
    }
    final history = TripHistory(userId: user.id!, destinationId: _selectedDestination!.id!, transport: _state['transport'] as String, totalBudget: _biaya['total'] ?? 0, date: DateTime.now().toIso8601String().split('T').first);
    await FirestoreService.instance.insertTripHistory(history);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil disimpan ke Riwayat!')));
  }

  void _bukaPeta() {
    if (_selectedDestination == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(destination: _selectedDestination!)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: Color(0xFF007AFF))));
    return Scaffold(backgroundColor: Colors.white, body: Column(children: [
      _buildHeader(),
      _buildTabBar(),
      Expanded(child: Container(color: Colors.white, padding: const EdgeInsets.all(16),
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade300)),
          child: TabBarView(controller: _tabController, physics: const NeverScrollableScrollPhysics(), children: [
            BudgetFormTab(state: _state, controllers: _controllers, onHitung: _hitungBudget, onStateChanged: _onStateChanged, destinations: destinations, selectedDestination: _selectedDestination, onDestinationChanged: (d) => setState(() => _selectedDestination = d)),
            BudgetResultTab(biaya: _biaya, state: _state, controllers: _controllers, onEdit: () => _tabController.animateTo(0), onBukaPeta: _bukaPeta, onSimpan: _simpanKeRiwayat),
          ])))),
    ]));
  }

  Widget _buildHeader() {
    return Stack(children: [
      Container(width: double.infinity, height: 200, decoration: const BoxDecoration(color: Color(0xFF007AFF), image: DecorationImage(image: AssetImage('assets/images/travel.jpg'), fit: BoxFit.cover))),
      SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 32),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(children: [
            Column(children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.2), shape: BoxShape.circle), child: Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle)))),
              Container(width: 2, height: 24, color: Colors.grey.shade300),
              const Icon(Icons.location_on, color: Colors.red, size: 16),
            ]),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(onTap: _locationError ? _fetchCurrentLocation : null, child: Row(children: [
                if (!_locationError) const Icon(Icons.my_location, size: 12, color: Colors.green) else const Icon(Icons.location_off, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(child: Text(_currentLocationName, style: TextStyle(color: _locationError ? Colors.red : Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                if (_locationError) const Icon(Icons.refresh, size: 12, color: Colors.blue),
              ])),
              const Divider(height: 16),
              Autocomplete<Destination>(
                initialValue: TextEditingValue(text: _selectedDestination?.title ?? ''),
                displayStringForOption: (o) => o.title,
                optionsBuilder: (v) => v.text.isEmpty ? destinations : destinations.where((o) => o.title.toLowerCase().contains(v.text.toLowerCase())),
                onSelected: (s) => setState(() => _selectedDestination = s),
                fieldViewBuilder: (context, ctrl, node, onSubmit) => TextField(controller: ctrl, focusNode: node,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none, hintText: 'Cari Tujuan...', hintStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey))),
              ),
            ])),
          ])),
      ]))),
    ]);
  }

  Widget _buildTabBar() {
    return Container(color: Colors.white, child: TabBar(controller: _tabController, labelColor: Colors.orange, unselectedLabelColor: Colors.grey, indicatorColor: Colors.orange, indicatorWeight: 3, tabs: const [Tab(text: 'Hitung Budget'), Tab(text: 'Hasil')]));
  }
}
