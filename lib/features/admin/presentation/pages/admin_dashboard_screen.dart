import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<User> _users = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      FirestoreService.instance.getAllUsers(),
      FirestoreService.instance.getAllTripHistory(),
    ]);
    if (!mounted) return;
    setState(() {
      _users = results[0] as List<User>;
      _transactions = results[1] as List<Map<String, dynamic>>;
      _isLoading = false;
    });
  }

  double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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

  String _topValue(String Function(Map<String, dynamic>) picker) {
    final counts = <String, int>{};
    for (final item in _transactions) {
      final key = picker(item).trim();
      if (key.isEmpty || key == '-') continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return '-';
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return '${entries.first.key} (${entries.first.value}x)';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeUsers = _users.where((user) => user.isActive).length;
    final adminUsers = _users.where((user) => user.role == 'admin').length;
    final totalBudget = _transactions.fold<double>(
      0,
      (sum, item) => sum + _doubleValue(item['total_budget']),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: _loadStats, icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _heroSummary(totalBudget),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _statCard(
                  'Total User',
                  _users.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _statCard(
                  'User Aktif',
                  activeUsers.toString(),
                  Icons.verified_user,
                  Colors.green,
                ),
                _statCard(
                  'Admin',
                  adminUsers.toString(),
                  Icons.admin_panel_settings,
                  Colors.orange,
                ),
                _statCard(
                  'Transaksi',
                  _transactions.length.toString(),
                  Icons.receipt_long,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _insightRow(
              'Destinasi Teratas',
              _topValue((item) => item['title']?.toString() ?? '-'),
              Icons.place,
            ),
            _insightRow(
              'Transportasi Teratas',
              _topValue((item) => item['transport']?.toString() ?? '-'),
              Icons.directions_car,
            ),
            _insightRow(
              'Lokasi Teratas',
              _topValue((item) => item['location']?.toString() ?? '-'),
              Icons.map,
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroSummary(double totalBudget) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Operasional',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pantau user, transaksi, dan pola perjalanan dari data riwayat.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
          ),
          const SizedBox(height: 18),
          Text(
            _fmtCurrency(totalBudget),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Total budget tersimpan',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: color),
          const Spacer(),
          Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _insightRow(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF007AFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
