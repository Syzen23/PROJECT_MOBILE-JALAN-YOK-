import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/user_model.dart';



class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.map((doc) {
            return User.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id);
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
                    child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF007AFF))),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.role == 'admin' ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: user.role == 'admin' ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                  onLongPress: () => _showUserActions(context, user),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserActions(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: Text(user.role == 'admin' ? 'Ubah ke User Biasa' : 'Jadikan Admin'),
                onTap: () async {
                  final newRole = user.role == 'admin' ? 'user' : 'admin';
                  await FirebaseFirestore.instance.collection('users').doc(user.id).update({'role': newRole});
                  if (context.mounted) context.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Pengguna', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
                  if (context.mounted) context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
