import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Row(
                children: [
                  // tidak ada tombol back, mengikuti halaman lain
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola',
                          style: AppTextStyles.heading1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola kelas dan fasilitas peminjaman',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- RINGKASAN CEPAT ----------
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total Kelas',
                      value: '70', // dummy, nanti dari backend
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total Fasilitas',
                      value: '18', // dummy, nanti dari backend
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ---------- AREA KELOLA ----------
              Text(
                'Area Kelola',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Kelola Kelas
              _ManageCard(
                title: 'Kelola Kelas',
                description:
                    'Atur jadwal, cari kelas kosong, dan kelola peminjaman kelas.',
                icon: Icons.meeting_room_outlined,
                gradient: AppColors.mainGradient,
                onTap: () {
                  Navigator.pushNamed(context, '/main_classroom');
                },
              ),

              const SizedBox(height: 16),

              // Kelola Fasilitas
              _ManageCard(
                title: 'Kelola Fasilitas',
                description:
                    'Kelola paket fasilitas, stok, dan peminjaman fasilitas.',
                icon: Icons.shopping_basket_outlined,
                // bisa pakai gradient yang sama agar seragam
                gradient: AppColors.mainGradient,
                onTap: () {
                  Navigator.pushNamed(context, '/admin_facilities');
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ---------- BOTTOM NAV BAR ----------
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1,
        useRoleRouting: true,
      ),

    );
  }
}

// ================== WIDGET KECIL ==================

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ManageCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon besar di kiri
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Chip "Buka"
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Buka',
                style: AppTextStyles.button2.copyWith(
                  color: AppColors.mainGradientStart,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
