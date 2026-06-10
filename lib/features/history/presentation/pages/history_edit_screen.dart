import 'package:flutter/material.dart';
import 'package:jalanyok2/core/data/vehicle_database.dart';
import 'package:jalanyok2/core/repositories/vehicle_repository.dart';
import 'package:jalanyok2/core/services/firestore_service.dart';
import 'package:jalanyok2/features/plan/presentation/pages/budget_constants.dart';

class HistoryEditScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const HistoryEditScreen({super.key, required this.item});

  @override
  State<HistoryEditScreen> createState() => _HistoryEditScreenState();
}

class _HistoryEditScreenState extends State<HistoryEditScreen> {
  late final Map<String, dynamic> _item;
  late final Map<String, TextEditingController> _controllers;

  late String _transport;
  late String _fuelType;
  late String _tipeAkomodasi;
  late int _frekuensiMakan;
  late bool _isTiketOtomatis;
  late bool _isParkirOtomatis;
  late bool _isDanaDarurat;
  final TextEditingController _modelSearchController = TextEditingController();
  bool _searchIsMotor = false;
  String? _selectedMake;
  VehicleEntry? _selectedVehicle;
  List<String> _vehicleMakes = [];
  List<VehicleEntry> _vehicleResults = [];
  bool _isVehicleLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _item = Map<String, dynamic>.from(widget.item);

    final details = _mapOf(_item['details']);
    final form = _mapOf(details['form']);
    final state = _mapOf(details['state']);

    _controllers = {
      'budget': TextEditingController(
        text: _textValue(
          form,
          'budget',
          _item['total_budget']?.toString() ?? '',
        ),
      ),
      'bbm': TextEditingController(text: _textValue(form, 'bbm')),
      'jarak': TextEditingController(text: _textValue(form, 'jarak')),
      'tiket': TextEditingController(text: _textValue(form, 'tiket')),
      'parkir': TextEditingController(text: _textValue(form, 'parkir')),
      'makan': TextEditingController(text: _textValue(form, 'makan')),
      'penumpang': TextEditingController(
        text: _textValue(form, 'penumpang', '1'),
      ),
      'durasi': TextEditingController(text: _textValue(form, 'durasi', '1')),
      'hargaPenginapan': TextEditingController(
        text: _textValue(form, 'hargaPenginapan', '0'),
      ),
      'jumlahMalam': TextEditingController(
        text: _textValue(form, 'jumlahMalam', '0'),
      ),
      'jumlahKamar': TextEditingController(
        text: _textValue(form, 'jumlahKamar', '1'),
      ),
      'tol': TextEditingController(text: _textValue(form, 'tol')),
      'tiketTransport': TextEditingController(
        text: _textValue(form, 'tiketTransport'),
      ),
      'olehOleh': TextEditingController(text: _textValue(form, 'olehOleh')),
      'lainnya': TextEditingController(text: _textValue(form, 'lainnya')),
      'date': TextEditingController(text: _item['date']?.toString() ?? ''),
    };

