import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  int _plansCount = 0;
  int _destinationsCount = 0;


  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      final plansSnapshot = await FirebaseFirestore.instance
          .collection('plans')
          .where('userId', isEqualTo: user.id)
          .get();
      
      if (mounted) {
        setState(() {
          _plansCount = plansSnapshot.docs.length;
          _destinationsCount = _plansCount * 2; 
          isLoading = false;
        });
      }
    }
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final currentUser = AuthService.userNotifier.value;
      if (currentUser == null) return;

      final updatedUser = User(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        password: currentUser.password,
        role: currentUser.role,
        phoneNumber: currentUser.phoneNumber,
        age: currentUser.age,
        dateOfBirth: currentUser.dateOfBirth,
        gender: currentUser.gender,
        address: currentUser.address,
        profileImageUrl: base64Image,
      );

      await AuthService.updateProfile(updatedUser);
      // No need to call _loadUser() manually, notifier will handle it
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return ValueListenableBuilder<User?>(
      valueListenable: AuthService.userNotifier,
      builder: (context, currentUser, child) {
        if (currentUser == null) return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(currentUser),
                _buildStats(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Informasi Pribadi'),
                      _buildInfoCard(items: [
                        _buildInfoItem(Icons.email_outlined, 'Email', currentUser.email),
                        _buildInfoItem(Icons.phone_android_outlined, 'No. Telepon', currentUser.phoneNumber ?? '-'),
                        _buildInfoItem(Icons.cake_outlined, 'Tanggal Lahir', currentUser.dateOfBirth ?? '-'),
                      ]),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle('Menu Profil'),
                      _buildMenuCard(items: [
                        _buildMenuItem(Icons.edit_note_rounded, 'Edit Profil', 'Ubah data diri Anda', onTap: () async {
                          await context.push('/edit-profile');
                          _loadUser(); // Still reload stats just in case
                        }),
                        _buildMenuItem(Icons.security_rounded, 'Keamanan', 'Ganti kata sandi', onTap: () => context.push('/change-password')),
                      ]),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Lainnya'),
                      _buildMenuCard(items: [
                        _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi', 'Informasi versi & pengembang', onTap: () => context.push('/about')),
                        _buildMenuItem(Icons.help_outline, 'Pusat Bantuan (FAQ)', 'Tanya jawab seputar aplikasi', onTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman FAQ segera hadir!')));
                        }),
                      ]),

                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                      const SizedBox(height: 12),
                      _buildDeleteAccountButton(currentUser.id!),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(User currentUser) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF007AFF), width: 3),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFEAF4FF),
                  backgroundImage: (currentUser.profileImageUrl != null && currentUser.profileImageUrl!.isNotEmpty)
                      ? MemoryImage(base64Decode(currentUser.profileImageUrl!))
                      : null,
                  child: (currentUser.profileImageUrl == null || currentUser.profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 70, color: Color(0xFF007AFF))
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(currentUser.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          _buildRoleBadge(currentUser.role),

        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),

        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF007AFF), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatItem(_plansCount.toString(), 'Rencana'),
          const SizedBox(width: 60),
          _buildStatDivider(),
          const SizedBox(width: 60),
          _buildStatItem(_destinationsCount.toString(), 'Destinasi'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout),
        label: const Text('Keluar dari Akun'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(String userId) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _confirmDeleteAccount(context, userId),
        child: const Text('Hapus Akun Permanen', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
      ),
    );
  }


  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (context.mounted) context.go('/login');
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun Permanen', style: TextStyle(color: Colors.red)),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.deleteAccount(userId);
      if (context.mounted) context.go('/login');
    }
  }


  Widget _buildInfoCard({required List<Widget> items}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Column(children: items),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey),
          title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100, indent: 60),
      ],
    );
  }

  Widget _buildMenuCard({required List<Widget> items}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 24, color: const Color(0xFF007AFF)),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100, indent: 60),
      ],
    );
  }
}
