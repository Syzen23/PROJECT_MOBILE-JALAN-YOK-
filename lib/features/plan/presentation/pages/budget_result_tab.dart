import 'package:flutter/material.dart';
import 'package:jalanyok2/core/data/vehicle_database.dart';
import 'budget_widgets.dart';

class BudgetResultTab extends StatelessWidget {
  final Map<String, double> biaya;
  final Map<String, dynamic> state;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onEdit;
  final VoidCallback onBukaPeta;
  final VoidCallback onSimpan;

  const BudgetResultTab({
    super.key,
    required this.biaya,
    required this.state,
    required this.controllers,
    required this.onEdit,
    required this.onBukaPeta,
    required this.onSimpan,
  });

  String _fmt(double n) {
    String r = n.toStringAsFixed(0);
    String res = '';
    int c = 0;
    for (int i = r.length - 1; i >= 0; i--) {
      res = r[i] + res;
      c++;
      if (c % 3 == 0 && i > 0) res = '.$res';
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = state['selectedVehicle'] as VehicleEntry?;
    final transport = state['transport'] as String;
    final fuelType = state['fuelType'] as String;
    final penumpang = int.tryParse(controllers['penumpang']!.text) ?? 1;
    final durasi = int.tryParse(controllers['durasi']!.text) ?? 1;
    final jarak = double.tryParse(controllers['jarak']!.text) ?? 0;
    final budget = double.tryParse(controllers['budget']!.text) ?? 0;
    final total = biaya['total'] ?? 0;
    final sisaBudget = budget - total;
    final perOrang = penumpang > 0 ? total / penumpang : total;
    final isKendaraanPribadi = transport == 'Mobil' || transport == 'Motor';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Info Kendaraan
                if (selectedVehicle != null) ...[
                  _sectionTitle(
                    'Info Kendaraan',
                    Icons.directions_car,
                    Colors.deepPurple,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedVehicle.displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedVehicle.detailInfo,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (selectedVehicle.engineCc > 0)
                          Text(
                            'Mesin: ${selectedVehicle.engineDisplay}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Detail Perjalanan
                _sectionTitle(
                  'Detail Perjalanan',
                  Icons.event_note,
                  Colors.teal,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ResultInfoCard(
                        label: 'Jarak',
                        value: '${jarak.toInt()} km',
                        icon: Icons.straighten,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultInfoCard(
                        label: 'Durasi',
                        value: '$durasi hari',
                        icon: Icons.schedule,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ResultInfoCard(
                        label: 'Penumpang',
                        value: '$penumpang orang',
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultInfoCard(
                        label: 'Transportasi',
                        value: transport,
                        icon: Icons.directions_car,
                      ),
                    ),
                  ],
                ),
                if (isKendaraanPribadi) ...[
                  const SizedBox(height: 8),
                  ResultInfoCard(
                    label: 'BBM',
                    value: '$fuelType (${controllers['bbm']!.text} km/l)',
                    icon: Icons.local_gas_station,
                  ),
                ],
                const SizedBox(height: 20),
                // Rincian Biaya
                _sectionTitle(
                  'Rincian Biaya',
                  Icons.receipt_long,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                if (isKendaraanPribadi) ...[
                  _biayaRow('BBM', biaya['bbm'] ?? 0, Icons.local_gas_station),
                  _biayaRow('Tol', biaya['tol'] ?? 0, Icons.toll),
                ],
                if (!isKendaraanPribadi)
                  _biayaRow(
                    'Tiket $transport',
                    biaya['transportUmum'] ?? 0,
                    Icons.train,
                  ),
                _biayaRow(
                  'Tiket Masuk',
                  biaya['tiket'] ?? 0,
                  Icons.confirmation_number,
                ),
                _biayaRow('Parkir', biaya['parkir'] ?? 0, Icons.local_parking),
                _biayaRow('Makan', biaya['makan'] ?? 0, Icons.restaurant),
                _biayaRow('Penginapan', biaya['penginapan'] ?? 0, Icons.hotel),
                _biayaRow(
                  'Oleh-oleh',
                  biaya['olehOleh'] ?? 0,
                  Icons.shopping_bag,
                ),
                _biayaRow('Lain-lain', biaya['lainnya'] ?? 0, Icons.more_horiz),
                const Divider(height: 24),
                _biayaRow(
                  'Subtotal',
                  biaya['subtotal'] ?? 0,
                  Icons.summarize,
                  isBold: true,
                ),
                if ((biaya['danaDarurat'] ?? 0) > 0)
                  _biayaRow(
                    'Dana Darurat (10%)',
                    biaya['danaDarurat'] ?? 0,
                    Icons.shield,
                    color: Colors.amber.shade700,
                  ),
                const SizedBox(height: 16),
                // TOTAL
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${_fmt(total)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Per Orang
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF007AFF),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Biaya Per Orang',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rp ${_fmt(perOrang)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Status Budget
                if (budget > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sisaBudget >= 0
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sisaBudget >= 0
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          sisaBudget >= 0 ? Icons.check_circle : Icons.warning,
                          size: 20,
                          color: sisaBudget >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget: Rp ${_fmt(budget)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                sisaBudget >= 0
                                    ? 'Sisa: Rp ${_fmt(sisaBudget)}'
                                    : 'Kurang: Rp ${_fmt(sisaBudget.abs())}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: sisaBudget >= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Edit Budget',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF007AFF),
                    side: const BorderSide(color: Color(0xFF007AFF)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onBukaPeta,
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text(
                    'Lihat Rute di Peta',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSimpan,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text(
                    'Simpan ke Riwayat',
                    style: TextStyle(fontSize: 14),
                  ),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _biayaRow(
    String label,
    double value,
    IconData icon, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            'Rp ${_fmt(value)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
