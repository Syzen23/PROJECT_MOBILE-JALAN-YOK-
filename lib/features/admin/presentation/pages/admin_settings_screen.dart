import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _ticketController = TextEditingController();
  final _motorParkingController = TextEditingController();
  final _carParkingController = TextEditingController();
  final _emergencyController = TextEditingController();
  List<Map<String, dynamic>> _auditLogs = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _ticketController.dispose();
    _motorParkingController.dispose();
    _carParkingController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      FirestoreService.instance.getBudgetSettings(),
      FirestoreService.instance.getAuditLogs(),
    ]);
    final settings = results[0] as Map<String, dynamic>;
    final logs = results[1] as List<Map<String, dynamic>>;

    if (!mounted) return;
    setState(() {
      _ticketController.text = (settings['default_ticket'] as double)
          .toStringAsFixed(0);
      _motorParkingController.text = (settings['parking_motor'] as double)
          .toStringAsFixed(0);
      _carParkingController.text = (settings['parking_car'] as double)
          .toStringAsFixed(0);
      _emergencyController.text = (settings['emergency_percent'] as double)
          .toStringAsFixed(0);
      _auditLogs = logs;
      _isLoading = false;
    });
  }

  double _fieldValue(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final user = await AuthService.getCurrentUser();
    final settings = {
      'default_ticket': _fieldValue(_ticketController),
      'parking_motor': _fieldValue(_motorParkingController),
      'parking_car': _fieldValue(_carParkingController),
      'emergency_percent': _fieldValue(_emergencyController),
    };

    await FirestoreService.instance.updateBudgetSettings(settings);
    if (user != null) {
      await FirestoreService.instance.addAuditLog(
        actorId: user.id ?? '-',
        actorName: user.name,
        action: 'update_settings',
        target: 'budget_defaults',
        metadata: settings,
      );
    }

    await _loadData();
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan berhasil disimpan.')),
    );
  }

  String _formatTime(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/${date.year} $hour:$minute';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan Admin',
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
          children: [_settingsCard(), const SizedBox(height: 16), _auditCard()],
        ),
      ),
    );
  }

  Widget _settingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Default Budget',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _field('Tiket masuk fallback', _ticketController, 'Rp'),
          _field('Parkir motor', _motorParkingController, 'Rp'),
          _field('Parkir mobil', _carParkingController, 'Rp'),
          _field('Dana darurat', _emergencyController, '%'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Pengaturan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _auditCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audit Aktivitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_auditLogs.isEmpty)
            const Text(
              'Belum ada aktivitas admin tercatat.',
              style: TextStyle(color: Colors.black54),
            )
          else
            ..._auditLogs.map((log) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  child: Icon(Icons.history, size: 18),
                ),
                title: Text(
                  '${log['actor_name'] ?? 'Admin'} - ${log['action'] ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${log['target'] ?? '-'}\n${_formatTime(log['created_at'])}',
                ),
                isThreeLine: true,
              );
            }),
        ],
      ),
    );
  }
}
