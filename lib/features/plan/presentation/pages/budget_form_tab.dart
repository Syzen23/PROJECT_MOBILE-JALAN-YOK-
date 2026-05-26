import 'package:flutter/material.dart';
import 'package:jalanyok2/core/models/destination_model.dart';
import 'package:jalanyok2/core/models/vehicle_data_model.dart';
import 'package:jalanyok2/core/services/nopol_service.dart';
import 'budget_constants.dart';
import 'budget_widgets.dart';

class BudgetFormTab extends StatelessWidget {
  final Map<String, dynamic> state;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onHitung;
  final Function(String, dynamic) onStateChanged;
  final List<Destination> destinations;
  final Destination? selectedDestination;
  final Function(Destination) onDestinationChanged;

  const BudgetFormTab({super.key, required this.state, required this.controllers, required this.onHitung, required this.onStateChanged, required this.destinations, this.selectedDestination, required this.onDestinationChanged});

  @override
  Widget build(BuildContext context) {
    final transport = state['transport'] as String;
    final isKendaraanPribadi = transport == 'Mobil' || transport == 'Motor';
    return Column(children: [
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildNopolSection(context),
        const SizedBox(height: 12),
        _buildTransportSection(isKendaraanPribadi),
        const SizedBox(height: 12),
        _buildDetailSection(),
        const SizedBox(height: 12),
        _buildAkomodasiSection(),
        const SizedBox(height: 12),
        _buildKonsumsiSection(),
        const SizedBox(height: 12),
        _buildWisataSection(),
        const SizedBox(height: 12),
        _buildLainnyaSection(),
      ]))),
      Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
        onPressed: onHitung, icon: const Icon(Icons.calculate, size: 18),
        label: const Text('Hitung Budget', style: TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ))),
    ]);
  }

  Widget _buildNopolSection(BuildContext context) {
    final vehicleData = state['vehicleData'] as VehicleData?;
    final isSearching = state['isSearchingPlate'] as bool? ?? false;
    return SectionCard(title: 'Cari Kendaraan (Plat Nomor)', icon: Icons.search, color: Colors.deepPurple, children: [
      Row(children: [
        Expanded(child: BudgetField(label: 'Plat Nomor', hint: 'Contoh: B1234ABC', controller: controllers['platNomor'])),
        const SizedBox(width: 8),
        Padding(padding: const EdgeInsets.only(top: 20), child: SizedBox(height: 40, child: ElevatedButton(
          onPressed: isSearching ? null : () => _searchPlate(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 16)),
          child: isSearching ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search, size: 18),
        ))),
      ]),
      if (vehicleData != null) ...[
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepPurple.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16), const SizedBox(width: 6),
              Expanded(child: Text(vehicleData.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 6),
            Text('Tahun: ${vehicleData.registrationYear} | Warna: ${vehicleData.colour ?? "-"}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
            Text('Tipe: ${vehicleData.vehicleType ?? "-"} | Lokasi: ${vehicleData.location ?? "-"}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
            if (vehicleData.stnkExpiry != null) Text('STNK: ${vehicleData.stnkExpiry}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          ]),
        ),
      ],
    ]);
  }

  Future<void> _searchPlate(BuildContext context) async {
    final plate = controllers['platNomor']!.text.trim();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan plat nomor')));
      return;
    }
    onStateChanged('isSearchingPlate', true);
    final data = await NopolService.lookupPlate(plate);
    onStateChanged('isSearchingPlate', false);
    if (data != null) {
      onStateChanged('vehicleData', data);
      onStateChanged('transport', data.transportType);
      controllers['bbm']!.text = data.estimatedConsumption.toStringAsFixed(0);
      final fuel = data.fuelType?.toUpperCase() ?? '';
      if (fuel.contains('SOLAR')) { onStateChanged('fuelType', 'Solar'); }
      else { onStateChanged('fuelType', 'Pertalite'); }
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ditemukan: ${data.displayName}')));
    } else {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kendaraan tidak ditemukan')));
    }
  }

  Widget _buildTransportSection(bool isKendaraanPribadi) {
    final transport = state['transport'] as String;
    final tipeKendaraan = state['tipeKendaraan'] as String?;
    final fuelType = state['fuelType'] as String;
    return SectionCard(title: 'Transportasi & Kendaraan', icon: Icons.directions_car, color: const Color(0xFF007AFF), children: [
      BudgetField(label: 'Budget', hint: 'Contoh: 2000000', controller: controllers['budget'], isNumber: true),
      const SizedBox(height: 12),
      BudgetDropdown<String>(label: 'Transportasi', value: transport,
        items: ['Mobil', 'Motor', 'Bus', 'Kereta'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) { onStateChanged('transport', v); onStateChanged('tipeKendaraan', null); }),
      if (isKendaraanPribadi && vehicleTypes.containsKey(transport)) ...[
        const SizedBox(height: 12),
        BudgetDropdown<String?>(label: 'Tipe Kendaraan', value: tipeKendaraan,
          items: [const DropdownMenuItem<String?>(value: null, child: Text('Pilih tipe...')), ...vehicleTypes[transport]!.map((e) => DropdownMenuItem<String?>(value: e['label'] as String, child: Text(e['label'] as String, overflow: TextOverflow.ellipsis)))],
          onChanged: (v) {
            onStateChanged('tipeKendaraan', v);
            if (v != null) {
              final match = vehicleTypes[transport]!.firstWhere((e) => e['label'] == v);
              controllers['bbm']!.text = (match['konsumsi'] as double).toStringAsFixed(0);
            }
          }),
        const SizedBox(height: 12),
        BudgetDropdown<String>(label: 'Jenis BBM', value: fuelType,
          items: fuelTypes.map((e) => DropdownMenuItem(value: e['label'] as String, child: Text('${e['label']} (Rp ${_fmt(e['harga'] as double)}/l)'))).toList(),
          onChanged: (v) => onStateChanged('fuelType', v)),
        const SizedBox(height: 12),
        BudgetField(label: 'Konsumsi BBM (km/l)', hint: 'Contoh: 12', controller: controllers['bbm'], isNumber: true),
        const SizedBox(height: 12),
        BudgetField(label: 'Jarak Tempuh (km)', hint: 'Contoh: 100', controller: controllers['jarak'], isNumber: true),
        const SizedBox(height: 12),
        BudgetField(label: 'Biaya Tol (PP)', hint: 'Contoh: 150000', controller: controllers['tol'], isNumber: true),
      ],
      if (!isKendaraanPribadi) ...[
        const SizedBox(height: 12),
        BudgetField(label: 'Harga Tiket $transport (PP)', hint: 'Contoh: 200000', controller: controllers['tiketTransport'], isNumber: true),
      ],
    ]);
  }

  Widget _buildDetailSection() {
    return SectionCard(title: 'Detail Perjalanan', icon: Icons.event_note, color: Colors.teal, children: [
      BudgetField(label: 'Jumlah Penumpang', hint: '1', controller: controllers['penumpang'], isNumber: true),
      const SizedBox(height: 12),
      BudgetField(label: 'Durasi Perjalanan (hari)', hint: '1', controller: controllers['durasi'], isNumber: true),
    ]);
  }

  Widget _buildAkomodasiSection() {
    final tipeAkomodasi = state['tipeAkomodasi'] as String;
    return SectionCard(title: 'Akomodasi', icon: Icons.hotel, color: Colors.orange, children: [
      BudgetDropdown<String>(label: 'Tipe Penginapan', value: tipeAkomodasi,
        items: accommodationTypes.map((e) => DropdownMenuItem(value: e['label'] as String, child: Text(e['label'] as String))).toList(),
        onChanged: (v) {
          onStateChanged('tipeAkomodasi', v);
          final match = accommodationTypes.firstWhere((e) => e['label'] == v);
          controllers['hargaPenginapan']!.text = (match['harga'] as double).toStringAsFixed(0);
        }),
      const SizedBox(height: 12),
      BudgetField(label: 'Harga per Malam', hint: 'Contoh: 350000', controller: controllers['hargaPenginapan'], isNumber: true),
      const SizedBox(height: 12),
      BudgetField(label: 'Jumlah Malam', hint: 'Otomatis: durasi-1', controller: controllers['jumlahMalam'], isNumber: true),
      const SizedBox(height: 12),
      BudgetField(label: 'Jumlah Kamar', hint: '1', controller: controllers['jumlahKamar'], isNumber: true),
    ]);
  }

  Widget _buildKonsumsiSection() {
    final frekuensi = state['frekuensiMakan'] as int;
    return SectionCard(title: 'Konsumsi / Makan', icon: Icons.restaurant, color: Colors.red.shade400, children: [
      BudgetField(label: 'Budget Makan (per orang/sekali makan)', hint: 'Contoh: 25000', controller: controllers['makan'], isNumber: true),
      const SizedBox(height: 12),
      BudgetDropdown<int>(label: 'Frekuensi Makan per Hari', value: frekuensi,
        items: mealFrequencies.map((e) => DropdownMenuItem(value: e['value'] as int, child: Text(e['label'] as String))).toList(),
        onChanged: (v) => onStateChanged('frekuensiMakan', v)),
    ]);
  }

  Widget _buildWisataSection() {
    final isTiketOto = state['isTiketOtomatis'] as bool;
    final isParkirOto = state['isParkirOtomatis'] as bool;
    return SectionCard(title: 'Biaya Wisata', icon: Icons.confirmation_number, color: Colors.indigo, children: [
      _buildOtomatisField('Tiket Masuk', 'Contoh: 10000', controllers['tiket']!, isTiketOto, (v) => onStateChanged('isTiketOtomatis', v)),
      const SizedBox(height: 12),
      _buildOtomatisField('Parkir', 'Contoh: 5000', controllers['parkir']!, isParkirOto, (v) => onStateChanged('isParkirOtomatis', v)),
    ]);
  }

  Widget _buildOtomatisField(String label, String hint, TextEditingController ctrl, bool isOto, Function(bool) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 6),
      Container(height: 40, padding: const EdgeInsets.only(left: 12, right: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
        child: Row(children: [
          Expanded(child: TextField(controller: ctrl, keyboardType: TextInputType.number, enabled: !isOto,
            style: TextStyle(fontSize: 12, color: isOto ? Colors.grey : Colors.black),
            decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12), contentPadding: const EdgeInsets.only(bottom: 12)))),
          PopupMenuButton<bool>(initialValue: isOto, onSelected: onChanged, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            itemBuilder: (c) => [const PopupMenuItem(value: true, child: Text('Otomatis', style: TextStyle(fontSize: 12))), const PopupMenuItem(value: false, child: Text('Manual', style: TextStyle(fontSize: 12)))],
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blue.shade300), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(isOto ? 'Otomatis' : 'Manual', style: const TextStyle(color: Color(0xFF007AFF), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4), const Icon(Icons.keyboard_arrow_down, color: Color(0xFF007AFF), size: 14),
              ]))),
        ])),
    ]);
  }

  Widget _buildLainnyaSection() {
    final isDanaDarurat = state['isDanaDarurat'] as bool;
    return SectionCard(title: 'Biaya Lainnya', icon: Icons.attach_money, color: Colors.green.shade600, children: [
      BudgetField(label: 'Oleh-oleh / Belanja', hint: 'Contoh: 200000', controller: controllers['olehOleh'], isNumber: true),
      const SizedBox(height: 12),
      BudgetField(label: 'Biaya Lain-lain', hint: 'Contoh: 50000', controller: controllers['lainnya'], isNumber: true),
      const SizedBox(height: 12),
      Row(children: [
        const Expanded(child: Text('Dana Darurat (10%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87))),
        Switch(value: isDanaDarurat, activeColor: Colors.green, onChanged: (v) => onStateChanged('isDanaDarurat', v)),
      ]),
    ]);
  }

  String _fmt(double n) {
    String r = n.toStringAsFixed(0); String res = ''; int c = 0;
    for (int i = r.length - 1; i >= 0; i--) { res = r[i] + res; c++; if (c % 3 == 0 && i > 0) res = '.$res'; }
    return res;
  }
}
