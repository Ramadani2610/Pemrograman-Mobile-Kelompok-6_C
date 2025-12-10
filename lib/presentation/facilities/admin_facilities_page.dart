import 'package:flutter/material.dart';
import 'package:spareapp_unhas/presentation/facilities/facility_detail_tabs_page.dart';
import 'package:spareapp_unhas/presentation/facilities/admin_add_facility_dialog.dart';

class AdminFacilitiesPage extends StatelessWidget {
  const AdminFacilitiesPage({super.key});

  // Data fasilitas - DENGAN PATH YANG DIPERBAIKI
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'Kelola Fasilitas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color(0xFFD32F2F),
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
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 248, 248, 248),
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

  Widget _buildFacilityCard(BuildContext context, Map<String, dynamic> facility) {
    String name = facility['name'];
    int available = facility['available'];
    int borrowed = facility['borrowed'];
    int broken = facility['broken'];
    String imagePath = facility['image'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE0E0E0), // Warna border abu-abu terang sesuai gambar
          width: 1.5, // Ketebalan border sedikit lebih tebal
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama fasilitas dan tombol selengkapnya
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3), // Warna biru untuk tombol
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1976D2), // Border biru sedikit lebih gelap
                      width: 1,
                    ),
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
                        color: Colors.white, // Teks putih
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Konten: Gambar dan Informasi
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar fasilitas
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0), // Border abu-abu terang
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(imagePath),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Informasi fasilitas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.check_circle_outline,
                        'Tersedia: $available Unit',
                        const Color.fromARGB(255, 76, 76, 175),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.history_toggle_off,
                        'Dipinjam: $borrowed Unit',
                        Colors.orange,
                      ),
                      if (broken > 0) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.error_outline,
                          'Rusak: $broken Unit',
                          Colors.red,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            // TIDAK ADA TOMBOL EDIT/HAPUS LAGI
            // TIDAK ADA GARIS PEMISAH LAGI
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun widget gambar dengan error handling
  Widget _buildImageWidget(String imagePath) {
    return Image.asset(
      imagePath,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        
        // Coba beberapa kemungkinan path alternatif
        List<String> alternativePaths = [
          imagePath,
          imagePath.replaceFirst('assets/', 'lib/assets/'),
          imagePath.replaceFirst('lib/assets/', 'assets/'),
          'assets/icons/Logo-Resmi-Unhas-1.png',
        ];
        
        for (int i = 1; i < alternativePaths.length; i++) {
          try {
            return Image.asset(
              alternativePaths[i],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            );
          } catch (e) {
            continue;
          }
        }
        
        return Container(
          width: 100,
          height: 100,
          color: const Color(0xFFF5F5F5), // Warna abu-abu sangat terang
          child: const Center(
            child: Icon(
              Icons.image,
              size: 40,
              color: Color(0xFF9E9E9E), // Warna abu-abu sedang
            ),
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}