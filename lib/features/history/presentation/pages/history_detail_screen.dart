import 'package:flutter/material.dart';
import 'package:jalanyok2/core/models/destination_model.dart';
import 'package:jalanyok2/core/services/firestore_service.dart';
import 'package:jalanyok2/core/widgets/cached_app_image.dart';
import 'package:jalanyok2/features/plan/presentation/pages/budget_constants.dart';
import 'package:jalanyok2/features/plan/presentation/pages/map_screen.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Map<String, dynamic> item;

  @override
  void initState() {
    super.initState();
    item = Map<String, dynamic>.from(widget.item);
  }

  Map<String, dynamic> get _details {
    final details = item['details'];
    return details is Map ? Map<String, dynamic>.from(details) : {};
  }

  Map<String, dynamic> get _formDetails {
    final form = _details['form'];
    return form is Map ? Map<String, dynamic>.from(form) : {};
  }

  Map<String, dynamic> get _stateDetails {
    final state = _details['state'];
    return state is Map ? Map<String, dynamic>.from(state) : {};
  }

  Map<String, dynamic> get _costDetails {
    final biaya = _details['biaya'];
    return biaya is Map ? Map<String, dynamic>.from(biaya) : {};
  }

  String _textValue(
    Map<String, dynamic> map,
    String key, [
    String fallback = '',
  ]) {
    final value = map[key];
    return value?.toString() ?? fallback;
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

  String _fmtCurrency(dynamic value) {
    final raw = _doubleValue(value).toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  Destination _destinationFromHistory() {
    return Destination(
      id: item['destination_id']?.toString(),
      title: item['title']?.toString() ?? 'Tujuan Perjalanan',
      location: item['location']?.toString() ?? '',
      image: item['image']?.toString() ?? '',
      rating: 0,
      visitors: '',
      tiket: 0,
      waktu: 0,
    );
  }

  Future<void> _openRoute() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(destination: _destinationFromHistory()),
      ),
    );
  }

  Future<void> _showEditDialog() async {
    final form = _formDetails;
    final state = _stateDetails;

    final controllers = <String, TextEditingController>{
      'budget': TextEditingController(
        text: _textValue(
          form,
          'budget',
          item['total_budget']?.toString() ?? '',
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
      'date': TextEditingController(text: item['date']?.toString() ?? ''),
    };

    var transport = _textValue(
      state,
      'transport',
      item['transport']?.toString() ?? 'Mobil',
    );
    var fuelType = _textValue(state, 'fuelType', 'Pertalite');
    var tipeAkomodasi = _textValue(state, 'tipeAkomodasi', 'Tidak Menginap');
    var frekuensiMakan = _intValue(state['frekuensiMakan'], 3);
    var isTiketOtomatis = _boolValue(state['isTiketOtomatis'], true);
    var isParkirOtomatis = _boolValue(state['isParkirOtomatis'], true);
    var isDanaDarurat = _boolValue(state['isDanaDarurat'], false);

    final saved = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Edit Budget Perjalanan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: Column(
                          children: [
                            _editSection(
                              'Transportasi & Kendaraan',
                              Icons.directions_car,
                              [
                                _editField(
                                  'Budget',
                                  controllers['budget']!,
                                  isNumber: true,
                                ),
                                _editDropdown<String>(
                                  'Transportasi',
                                  transport,
                                  ['Mobil', 'Motor', 'Bus', 'Kereta'],
                                  (value) =>
                                      setDialogState(() => transport = value),
                                ),
                                if (transport == 'Mobil' ||
                                    transport == 'Motor') ...[
                                  _editDropdown<String>(
                                    'Jenis BBM',
                                    fuelType,
                                    fuelTypes
                                        .map((fuel) => fuel['label'] as String)
                                        .toList(),
                                    (value) =>
                                        setDialogState(() => fuelType = value),
                                  ),
                                  _editField(
                                    'Konsumsi BBM (km/l)',
                                    controllers['bbm']!,
                                    isNumber: true,
                                  ),
                                  _editField(
                                    'Jarak Tempuh (km)',
                                    controllers['jarak']!,
                                    isNumber: true,
                                  ),
                                  _editField(
                                    'Biaya Tol (PP)',
                                    controllers['tol']!,
                                    isNumber: true,
                                  ),
                                ] else
                                  _editField(
                                    'Harga Tiket $transport (PP)',
                                    controllers['tiketTransport']!,
                                    isNumber: true,
                                  ),
                              ],
                            ),
                            _editSection(
                              'Detail Perjalanan',
                              Icons.event_note,
                              [
                                _editDateField(context, controllers['date']!),
                                _editField(
                                  'Jumlah Penumpang',
                                  controllers['penumpang']!,
                                  isNumber: true,
                                ),
                                _editField(
                                  'Durasi Perjalanan (hari)',
                                  controllers['durasi']!,
                                  isNumber: true,
                                ),
                              ],
                            ),
                            _editSection('Akomodasi', Icons.hotel, [
                              _editDropdown<String>(
                                'Tipe Penginapan',
                                tipeAkomodasi,
                                accommodationTypes
                                    .map((item) => item['label'] as String)
                                    .toList(),
                                (value) {
                                  final match = accommodationTypes.firstWhere(
                                    (item) => item['label'] == value,
                                  );
                                  controllers['hargaPenginapan']!.text =
                                      (match['harga'] as double)
                                          .toStringAsFixed(0);
                                  setDialogState(() => tipeAkomodasi = value);
                                },
                              ),
                              _editField(
                                'Harga per Malam',
                                controllers['hargaPenginapan']!,
                                isNumber: true,
                              ),
                              _editField(
                                'Jumlah Malam',
                                controllers['jumlahMalam']!,
                                isNumber: true,
                              ),
                              _editField(
                                'Jumlah Kamar',
                                controllers['jumlahKamar']!,
                                isNumber: true,
                              ),
                            ]),
                            _editSection('Konsumsi / Makan', Icons.restaurant, [
                              _editField(
                                'Budget Makan (per orang/sekali makan)',
                                controllers['makan']!,
                                isNumber: true,
                              ),
                              _editDropdown<int>(
                                'Frekuensi Makan per Hari',
                                frekuensiMakan,
                                mealFrequencies
                                    .map((item) => item['value'] as int)
                                    .toList(),
                                (value) => setDialogState(
                                  () => frekuensiMakan = value,
                                ),
                                labelFor: (value) =>
                                    mealFrequencies.firstWhere(
                                          (item) => item['value'] == value,
                                        )['label']
                                        as String,
                              ),
                            ]),
                            _editSection(
                              'Biaya Wisata',
                              Icons.confirmation_number,
                              [
                                _editSwitch(
                                  'Tiket Masuk Otomatis',
                                  isTiketOtomatis,
                                  (value) => setDialogState(
                                    () => isTiketOtomatis = value,
                                  ),
                                ),
                                _editField(
                                  'Tiket Masuk',
                                  controllers['tiket']!,
                                  isNumber: true,
                                  enabled: !isTiketOtomatis,
                                ),
                                _editSwitch(
                                  'Parkir Otomatis',
                                  isParkirOtomatis,
                                  (value) => setDialogState(
                                    () => isParkirOtomatis = value,
                                  ),
                                ),
                                _editField(
                                  'Parkir',
                                  controllers['parkir']!,
                                  isNumber: true,
                                  enabled: !isParkirOtomatis,
                                ),
                              ],
                            ),
                            _editSection('Biaya Lainnya', Icons.attach_money, [
                              _editField(
                                'Oleh-oleh / Belanja',
                                controllers['olehOleh']!,
                                isNumber: true,
                              ),
                              _editField(
                                'Biaya Lain-lain',
                                controllers['lainnya']!,
                                isNumber: true,
                              ),
                              _editSwitch(
                                'Dana Darurat (10%)',
                                isDanaDarurat,
                                (value) =>
                                    setDialogState(() => isDanaDarurat = value),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context, {
                                  'transport': transport,
                                  'fuelType': fuelType,
                                  'tipeAkomodasi': tipeAkomodasi,
                                  'frekuensiMakan': frekuensiMakan,
                                  'isTiketOtomatis': isTiketOtomatis,
                                  'isParkirOtomatis': isParkirOtomatis,
                                  'isDanaDarurat': isDanaDarurat,
                                });
                              },
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('Simpan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == null) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
      return;
    }

    await _saveEditedHistory(controllers, saved);

    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Future<void> _saveEditedHistory(
    Map<String, TextEditingController> controllers,
    Map<String, dynamic> editedState,
  ) async {
    final historyId = item['id']?.toString();
    if (historyId == null || historyId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID riwayat tidak ditemukan.')),
      );
      return;
    }

    final date = controllers['date']!.text.trim();
    final transport = editedState['transport'] as String;
    if (date.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tanggal belum diisi.')));
      return;
    }

    final biaya = _calculateCosts(controllers, editedState);
    if ((biaya['total'] ?? 0) <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total budget harus lebih dari 0.')),
      );
      return;
    }

    final details = {
      'form': {
        for (final entry in controllers.entries) entry.key: entry.value.text,
      }..remove('date'),
      'state': editedState,
      'biaya': biaya,
    };

    try {
      await FirestoreService.instance.updateTripHistory(historyId, {
        'transport': transport,
        'total_budget': biaya['total'],
        'date': date,
        'details': details,
      });

      if (!mounted) return;
      setState(() {
        item['transport'] = transport;
        item['total_budget'] = biaya['total'];
        item['date'] = date;
        item['details'] = details;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat berhasil diperbarui.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update riwayat: $e')));
    }
  }

  Map<String, double> _calculateCosts(
    Map<String, TextEditingController> controllers,
    Map<String, dynamic> state,
  ) {
    double textDouble(String key) => _doubleValue(controllers[key]?.text);
    int textInt(String key, [int fallback = 0]) =>
        int.tryParse(controllers[key]?.text ?? '') ?? fallback;

    final transport = state['transport'] as String;
    final fuelType = state['fuelType'] as String;
    final isKendaraanPribadi = transport == 'Mobil' || transport == 'Motor';
    final jarak = textDouble('jarak');
    final konsumsiBbm = textDouble('bbm');
    final penumpang = textInt('penumpang', 1);
    final durasi = textInt('durasi', 1);
    final frekuensiMakan = state['frekuensiMakan'] as int;

    double hargaBbm = 10000;
    for (final fuel in fuelTypes) {
      if (fuel['label'] == fuelType) {
        hargaBbm = fuel['harga'] as double;
        break;
      }
    }

    final bbm = isKendaraanPribadi && konsumsiBbm > 0
        ? (jarak / konsumsiBbm) * hargaBbm
        : 0.0;
    final tol = isKendaraanPribadi ? textDouble('tol') : 0.0;
    final transportUmum = !isKendaraanPribadi
        ? textDouble('tiketTransport')
        : 0.0;
    final savedTicket = _doubleValue(_costDetails['tiket']);
    final tiket = (state['isTiketOtomatis'] as bool)
        ? (savedTicket > 0 ? savedTicket : 10000.0)
        : textDouble('tiket');
    final parkir = (state['isParkirOtomatis'] as bool)
        ? (transport == 'Motor' ? 5000.0 : 10000.0)
        : textDouble('parkir');
    final makan = textDouble('makan') * frekuensiMakan * penumpang * durasi;
    final penginapan =
        textDouble('hargaPenginapan') *
        textInt('jumlahMalam') *
        textInt('jumlahKamar', 1);
    final olehOleh = textDouble('olehOleh');
    final lainnya = textDouble('lainnya');
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
    final danaDarurat = (state['isDanaDarurat'] as bool)
        ? subtotal * 0.10
        : 0.0;

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

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Riwayat Perjalanan';
    final location = item['location']?.toString() ?? '-';
    final transport = item['transport']?.toString() ?? '-';
    final date = item['date']?.toString() ?? '-';
    final destinationId = item['destination_id']?.toString() ?? '-';
    final totalBudget = _fmtCurrency(item['total_budget']);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, item);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image(
                  image: appImageProvider(item['image'] as String?),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.landscape,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _summaryCard(totalBudget, transport, date),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showEditDialog,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF007AFF),
                              side: const BorderSide(color: Color(0xFF007AFF)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openRoute,
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Rute'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailTile(
                      Icons.confirmation_number,
                      'ID Destinasi',
                      destinationId,
                    ),
                    _detailTile(
                      Icons.directions_car,
                      'Transportasi',
                      transport,
                    ),
                    _detailTile(Icons.calendar_today, 'Tanggal', date),
                    _detailTile(
                      Icons.account_balance_wallet,
                      'Total Budget',
                      'Rp $totalBudget',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailedHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedHistory() {
    final form = _formDetails;
    final state = _stateDetails;
    final biaya = _costDetails;

    if (form.isEmpty && biaya.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          'Rincian lengkap belum tersedia untuk riwayat lama ini. Gunakan Edit untuk menyimpan rincian baru.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }

    return Column(
      children: [
        _detailGroup('Perjalanan', Icons.event_note, [
          _compactRow('Budget Awal', 'Rp ${_fmtCurrency(form['budget'])}'),
          _compactRow(
            'Penumpang',
            '${_textValue(form, 'penumpang', '1')} orang',
          ),
          _compactRow('Durasi', '${_textValue(form, 'durasi', '1')} hari'),
        ]),
        _detailGroup('Transportasi', Icons.directions_car, [
          _compactRow(
            'Jenis',
            _textValue(
              state,
              'transport',
              item['transport']?.toString() ?? '-',
            ),
          ),
          _compactRow('BBM', _textValue(state, 'fuelType', '-')),
          _compactRow('Konsumsi', '${_textValue(form, 'bbm', '0')} km/l'),
          _compactRow('Jarak', '${_textValue(form, 'jarak', '0')} km'),
          _compactRow('Tol', 'Rp ${_fmtCurrency(form['tol'])}'),
        ]),
        _detailGroup('Akomodasi & Makan', Icons.hotel, [
          _compactRow('Penginapan', _textValue(state, 'tipeAkomodasi', '-')),
          _compactRow(
            'Harga/Malam',
            'Rp ${_fmtCurrency(form['hargaPenginapan'])}',
          ),
          _compactRow(
            'Malam x Kamar',
            '${_textValue(form, 'jumlahMalam', '0')} x ${_textValue(form, 'jumlahKamar', '1')}',
          ),
          _compactRow(
            'Makan',
            'Rp ${_fmtCurrency(form['makan'])} x ${_textValue(state, 'frekuensiMakan', '3')}/hari',
          ),
        ]),
        _detailGroup('Rincian Biaya', Icons.receipt_long, [
          _compactRow('BBM', 'Rp ${_fmtCurrency(biaya['bbm'])}'),
          _compactRow(
            'Transport Umum',
            'Rp ${_fmtCurrency(biaya['transportUmum'])}',
          ),
          _compactRow('Tiket Masuk', 'Rp ${_fmtCurrency(biaya['tiket'])}'),
          _compactRow('Parkir', 'Rp ${_fmtCurrency(biaya['parkir'])}'),
          _compactRow('Makan', 'Rp ${_fmtCurrency(biaya['makan'])}'),
          _compactRow('Penginapan', 'Rp ${_fmtCurrency(biaya['penginapan'])}'),
          _compactRow('Oleh-oleh', 'Rp ${_fmtCurrency(biaya['olehOleh'])}'),
          _compactRow('Lain-lain', 'Rp ${_fmtCurrency(biaya['lainnya'])}'),
          _compactRow(
            'Subtotal',
            'Rp ${_fmtCurrency(biaya['subtotal'])}',
            isBold: true,
          ),
          _compactRow(
            'Dana Darurat',
            'Rp ${_fmtCurrency(biaya['danaDarurat'])}',
          ),
        ]),
      ],
    );
  }

  Widget _editSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF007AFF)),
              const SizedBox(width: 6),
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
          ...children.expand((child) => [child, const SizedBox(height: 10)]),
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
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _editDateField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Tanggal',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onTap: () async {
        final currentDate =
            DateTime.tryParse(controller.text) ?? DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selected != null) {
          controller.text = selected.toIso8601String().split('T').first;
        }
      },
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
    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
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
    );
  }

  Widget _editSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _detailGroup(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF007AFF)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _compactRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String totalBudget, String transport, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Budget',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp $totalBudget',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniInfo(Icons.directions_car, 'Via', transport),
              ),
              const SizedBox(width: 12),
              Expanded(child: _miniInfo(Icons.event, 'Tanggal', date)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF007AFF)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
