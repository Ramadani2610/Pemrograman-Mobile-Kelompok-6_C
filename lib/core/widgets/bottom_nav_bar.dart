import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

      return SafeArea(
        top: false, 
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.mainGradient,
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 6,
            bottom: 6 + bottomPadding, 
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 5;

            return SizedBox(
              height: 64,
              child: Stack(
                children: [
                  // ===== Garis putih di atas tab aktif =====
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    left: selectedIndex * itemWidth,
                    top: 0,
                    width: itemWidth,
                    child: Center(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 4),
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // ===== Row ikon + titik =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        assetPath: 'lib/assets/icons/beranda.png',
                        index: 0,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped,
                        width: itemWidth,
                      ),
                      _NavItem(
                        assetPath: 'lib/assets/icons/Kelola fasilitas.png',
                        index: 1,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped,
                        width: itemWidth,
                      ),
                      _NavItem(
                        assetPath: 'lib/assets/icons/notifikasi.png',
                        index: 2,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped,
                        width: itemWidth,
                      ),
                      _NavItem(
                        assetPath: 'lib/assets/icons/laporan.png',
                        index: 3,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped,
                        width: itemWidth,
                      ),
                      _NavItem(
                        assetPath: 'lib/assets/icons/Settings.png',
                        index: 4,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped,
                        width: itemWidth,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String assetPath;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;
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
          mainAxisAlignment: MainAxisAlignment.center, // ⬅️ center vertikal
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              assetPath,
              width: 24,
              height: 24,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );

  }
}
