import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/firestore_service.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  List<Map<String, dynamic>> _transactions = [];
  List<User> _users = [];
  String _query = '';
  String _transportFilter = 'Semua';
  String _userFilter = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      FirestoreService.instance.getAllTripHistory(),
      FirestoreService.instance.getAllUsers(),
    ]);

    if (!mounted) return;
    setState(() {
      _transactions = results[0] as List<Map<String, dynamic>>;
      _users = results[1] as List<User>;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    return _transactions.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? '';
      final location = item['location']?.toString().toLowerCase() ?? '';
      final user = _userName(item['user_id']?.toString()).toLowerCase();
      final query = _query.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          title.contains(query) ||
          location.contains(query) ||
          user.contains(query);
      final matchesTransport =
          _transportFilter == 'Semua' ||
          item['transport']?.toString() == _transportFilter;
      final matchesUser =
          _userFilter == 'Semua' || item['user_id']?.toString() == _userFilter;
      return matchesQuery && matchesTransport && matchesUser;
    }).toList();
  }

  String _userName(String? userId) {
    if (userId == null) return 'User tidak diketahui';
    final matches = _users.where((user) => user.id == userId);
    return matches.isEmpty ? 'User tidak diketahui' : matches.first.name;
  }

  String _fmtCurrency(dynamic value) {
    final amount = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    final raw = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  Map<String, dynamic> _mapOf(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filtered = _filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _exportFilteredCsv,
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy CSV',
          ),
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            Text(
              '${filtered.length} transaksi ditemukan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: Text('Belum ada transaksi yang cocok.')),
              )
            else
              ...filtered.map(_buildTransactionCard),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final transports = [
      'Semua',
      ..._transactions
          .map((item) => item['transport']?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList()
        ..sort(),
    ];

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Cari destinasi, lokasi, atau nama user',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _filterDropdown(
                value: _transportFilter,
                items: transports,
                onChanged: (value) {
                  setState(() => _transportFilter = value ?? 'Semua');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _filterDropdown(
                value: _userFilter,
                items: [
                  const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                  ..._users.map(
                    (user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _userFilter = value ?? 'Semua');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filterDropdown<T>({
    required T value,
    required List<dynamic> items,
    required ValueChanged<T?> onChanged,
  }) {
    final menuItems = items is List<DropdownMenuItem<T>>
        ? items
        : items
              .map(
                (item) =>
                    DropdownMenuItem<T>(value: item as T, child: Text('$item')),
              )
              .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: menuItems,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> item) {
    final details = _mapOf(item['details']);
    final state = _mapOf(details['state']);
    final vehicle = _mapOf(state['selectedVehicle']);
    final vehicleName = [
      vehicle['make']?.toString() ?? '',
      vehicle['model']?.toString() ?? '',
    ].where((item) => item.isNotEmpty).join(' ');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
          child: const Icon(Icons.receipt_long, color: Color(0xFF007AFF)),
        ),
        title: Text(
          item['title']?.toString() ?? 'Destinasi',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_userName(item['user_id']?.toString())),
              Text(
                '${item['transport'] ?? '-'}${vehicleName.isEmpty ? '' : ' - $vehicleName'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(item['date']?.toString() ?? '-'),
            ],
          ),
        ),
        trailing: Text(
          _fmtCurrency(item['total_budget']),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF007AFF),
          ),
        ),
        onTap: () => _showTransactionDetail(item),
      ),
    );
  }

  Future<void> _exportFilteredCsv() async {
    final rows = [
      [
        'Tanggal',
        'User',
        'Destinasi',
        'Lokasi',
        'Transportasi',
        'Total Budget',
      ],
      ..._filteredTransactions.map((item) {
        return [
          item['date']?.toString() ?? '',
          _userName(item['user_id']?.toString()),
          item['title']?.toString() ?? '',
          item['location']?.toString() ?? '',
          item['transport']?.toString() ?? '',
          item['total_budget']?.toString() ?? '0',
        ];
      }),
    ];
    final csv = rows.map((row) => row.map(_csvCell).join(',')).join('\n');
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV transaksi berhasil disalin.')),
    );
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  void _showTransactionDetail(Map<String, dynamic> item) {
    final details = _mapOf(item['details']);
    final form = _mapOf(details['form']);
    final state = _mapOf(details['state']);
    final costs = _mapOf(details['biaya']);
    final vehicle = _mapOf(state['selectedVehicle']);
    final vehicleName = [
      vehicle['make']?.toString() ?? '',
      vehicle['model']?.toString() ?? '',
    ].where((item) => item.isNotEmpty).join(' ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.45,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  item['title']?.toString() ?? 'Detail Transaksi',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_userName(item['user_id']?.toString())} - ${item['date'] ?? '-'}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                _detailRow('Lokasi', item['location']?.toString() ?? '-'),
                _detailRow(
                  'Transportasi',
                  item['transport']?.toString() ?? '-',
                ),
                if (vehicleName.isNotEmpty) ...[
                  _detailRow('Kendaraan', vehicleName),
                  _detailRow('Tipe', vehicle['type']?.toString() ?? '-'),
                  _detailRow('BBM', vehicle['fuelType']?.toString() ?? '-'),
                  _detailRow('Mesin', '${vehicle['engineCc'] ?? 0} cc'),
                ],
                _detailRow('Jarak', '${form['jarak'] ?? 0} km'),
                _detailRow('Konsumsi', '${form['bbm'] ?? 0} km/l'),
                const Divider(height: 28),
                _detailRow('BBM', _fmtCurrency(costs['bbm'])),
                _detailRow('Tol', _fmtCurrency(costs['tol'])),
                _detailRow(
                  'Transport Umum',
                  _fmtCurrency(costs['transportUmum']),
                ),
                _detailRow('Tiket Masuk', _fmtCurrency(costs['tiket'])),
                _detailRow('Parkir', _fmtCurrency(costs['parkir'])),
                _detailRow('Makan', _fmtCurrency(costs['makan'])),
                _detailRow('Penginapan', _fmtCurrency(costs['penginapan'])),
                _detailRow('Oleh-oleh', _fmtCurrency(costs['olehOleh'])),
                _detailRow('Lain-lain', _fmtCurrency(costs['lainnya'])),
                const Divider(height: 28),
                _detailRow(
                  'Total',
                  _fmtCurrency(item['total_budget']),
                  isBold: true,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
