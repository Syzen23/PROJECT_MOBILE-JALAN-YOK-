import 'package:flutter/material.dart';
import 'package:jalanyok2/core/models/destination_model.dart';
import 'package:jalanyok2/core/services/firestore_service.dart';
import 'package:jalanyok2/core/widgets/cached_app_image.dart';
import 'package:jalanyok2/features/plan/presentation/pages/map_screen.dart';

import 'history_edit_screen.dart';

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

  Map<String, dynamic> get _selectedVehicleDetails {
    final vehicle = _stateDetails['selectedVehicle'];
    return vehicle is Map ? Map<String, dynamic>.from(vehicle) : {};
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
    return map[key]?.toString() ?? fallback;
  }

  String _vehicleText(String key, [String fallback = '']) {
    return _selectedVehicleDetails[key]?.toString() ?? fallback;
  }

  bool get _hasSelectedVehicle {
    final vehicle = _selectedVehicleDetails;
    return (vehicle['make']?.toString().isNotEmpty ?? false) ||
        (vehicle['model']?.toString().isNotEmpty ?? false);
  }

  String get _selectedVehicleName {
    final make = _vehicleText('make');
    final model = _vehicleText('model');
    return [make, model].where((value) => value.isNotEmpty).join(' ');
  }

  String get _transportLabel {
    final transport = item['transport']?.toString() ?? '-';
    if (!_hasSelectedVehicle) return transport;
    return '$transport - $_selectedVehicleName';
  }

  double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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

  Future<void> _openEditPage() async {
    final updatedItem = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => HistoryEditScreen(item: item)),
    );
    if (updatedItem != null && mounted) {
      setState(() => item = updatedItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat berhasil diperbarui.')),
      );
    }
  }

  Future<void> _deleteHistory() async {
    final historyId = item['id']?.toString();
    if (historyId == null || historyId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Riwayat?'),
          content: const Text(
            'Data riwayat ini akan dihapus permanen dari daftar perjalanan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await FirestoreService.instance.deleteTripHistory(historyId);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Riwayat berhasil dihapus.')));
    Navigator.pop(context, {'deleted': true, 'id': historyId});
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Riwayat Perjalanan';
    final location = item['location']?.toString() ?? '-';
    final transportLabel = _transportLabel;
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
                    _summaryCard(totalBudget, transportLabel, date),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openEditPage,
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteHistory,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Hapus Riwayat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
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
                      transportLabel,
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
    final hasVehicle = _hasSelectedVehicle;

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
          if (hasVehicle) ...[
            _compactRow('Kendaraan', _selectedVehicleName),
            _compactRow('Tipe', _vehicleText('type', '-')),
            if (_vehicleText('year').isNotEmpty)
              _compactRow('Tahun', _vehicleText('year')),
            if (_vehicleText('transmission').isNotEmpty)
              _compactRow('Transmisi', _vehicleText('transmission')),
            if (_vehicleText('colour').isNotEmpty)
              _compactRow('Warna', _vehicleText('colour')),
            if (_vehicleText('engineCc').isNotEmpty &&
                _vehicleText('engineCc') != '0')
              _compactRow('Mesin', '${_vehicleText('engineCc')} cc'),
          ],
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
}
