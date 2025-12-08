import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/presentation/facilities/facility_detail_tabs_page.dart';
import 'package:spareapp_unhas/presentation/facilities/admin_add_facility_dialog.dart';

class AdminFacilitiesPage extends StatelessWidget {
  const AdminFacilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: const Text('Kelola Fasilitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AdminAddFacilityDialog.show(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFacilityCard(
            context,
            'Proyektor',
            '50 Unit tersedia',
            '30 Unit dipinjam',
          ),
          const SizedBox(height: 16),
          _buildFacilityCard(
            context,
            'Terminal',
            '30 Unit tersedia',
            '20 Unit dipinjam',
          ),
          const SizedBox(height: 16),
          _buildFacilityCard(
            context,
            'Remote',
            '10 Unit tersedia',
            '30 Unit dipinjam',
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(
    BuildContext context,
    String name,
    String available,
    String borrowed,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mainGradientStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
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
                    child: const Text(
                      'Selengkapnya...',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              available,
              style: const TextStyle(
               