import 'package:flutter/material.dart';
import '../../../../core/services/firestore_service.dart';

class AdminInsightsScreen extends StatefulWidget {
  const AdminInsightsScreen({super.key});

  @override
  State<AdminInsightsScreen> createState() => _AdminInsightsScreenState();
}

class _AdminInsightsScreenState extends State<AdminInsightsScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final transactions = await FirestoreService.instance.getAllTripHistory();
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  String _fmtCurrency(num value) {
    final raw = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> _mapOf(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  List<MapEntry<String, int>> _topCounts(
    String Function(Map<String, dynamic>) picker,
  ) {
    final counts = <String, int>{};
    for (final item in _transactions) {
      final key = picker(item).trim();
      if (key.isEmpty || key == '-') continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  List<MapEntry<String, double>> _topAverageBudgetByDestination() {
    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final item in _transactions) {
      final destination = item['title']?.toString() ?? 'Unknown';
      totals[destination] =
          (totals[destination] ?? 0) + _doubleValue(item['total_budget']);
      counts[destination] = (counts[destination] ?? 0) + 1;
    }
    final averages =
        totals.entries
            .map(
              (entry) =>
                  MapEntry(entry.key, entry.value / (counts[entry.key] ?? 1)),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return averages.take(5).toList();
  }

  List<MapEntry<String, int>> _topVehicleModels() {
    final counts = <String, int>{};
    for (final item in _transactions) {
      final details = _mapOf(item['details']);
      final state = _mapOf(details['state']);
      final vehicle = _mapOf(state['selectedVehicle']);
      final name = [
        vehicle['make']?.toString() ?? '',
        vehicle['model']?.toString() ?? '',
      ].where((value) => value.isNotEmpty).join(' ');
      if (name.isEmpty) continue;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final topDestinations = _topCounts(
      (item) => item['title']?.toString() ?? '-',
    );
    final topLocations = _topCounts(
      (item) => item['location']?.toString() ?? '-',
    );
    final topTransports = _topCounts(
      (item) => item['transport']?.toString() ?? '-',
    );
    final topVehicleModels = _topVehicleModels();
    final topAverageBudgets = _topAverageBudgetByDestination();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Insight Destinasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headlineCard(),
            const SizedBox(height: 16),
            _rankingCard(
              'Destinasi Paling Sering Direncanakan',
              topDestinations,
            ),
            _rankingCard('Lokasi/Provinsi Terpopuler', topLocations),
            _rankingCard('Transportasi Terfavorit', topTransports),
            _rankingCard('Model Kendaraan Terfavorit', topVehicleModels),
            _budgetRankingCard('Rata-rata Budget Tertinggi', topAverageBudgets),
          ],
        ),
      ),
    );
  }

  Widget _headlineCard() {
    final totalBudget = _transactions.fold<double>(
      0,
      (sum, item) => sum + _doubleValue(item['total_budget']),
    );
    final averageBudget = _transactions.isEmpty
        ? 0
        : totalBudget / _transactions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Minat Pengguna',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniMetric(
                  'Transaksi',
                  _transactions.length.toString(),
                  Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniMetric(
                  'Avg Budget',
                  _fmtCurrency(averageBudget),
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _rankingCard(String title, List<MapEntry<String, int>> items) {
    return _card(
      title,
      items.isEmpty
          ? [
              const Text(
                'Belum ada data.',
                style: TextStyle(color: Colors.black54),
              ),
            ]
          : items.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              return _rankRow('$index', item.key, '${item.value}x');
            }).toList(),
    );
  }

  Widget _budgetRankingCard(
    String title,
    List<MapEntry<String, double>> items,
  ) {
    return _card(
      title,
      items.isEmpty
          ? [
              const Text(
                'Belum ada data.',
                style: TextStyle(color: Colors.black54),
              ),
            ]
          : items.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              return _rankRow('$index', item.key, _fmtCurrency(item.value));
            }).toList(),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _rankRow(String rank, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
            child: Text(
              rank,
              style: const TextStyle(fontSize: 11, color: Color(0xFF007AFF)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
