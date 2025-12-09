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
            '5 Unit rusak',
          ),
          const SizedBox(height: 16),
          _buildFacilityCard(
            context,
            'Terminal',
            '30 Unit tersedia',
            '20 Unit dipinjam',
            '0 Unit rusak',
          ),
          const SizedBox(height: 16),
          _buildFacilityCard(
            context,
            'Remote',
            '10 Unit tersedia',
            '30 Unit dipinjam',
            '3 Unit rusak',
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
    String broken,
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
                    // Mengganti withOpacity dengan Color.fromRGBO
                    color: Color.fromRGBO(211, 47, 47, 0.1), // #D32F2F dengan opacity 0.1
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
            Row(
              children: [
                _buildStatusChip(Icons.check_circle, available, Colors.green),
                const SizedBox(width: 8),
                _buildStatusChip(Icons.history, borrowed, Colors.orange),
                const SizedBox(width: 8),
                _buildStatusChip(Icons.error, broken, Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Ganti print dengan SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Edit $name'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Ganti print dengan konfirmasi dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: Text('Hapus fasilitas $name?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$name dihapus'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Di sini kita masih menggunakan withOpacity, tapi ini untuk warna dinamis
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}