    _transport = _textValue(
      state,
      'transport',
      _item['transport']?.toString() ?? 'Mobil',
    );
    _fuelType = _textValue(state, 'fuelType', 'Pertalite');
    _tipeAkomodasi = _textValue(state, 'tipeAkomodasi', 'Tidak Menginap');
    _frekuensiMakan = _intValue(state['frekuensiMakan'], 3);
    _isTiketOtomatis = _boolValue(state['isTiketOtomatis'], true);
    _isParkirOtomatis = _boolValue(state['isParkirOtomatis'], true);
    _isDanaDarurat = _boolValue(state['isDanaDarurat'], false);
    _selectedVehicle = _vehicleFromMap(state['selectedVehicle']);
    _searchIsMotor =
        _boolValue(state['searchIsMotor'], _transport == 'Motor') ||
        (_selectedVehicle?.isMotorcycle ?? false);
    _selectedMake = state['selectedMake']?.toString() ?? _selectedVehicle?.make;
    _loadVehicleMakes();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _modelSearchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _mapOf(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  String _textValue(
    Map<String, dynamic> map,
    String key, [
    String fallback = '',
  ]) {
    return map[key]?.toString() ?? fallback;
  }

  double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _intValue(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _boolValue(dynamic value, [bool fallback = false]) {
    return value is bool ? value : fallback;
  }

  VehicleEntry? _vehicleFromMap(dynamic value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    final make = map['make']?.toString() ?? '';
    final model = map['model']?.toString() ?? '';
    if (make.isEmpty && model.isEmpty) return null;

    return VehicleEntry(
      id: (map['id'] as num?)?.toInt(),
      make: make,
      model: model,
      type:
          map['type']?.toString() ??
          (_transport == 'Motor' ? 'Motor' : 'Mobil'),
      year: (map['year'] as num?)?.toInt(),
      transmission: map['transmission']?.toString(),
      colour: map['colour']?.toString(),
      tankCapacityLiter: (map['tankCapacityLiter'] as num?)?.toDouble(),
      price: (map['price'] as num?)?.toDouble(),
      engineCc: (map['engineCc'] as num?)?.toInt() ?? 0,
      fuelType: map['fuelType']?.toString() ?? 'Bensin',
      consumption: (map['consumption'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic>? _vehicleToMap(VehicleEntry? vehicle) {
    if (vehicle == null) return null;
    return {
      'id': vehicle.id,
      'make': vehicle.make,
      'model': vehicle.model,
      'type': vehicle.type,
      'year': vehicle.year,
      'transmission': vehicle.transmission,
      'colour': vehicle.colour,
      'tankCapacityLiter': vehicle.tankCapacityLiter,
      'price': vehicle.price,
      'engineCc': vehicle.engineCc,
      'fuelType': vehicle.fuelType,
      'consumption': vehicle.consumption,
    };
  }

  double _fieldDouble(String key) => _doubleValue(_controllers[key]?.text);

  int _fieldInt(String key, [int fallback = 0]) {
    return int.tryParse(_controllers[key]?.text ?? '') ?? fallback;
  }

  Future<void> _pickDate() async {
    final currentDate =
        DateTime.tryParse(_controllers['date']!.text) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      _controllers['date']!.text = selected.toIso8601String().split('T').first;
    }
  }

  Future<void> _loadVehicleMakes() async {
    setState(() => _isVehicleLoading = true);
    try {
      final makes = await VehicleRepository.instance.getMakes(
        isMotorcycle: _searchIsMotor,
      );
      if (!mounted) return;
      setState(() {
        _vehicleMakes = makes;
        _isVehicleLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _vehicleMakes = _searchIsMotor
            ? VehicleDatabase.motorcycleMakes
            : VehicleDatabase.carMakes;
        _isVehicleLoading = false;
      });
    }
  }

  Future<void> _changeVehicleKind(bool isMotor) async {
    setState(() {
      _searchIsMotor = isMotor;
      _selectedMake = null;
      _selectedVehicle = null;
      _vehicleResults = [];
      _modelSearchController.clear();
      _transport = isMotor ? 'Motor' : 'Mobil';
    });
    await _loadVehicleMakes();
  }

  Future<void> _loadVehiclesByMake(String make) async {
    setState(() {
      _selectedMake = make;
      _selectedVehicle = null;
      _vehicleResults = [];
      _isVehicleLoading = true;
      _modelSearchController.clear();
    });

    try {
      final results = await VehicleRepository.instance.searchVehicle(
        make: make,
        isMotorcycle: _searchIsMotor,
      );
      if (!mounted) return;
      setState(() {
        _vehicleResults = results;
        _isVehicleLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVehicleLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal fetch kendaraan: $e')));
    }
  }

  Future<void> _searchVehicle() async {
    final make = _selectedMake;
    if (make == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih merk kendaraan dulu.')),
      );
      return;
    }

    setState(() {
      _selectedVehicle = null;
      _isVehicleLoading = true;
    });

    try {
      final results = await VehicleRepository.instance.searchVehicle(
        make: make,
        model: _modelSearchController.text.trim(),
        isMotorcycle: _searchIsMotor,
      );
      if (!mounted) return;
      setState(() {
        _vehicleResults = results;
        _isVehicleLoading = false;
      });
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kendaraan tidak ditemukan.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVehicleLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal fetch kendaraan: $e')));
    }
  }

  void _selectVehicle(VehicleEntry vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
      _selectedMake = vehicle.make;
      _vehicleResults = [];
      _searchIsMotor = vehicle.isMotorcycle;
      _transport = vehicle.isMotorcycle ? 'Motor' : 'Mobil';
      _controllers['bbm']!.text = vehicle.consumption.toStringAsFixed(0);

      final apiFuelType = vehicle.fuelType;
      if (fuelTypes.any((fuel) => fuel['label'] == apiFuelType)) {
        _fuelType = apiFuelType;
      } else if (apiFuelType.toLowerCase().contains('solar') ||
          apiFuelType.toLowerCase().contains('dex')) {
        _fuelType = 'Solar';
      } else {
        _fuelType = 'Pertalite';
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${vehicle.displayName} dipilih.')));
  }

  Map<String, double> _calculateCosts() {
    final isKendaraanPribadi = _transport == 'Mobil' || _transport == 'Motor';
    final jarak = _fieldDouble('jarak');
    final konsumsiBbm = _fieldDouble('bbm');
    final penumpang = _fieldInt('penumpang', 1);
    final durasi = _fieldInt('durasi', 1);

    double hargaBbm = 10000;
    for (final fuel in fuelTypes) {
      if (fuel['label'] == _fuelType) {
        hargaBbm = fuel['harga'] as double;
        break;
      }
    }

    final costDetails = _mapOf(_mapOf(_item['details'])['biaya']);
    final savedTicket = _doubleValue(costDetails['tiket']);
    final bbm = isKendaraanPribadi && konsumsiBbm > 0
        ? (jarak / konsumsiBbm) * hargaBbm
        : 0.0;
    final tol = isKendaraanPribadi ? _fieldDouble('tol') : 0.0;
    final transportUmum = !isKendaraanPribadi
        ? _fieldDouble('tiketTransport')
        : 0.0;
    final tiket = _isTiketOtomatis
        ? (savedTicket > 0 ? savedTicket : 10000.0)
        : _fieldDouble('tiket');
    final parkir = _isParkirOtomatis
        ? (_transport == 'Motor' ? 5000.0 : 10000.0)
        : _fieldDouble('parkir');
    final makan = _fieldDouble('makan') * _frekuensiMakan * penumpang * durasi;
    final penginapan =
        _fieldDouble('hargaPenginapan') *
        _fieldInt('jumlahMalam') *
        _fieldInt('jumlahKamar', 1);
    final olehOleh = _fieldDouble('olehOleh');
    final lainnya = _fieldDouble('lainnya');
    final subtotal =
        bbm +
        tol +
        transportUmum +
        tiket +
        parkir +
        makan +
        penginapan +
        olehOleh +
        lainnya;
    final danaDarurat = _isDanaDarurat ? subtotal * 0.10 : 0.0;

    return {
      'bbm': bbm,
      'tol': tol,
      'transportUmum': transportUmum,
      'tiket': tiket,
      'parkir': parkir,
      'makan': makan,
      'penginapan': penginapan,
      'olehOleh': olehOleh,
      'lainnya': lainnya,
      'subtotal': subtotal,
      'danaDarurat': danaDarurat,
      'total': subtotal + danaDarurat,
    };
  }

  Future<void> _save() async {
    final historyId = _item['id']?.toString();
    final date = _controllers['date']!.text.trim();

    if (historyId == null || historyId.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data riwayat belum lengkap.')),
      );
      return;
    }

    final biaya = _calculateCosts();
    if ((biaya['total'] ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total budget harus lebih dari 0.')),
      );
      return;
    }

    final editedState = {
      'transport': _transport,
      'fuelType': _fuelType,
      'tipeAkomodasi': _tipeAkomodasi,
      'frekuensiMakan': _frekuensiMakan,
      'isTiketOtomatis': _isTiketOtomatis,
      'isParkirOtomatis': _isParkirOtomatis,
      'isDanaDarurat': _isDanaDarurat,
      'searchIsMotor': _searchIsMotor,
      'selectedMake': _selectedMake,
      'selectedVehicle': _vehicleToMap(_selectedVehicle),
    };
    final details = {
      'form': {
        for (final entry in _controllers.entries) entry.key: entry.value.text,
      }..remove('date'),
      'state': editedState,
      'biaya': biaya,
    };

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.updateTripHistory(historyId, {
        'transport': _transport,
        'total_budget': biaya['total'],
        'date': date,
        'details': details,
      });

      if (!mounted) return;
      final updatedItem = {
        ..._item,
        'transport': _transport,
        'total_budget': biaya['total'],
        'date': date,
        'details': details,
      };
      Navigator.pop(context, updatedItem);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update riwayat: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKendaraanPribadi = _transport == 'Mobil' || _transport == 'Motor';
    final hasSelectedVehicle = _selectedVehicle != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Budget Perjalanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _destinationHeader(),
                  _editSection(
                    'Transportasi & Kendaraan',
                    Icons.directions_car,
                    [
                      _editField(
                        'Budget',
                        _controllers['budget']!,
                        isNumber: true,
                      ),
                      _vehicleSearchSection(),
                      if (hasSelectedVehicle)
                        _selectedVehicleSummary()
                      else
                        _editDropdown<String>('Transportasi', _transport, [
                          'Mobil',
                          'Motor',
                          'Bus',
                          'Kereta',
                        ], _changeTransport),
                      if (isKendaraanPribadi) ...[
                        _editDropdown<String>(
                          'Jenis BBM',
                          _fuelType,
                          fuelTypes
                              .map((fuel) => fuel['label'] as String)
                              .toList(),
                          (value) => setState(() => _fuelType = value),
                        ),
                        _editField(
                          'Konsumsi BBM (km/l)',
                          _controllers['bbm']!,
                          isNumber: true,
                        ),
                        _editField(
                          'Jarak Tempuh (km)',
                          _controllers['jarak']!,
                          isNumber: true,
                        ),
                        _editField(
                          'Biaya Tol (PP)',
                          _controllers['tol']!,
                          isNumber: true,
                        ),
                      ] else
                        _editField(
                          'Harga Tiket $_transport (PP)',
                          _controllers['tiketTransport']!,
                          isNumber: true,
                        ),
                    ],
                  ),
                  _editSection('Detail Perjalanan', Icons.event_note, [
                    _editDateField(),
                    _editField(
                      'Jumlah Penumpang',
                      _controllers['penumpang']!,
                      isNumber: true,
                    ),
                    _editField(
                      'Durasi Perjalanan (hari)',
                      _controllers['durasi']!,
                      isNumber: true,
                    ),
                  ]),
                  _editSection('Akomodasi', Icons.hotel, [
                    _editDropdown<String>(
                      'Tipe Penginapan',
                      _tipeAkomodasi,
                      accommodationTypes
                          .map((item) => item['label'] as String)
                          .toList(),
                      (value) {
                        final match = accommodationTypes.firstWhere(
                          (item) => item['label'] == value,
                        );
                        _controllers['hargaPenginapan']!.text =
                            (match['harga'] as double).toStringAsFixed(0);
                        setState(() => _tipeAkomodasi = value);
                      },
                    ),
                    _editField(
                      'Harga per Malam',
                      _controllers['hargaPenginapan']!,
                      isNumber: true,
                    ),
                    _editField(
                      'Jumlah Malam',
                      _controllers['jumlahMalam']!,
                      isNumber: true,
                    ),
                    _editField(
                      'Jumlah Kamar',
                      _controllers['jumlahKamar']!,
                      isNumber: true,
                    ),
                  ]),
                  _editSection('Konsumsi / Makan', Icons.restaurant, [
                    _editField(
                      'Budget Makan (per orang/sekali makan)',
                      _controllers['makan']!,
                      isNumber: true,
                    ),
                    _editDropdown<int>(
                      'Frekuensi Makan per Hari',
                      _frekuensiMakan,
                      mealFrequencies
                          .map((item) => item['value'] as int)
                          .toList(),
                      (value) => setState(() => _frekuensiMakan = value),
                      labelFor: (value) =>
                          mealFrequencies.firstWhere(
                                (item) => item['value'] == value,
                              )['label']
                              as String,
                    ),
                  ]),
                  _editSection('Biaya Wisata', Icons.confirmation_number, [
                    _editSwitch(
                      'Tiket Masuk Otomatis',
                      _isTiketOtomatis,
                      (value) => setState(() => _isTiketOtomatis = value),
                    ),
                    _editField(
                      'Tiket Masuk',
                      _controllers['tiket']!,
                      isNumber: true,
                      enabled: !_isTiketOtomatis,
                    ),
                    _editSwitch(
                      'Parkir Otomatis',
                      _isParkirOtomatis,
                      (value) => setState(() => _isParkirOtomatis = value),
                    ),
                    _editField(
                      'Parkir',
                      _controllers['parkir']!,
                      isNumber: true,
                      enabled: !_isParkirOtomatis,
                    ),
                  ]),
                  _editSection('Biaya Lainnya', Icons.attach_money, [
                    _editField(
                      'Oleh-oleh / Belanja',
                      _controllers['olehOleh']!,
                      isNumber: true,
                    ),
                    _editField(
                      'Biaya Lain-lain',
                      _controllers['lainnya']!,
                      isNumber: true,
                    ),
                    _editSwitch(
                      'Dana Darurat (10%)',
                      _isDanaDarurat,
                      (value) => setState(() => _isDanaDarurat = value),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeTransport(String value) {
    final shouldReloadMakes = value == 'Mobil' || value == 'Motor';
    setState(() {
      _transport = value;
      if (shouldReloadMakes) {
        _searchIsMotor = value == 'Motor';
        _selectedMake = null;
        _vehicleResults = [];
      }
    });
    if (shouldReloadMakes) _loadVehicleMakes();
  }

  Widget _vehicleSearchSection() {
    final makes = _vehicleMakes.isNotEmpty
        ? _vehicleMakes
        : (_searchIsMotor
              ? VehicleDatabase.motorcycleMakes
              : VehicleDatabase.carMakes);
    final safeMake = makes.contains(_selectedMake) ? _selectedMake : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_car_filled,
                size: 16,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                'Cari Data Kendaraan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const Spacer(),
              if (_isVehicleLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Jenis:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Mobil', style: TextStyle(fontSize: 11)),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Motor', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                  selected: {_searchIsMotor},
                  onSelectionChanged: (selection) {
                    _changeVehicleKind(selection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _plainDropdown<String>(
            label: 'Merk Kendaraan',
            value: safeMake,
            hint: 'Pilih merk...',
            values: makes,
            onChanged: (value) {
              if (value != null) _loadVehiclesByMake(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _editField(
                  'Cari Model (opsional)',
                  _modelSearchController,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _isVehicleLoading ? null : _searchVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Icon(Icons.search, size: 18),
                ),
              ),
            ],
          ),
          if (_vehicleResults.isNotEmpty && _selectedVehicle == null) ...[
            const SizedBox(height: 12),
            Text(
              'Ditemukan ${_vehicleResults.length} kendaraan:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(4),
                itemCount: _vehicleResults.length,
                separatorBuilder: (_, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final vehicle = _vehicleResults[index];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${vehicle.detailInfo} | ${vehicle.consumption.toStringAsFixed(0)} km/l',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                    onTap: () => _selectVehicle(vehicle),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _selectedVehicleSummary() {
    final vehicle = _selectedVehicle!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF007AFF),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${vehicle.displayName} | $_transport',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () async {
                  setState(() => _selectedVehicle = null);
                  if (_selectedMake != null) {
                    await _loadVehiclesByMake(_selectedMake!);
                  }
                },
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _vehicleInfoRow(Icons.category, 'Tipe', vehicle.type),
          _vehicleInfoRow(Icons.local_gas_station, 'BBM', vehicle.fuelType),
          if (vehicle.engineCc > 0)
            _vehicleInfoRow(Icons.settings, 'Mesin', vehicle.engineDisplay),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.speed, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Konsumsi BBM: ${vehicle.consumption.toStringAsFixed(0)} km/l',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.deepPurple.shade300),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _destinationHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF007AFF).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _item['title']?.toString() ?? 'Tujuan Perjalanan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _item['location']?.toString() ?? '-',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF007AFF).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF007AFF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007AFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children.expand((child) => [child, const SizedBox(height: 12)]),
        ],
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.black : Colors.grey,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(bottom: 12),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _editDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(child: _editField('Tanggal', _controllers['date']!)),
    );
  }

  Widget _editDropdown<T>(
    String label,
    T value,
    List<T> values,
    ValueChanged<T> onChanged, {
    String Function(T value)? labelFor,
  }) {
    final safeValue = values.contains(value) ? value : values.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: safeValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: values
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(labelFor?.call(item) ?? item.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _plainDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<T> values,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: values
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(item.toString()),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _editSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
