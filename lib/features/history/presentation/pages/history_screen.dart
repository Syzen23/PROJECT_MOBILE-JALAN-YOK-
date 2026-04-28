import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      final data = await FirestoreService.instance.getTripHistoryForUser(user.id!);
      setState(() {
        historyItems = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Perjalanan', style: TextStyle(fontWeight: FontWeight.bold))),
      body: historyItems.isEmpty
          ? const Center(child: Text('Belum ada riwayat perjalanan'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (item['image'] as String? ?? 'assets/images/Pantai.png').startsWith('assets/')
                          ? AssetImage(item['image'] ?? 'assets/images/Pantai.png')
                          : FileImage(File(item['image'])) as ImageProvider,
                    ),
                    title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Budget: Rp ${item['total_budget']} • Via: ${item['transport']}\nTanggal: ${item['date']}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
