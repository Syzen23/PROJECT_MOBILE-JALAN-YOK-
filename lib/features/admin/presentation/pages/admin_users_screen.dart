import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> _users = [];
  List<Map<String, dynamic>> _histories = [];
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      FirestoreService.instance.getAllUsers(),
      FirestoreService.instance.getAllTripHistory(),
    ]);
    if (!mounted) return;
    setState(() {
      _users = results[0] as List<User>;
      _histories = results[1] as List<Map<String, dynamic>>;
      _isLoading = false;
    });
  }

  List<User> get _filteredUsers {
    final query = _query.toLowerCase();
    return _users.where((user) {
      return query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  }

  int _historyCount(User user) {
    return _histories
        .where((history) => history['user_id']?.toString() == user.id)
        .length;
  }

  double _totalBudget(User user) {
    return _histories
        .where((history) => history['user_id']?.toString() == user.id)
        .fold<double>(0, (sum, history) {
          final value = history['total_budget'];
          return sum +
              (value is num
                  ? value.toDouble()
                  : double.tryParse('$value') ?? 0);
        });
  }

  String _fmtCurrency(double amount) {
    final raw = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  Future<void> _writeAudit(
    String action,
    String target, [
    Map<String, dynamic>? metadata,
  ]) async {
    final admin = await AuthService.getCurrentUser();
    if (admin == null) return;
    await FirestoreService.instance.addAuditLog(
      actorId: admin.id ?? '-',
      actorName: admin.name,
      action: action,
      target: target,
      metadata: metadata,
    );
  }

  Future<void> _changeRole(User user) async {
    final newRole = user.role == 'admin' ? 'user' : 'admin';
    await FirestoreService.instance.updateUserRole(user.id!, newRole);
    await _writeAudit('change_user_role', user.email, {
      'from': user.role,
      'to': newRole,
    });
    await _loadData();
  }

  Future<void> _toggleActive(User user) async {
    final nextStatus = !user.isActive;
    await FirestoreService.instance.updateUserActiveStatus(
      user.id!,
      nextStatus,
    );
    await _writeAudit('change_user_status', user.email, {
      'is_active': nextStatus,
    });
    await _loadData();
  }

  Future<void> _deleteUser(User user) async {
    await FirestoreService.instance.deleteUser(user.id!);
    await _writeAudit('delete_user', user.email);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final users = _filteredUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Pengguna',
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
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari nama, email, atau role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...users.map(_buildUserCard),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final isAdmin = user.role == 'admin';
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

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
          child: Text(
            initial,
            style: const TextStyle(color: Color(0xFF007AFF)),
          ),
        ),
        title: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _chip(
                  user.role.toUpperCase(),
                  isAdmin ? Colors.orange : Colors.green,
                ),
                _chip(
                  user.isActive ? 'AKTIF' : 'NONAKTIF',
                  user.isActive ? Colors.blue : Colors.red,
                ),
                _chip('${_historyCount(user)} RIWAYAT', Colors.purple),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.more_vert),
        onTap: () => _showUserDetail(user),
        onLongPress: () => _showUserActions(user),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showUserDetail(User user) {
    final histories = _histories
        .where((history) => history['user_id']?.toString() == user.id)
        .take(5)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          maxChildSize: 0.9,
          minChildSize: 0.45,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.email, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 18),
                _infoRow('Role', user.role),
                _infoRow('Status', user.isActive ? 'Aktif' : 'Nonaktif'),
                _infoRow('No HP', user.phoneNumber ?? '-'),
                _infoRow('Umur', user.age?.toString() ?? '-'),
                _infoRow('Tanggal Lahir', user.dateOfBirth ?? '-'),
                _infoRow('Gender', user.gender ?? '-'),
                _infoRow('Alamat', user.address ?? '-'),
                const Divider(height: 28),
                _infoRow('Total Riwayat', '${_historyCount(user)} transaksi'),
                _infoRow('Total Budget', _fmtCurrency(_totalBudget(user))),
                const SizedBox(height: 12),
                const Text(
                  'Riwayat Terbaru',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (histories.isEmpty)
                  const Text(
                    'User belum punya riwayat.',
                    style: TextStyle(color: Colors.black54),
                  )
                else
                  ...histories.map((history) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(history['title']?.toString() ?? '-'),
                      subtitle: Text(history['date']?.toString() ?? '-'),
                      trailing: Text(
                        _fmtCurrency(
                          (history['total_budget'] as num?)?.toDouble() ?? 0,
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    context.pop();
                    _showUserActions(user);
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Aksi Admin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserActions(User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: Text(
                  user.role == 'admin' ? 'Ubah ke User Biasa' : 'Jadikan Admin',
                ),
                onTap: () async {
                  context.pop();
                  await _changeRole(user);
                },
              ),
              ListTile(
                leading: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  color: user.isActive ? Colors.orange : Colors.green,
                ),
                title: Text(
                  user.isActive ? 'Nonaktifkan User' : 'Aktifkan User',
                ),
                onTap: () async {
                  context.pop();
                  await _toggleActive(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Hapus Pengguna',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  context.pop();
                  await _deleteUser(user);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
