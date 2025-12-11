import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';

// ⬇️ tambahkan import ini
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemTapped;

  /// kalau true, BottomNavBar akan otomatis:
  /// - baca role user dari koleksi `users`
  /// - melakukan Navigator.pushReplacementNamed sesuai role
  final bool useRoleRouting;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    this.onItemTapped,
    this.useRoleRouting = false,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String? _role;
  bool _isLoadingRole = false;

  @override
  void initState() {
    super.initState();
    if (widget.useRoleRouting) {
      _isLoadingRole = true;
      _loadRole();
    }
  }

  Future<void> _loadRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _role = 'mahasiswa';
          _isLoadingRole = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final role = (data?['role'] as String?) ?? 'mahasiswa';

      if (!mounted) return;
      setState(() {
        _role = role.toLowerCase();
        _isLoadingRole = false;
      });
    } catch (e) {
      debugPrint('Gagal load role user: $e');
      if (!mounted) return;
      setState(() {
        _role = 'mahasiswa';
        _isLoadingRole = false;
      });
    }
  }

  void _handleTap(BuildContext context, int index) {
    // kalau masih loading role dan developer mau dengar event-nya
    if (!_isLoadingRole && !widget.useRoleRouting) {
      widget.onItemTapped?.call(index);
      return;
    }

    final role = (_role ?? 'mahasiswa').toLowerCase();
    final bool isAdmin = role == 'admin' || role == 'super_admin';

    String? route;

    if (isAdmin) {
      // ====== RUTE ADMIN ======
      switch (index) {
        case 0:
          route = '/home'; // dashboard admin
          break;
        case 1:
          route = '/manage'; // kelola kelas/fasilitas
          break;
        case 2:
          route = '/notification'; // halaman tinjau peminjaman
          break;
        case 3:
          route = '/booking_history'; // riwayat booking versi admin
          break;
        case 4:
          route = '/profile';
          break;
      }
    } else {
      // ====== RUTE USER (mahasiswa / dosen) ======
      switch (index) {
        case 0:
          route = '/home_user';
          break;
        case 1:
          route = '/manage_user';
          break;
        case 2:
          route = '/user_notification';
          break;
        case 3:
          route = '/user_history';
          break;
        case 4:
          route = '/profile';
          break;
      }
    }

    if (route == null) return;

    // hindari push route yang sama berulang
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double iconWidth = isSmallScreen ? 30 : 40;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: isSmallScreen ? 56 : 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                assetPath: 'lib/assets/icons/beranda.png',
                index: 0,
                selectedIndex: widget.selectedIndex,
                onTap: (i) => _handleTap(context, i),
                width: iconWidth,
              ),
              _NavItem(
                assetPath: 'lib/assets/icons/Kelola fasilitas.png',
                index: 1,
                selectedIndex: widget.selectedIndex,
                onTap: (i) => _handleTap(context, i),
                width: iconWidth,
              ),
              _NavItem(
                assetPath: 'lib/assets/icons/notifikasi.png',
                index: 2,
                selectedIndex: widget.selectedIndex,
                onTap: (i) => _handleTap(context, i),
                width: iconWidth,
              ),
              _NavItem(
                assetPath: 'lib/assets/icons/laporan.png',
                index: 3,
                selectedIndex: widget.selectedIndex,
                onTap: (i) => _handleTap(context, i),
                width: iconWidth,
              ),
              _NavItem(
                assetPath: 'lib/assets/icons/Settings.png',
                index: 4,
                selectedIndex: widget.selectedIndex,
                onTap: (i) => _handleTap(context, i),
                width: iconWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// NAV ITEM (sedikit diubah tipe onTap-nya)
class _NavItem extends StatelessWidget {
  final String assetPath;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double width;

  const _NavItem({
    required this.assetPath,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              assetPath,
              width: isSelected ? 26 : 24,
              height: isSelected ? 26 : 24,
              color:
                  isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 2),
            Container(
              height: 3,
              width: 18,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
