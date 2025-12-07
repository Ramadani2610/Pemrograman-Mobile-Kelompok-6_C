import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFD32F2F);

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, Color(0xFFB71C1C)],
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/icons/beranda.png',
              width: 24,
              height: 24,
              color: selectedIndex == 0 ? Colors.white : Colors.white70,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/icons/Kelola fasilitas.png',
              width: 24,
              height: 24,
              color: selectedIndex == 1 ? Colors.white : Colors.white70,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/icons/notifikasi.png',
              width: 24,
              height: 24,
              color: selectedIndex == 2 ? Colors.white : Colors.white70,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/icons/laporan.png',
              width: 24,
              height: 24,
              color: selectedIndex == 3 ? Colors.white : Colors.white70,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/icons/Settings.png',
              width: 24,
              height: 24,
              color: selectedIndex == 4 ? Colors.white : Colors.white70,
            ),
            label: '',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}
