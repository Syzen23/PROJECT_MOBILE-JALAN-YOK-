import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF007AFF),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/Home.svg', false),
              activeIcon: _buildIcon('assets/images/Home.svg', true),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 24),
              activeIcon: Icon(Icons.chat, color: Color(0xFF007AFF), size: 24),
              label: 'Chatbot',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/History.svg', false),
              activeIcon: _buildIcon('assets/images/History.svg', true),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/User.svg', false),
              activeIcon: _buildIcon('assets/images/User.svg', true),
              label: 'Saya',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String assetName, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: SvgPicture.asset(
        assetName,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isActive ? const Color(0xFF007AFF) : Colors.grey,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
