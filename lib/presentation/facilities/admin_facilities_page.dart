import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';

import 'package:spareapp_unhas/presentation/facilities/facility_detail_tabs_page.dart';
import 'package:spareapp_unhas/presentation/facilities/admin_add_facility_dialog.dart';

class AdminFacilitiesPage extends StatelessWidget {
  const AdminFacilitiesPage({super.key});

  // Data fasilitas
  final List<Map<String, dynamic>> facilities = const [
    {
      'name': 'Proyektor',
      'available': 50,
      'borrowed': 30,
      'broken': 5,
      'image': 'assets/icons/proyektor.jpg',
    },
    {
      'name': 'Terminal',
      'available': 30,
      'borrowed': 20,
      'broken': 0,
      'image': 'assets/icons/terminal colokan.jpg',
    },
    {
      'name': 'Remote',
      'available': 10,
      'borrowed': 30,
      'broken': 3,
      'image': 'assets/icons/remote-tv.jpg',
    },
    {
      'name': 'Spidol',
      'available': 20,
      'borrowed': 10,
      'broken': 2,
      'image': 'assets/icons/spidol.jpeg',
    },
    {
      'name': 'Kabel HDMI',
      'available': 15,
      'borrowed': 5,
      'broken': 1,
      'image': 'assets/icons/kabel hdmi.jpg',
    },
    {
      'name': 'Penghapus',
      'available': 8,
      'borrowed': 12,
      'broken': 0,
      'image': 'assets/icons/Penghapus.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kelola Fasilitas',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.titleText,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: AppColors.mainGradientStart,
            ),
            onPressed: () => AdminAddFacilityDialog.show(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF7F7F7),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final facility = facilities[index];
            return _buildFacilityCard(context, facility);
          },
        ),
      ),
    );
  }

  Widget _buildFacilityCard(
      BuildContext context, Map<String, dynamic> facility) {
    final String name = facility['name'];
    final int available = facility['available'];
    final int borrowed = facility['borrowed'];
    final int broken = facility['broken'];
    final String imagePath = facility['image'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nama fasilitas + tombol selengkapnya
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacilityDetailTabsPage(
                          facilityName: name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.mainGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Selengkapnya',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Konten: Gambar + info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImageWidget(imagePath),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.check_circle_outline,
                        'Tersedia: $available unit',
                        AppColors.success,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        Icons.history_toggle_off,
                        'Dipinjam: $borrowed unit',
                        AppColors.warning,
                      ),
                      if (broken > 0) ...[
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          Icons.error_outline,
                          'Rusak: $broken unit',
                          AppColors.error,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Gambar dengan fallback
  Widget _buildImageWidget(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // fallback sederhana
        return Container(
          color: AppColors.backgroundColor,
          child: Icon(
            Icons.image,
            size: 40,
            color: AppColors.secondaryText,
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.titleText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
