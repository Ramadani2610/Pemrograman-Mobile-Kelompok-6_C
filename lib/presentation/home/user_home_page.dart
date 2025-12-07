import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFD32F2F);

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Beranda'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selamat datang, User!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Ini adalah halaman beranda untuk Mahasiswa/Dosen.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Buka Profil'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/facilities'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Lihat Fasilitas'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/booking_history'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Riwayat Peminjaman'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
