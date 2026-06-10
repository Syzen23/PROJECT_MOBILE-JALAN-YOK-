import 'package:flutter/material.dart';
import 'package:jalanyok2/core/models/destination_model.dart';
import 'package:jalanyok2/core/services/firestore_service.dart';
import 'package:jalanyok2/core/widgets/cached_app_image.dart';
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

  String _fmtCurrency(dynamic value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    final raw = number.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  double _budgetValue() {
    final value = item['total_budget'];
    return value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
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
    final transportController = TextEditingController(
      text: item['transport']?.toString() ?? '',
    );
    final budgetController = TextEditingController(
      text: _budgetValue().toStringAsFixed(0),
    );
    final dateController = TextEditingController(
      text: item['date']?.toString() ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Riwayat'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: transportController,
                  decoration: const InputDecoration(
                    labelText: 'Transportasi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Budget',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final currentDate =
                        DateTime.tryParse(dateController.text) ??
                        DateTime.now();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: currentDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selected != null) {
                      dateController.text = selected
                          .toIso8601String()
                          .split('T')
                          .first;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      transportController.dispose();
      budgetController.dispose();
      dateController.dispose();
      return;
    }

    final historyId = item['id']?.toString();
    final budget = double.tryParse(budgetController.text.trim());
    final transport = transportController.text.trim();
    final date = dateController.text.trim();

    if (historyId == null || historyId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID riwayat tidak ditemukan.')),
        );
      }
      transportController.dispose();
      budgetController.dispose();
      dateController.dispose();
      return;
    }

    if (transport.isEmpty || budget == null || budget <= 0 || date.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data edit belum lengkap.')),
        );
      }
      transportController.dispose();
      budgetController.dispose();
      dateController.dispose();
      return;
    }

    try {
      await FirestoreService.instance.updateTripHistory(historyId, {
        'transport': transport,
        'total_budget': budget,
        'date': date,
      });

      if (!mounted) return;
      setState(() {
        item['transport'] = transport;
        item['total_budget'] = budget;
        item['date'] = date;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat berhasil diperbarui.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal update riwayat: $e')));
      }
    } finally {
      transportController.dispose();
      budgetController.dispose();
      dateController.dispose();
    }
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
                  ],
                ),
              ),
            ),
          ],
        ),
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
