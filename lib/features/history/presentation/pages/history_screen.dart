import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import 'history_detail_screen.dart';

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

  ImageProvider _imageProvider(String? path) {
    final image = path == null || path.isEmpty
        ? 'assets/images/Pantai.png'
        : path;

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return NetworkImage(image);
    }
    if (image.startsWith('assets/')) {
      return AssetImage(image);
    }
    return FileImage(File(image));
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _imageProvider(item['image'] as String?),
                    ),
                    title: Text(
                      item['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Budget: Rp ${item['total_budget']} | Via: ${item['transport']}\nTanggal: ${item['date']}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryDetailScreen(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
