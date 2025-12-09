import 'package:flutter/material.dart';
// HAPUS import ini: import 'package:spareapp_unhas/core/constants/app_colors.dart';

class AdminManageFacilitiesPage extends StatelessWidget {
  const AdminManageFacilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header merah dengan tombol kembali
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFAD0001),
                  const Color(0xFFF26C4E),
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Kembali',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Logo SPARE
          Container(
            height: 120,
            color: Colors.white,
            child: Center(
              child: Image.asset(
                'lib/assets/icons/logo_no-bg.png',
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Judul Halaman
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Row(
              children: [
                Text(
                  'Kelola Fasilitas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Sub Judul
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: const Row(
              children: [
                Text(
                  'Daftar Fasilitas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Daftar Fasilitas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                _buildFacilityCard(
                  'Proyektor',
                  '50 Unit',
                  '30 Unit',
                  '5 Unit',
                ),
                _buildFacilityCard(
                  'Terminal',
                  '30 Unit',
                  '20 Unit',
                  '0 Unit',
                ),
                _buildFacilityCard(
                  'Remote',
                  '10 Unit',
                  '30 Unit',
                  '0 Unit',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(
    String name,
    String available,
    String borrowed,
    String broken,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(211, 47, 47, 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _getIcon(name),
                  color: _getColor(name),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    // PERBAIKAN: Ganti .withOpacity() dengan Color.fromRGBO
                    color: Color.fromRGBO(211, 47, 47, 0.1), // #D32F2F dengan opacity 0.1
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Selengkapnya...',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Statistik
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildStatRow('Tersedia:', available),
                const SizedBox(height: 6),
                _buildStatRow('Dipinjam:', borrowed),
                if (broken != '0 Unit') ...[
                  SizedBox(height: 6), // HAPUS 'const' dari sini
                  _buildStatRow('Rusak:', broken),
                ],
              ],
            ),
          ),

          // Garis pemisah
          const Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'Proyektor':
        return Icons.videocam_outlined;
      case 'Terminal':
        return Icons.power_outlined;
      case 'Remote':
        return Icons.settings_remote_outlined;
      default:
        return Icons.devices_other;
    }
  }

  Color _getColor(String name) {
    switch (name) {
      case 'Proyektor':
        return Colors.blue;
      case 'Terminal':
        return Colors.green;
      case 'Remote':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}