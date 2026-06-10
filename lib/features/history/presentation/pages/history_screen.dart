import 'package:flutter/material.dart';

import '../../../../core/widgets/cached_app_image.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/history_refresh_service.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyItems = [];
  bool isLoading = true;
  late final VoidCallback _refreshListener;

  String _fmtCurrency(dynamic value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    final raw = number.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    _refreshListener = () {
      if (mounted) _loadHistory();
    };
    HistoryRefreshService.token.addListener(_refreshListener);
    _loadHistory();
  }

  @override
  void dispose() {
    HistoryRefreshService.token.removeListener(_refreshListener);
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      final data = await FirestoreService.instance.getTripHistoryForUser(
        user.id!,
      );
      if (!mounted) return;
      setState(() {
        historyItems = data;
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Perjalanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: historyItems.isEmpty
          ? const Center(child: Text('Belum ada riwayat perjalanan'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                final location = item['location']?.toString() ?? '-';
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: appImageProvider(
                        item['image'] as String?,
                      ),
                    ),
                    title: Text(
                      item['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$location\nRp ${_fmtCurrency(item['total_budget'])} | Via: ${item['transport']} | ${item['date']}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    isThreeLine: true,
                    onTap: () async {
                      final updatedItem =
                          await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryDetailScreen(item: item),
                            ),
                          );
                      if (updatedItem != null && mounted) {
                        if (updatedItem['deleted'] == true) {
                          setState(() => historyItems.removeAt(index));
                        } else {
                          setState(() => historyItems[index] = updatedItem);
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
