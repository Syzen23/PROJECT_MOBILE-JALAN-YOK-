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
              color: Colors.black.withOpacity(0.05),
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
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/Maps.svg', false),
              activeIcon: _buildIcon('assets/images/Maps.svg', true),
              label: 'Rencana',
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
