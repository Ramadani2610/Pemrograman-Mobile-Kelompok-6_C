import 'package:flutter/material.dart';
import 'package:spareapp_unhas/data/models/facility.dart';
import 'package:spareapp_unhas/presentation/bookings/create_booking_page.dart';

class FacilityDetailPage extends StatelessWidget {
  final Facility facility;
  const FacilityDetailPage({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(facility.name),
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // image placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: facility.images.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(facility.images.first),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: facility.images.isEmpty
                ? Center(
                    child: Icon(Icons.photo, size: 64, color: Colors.grey[500]),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            facility.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${facility.category} • Lokasi: ${facility.location}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(label: Text('Total: ${facility.quantity}')),
              const SizedBox(width: 8),
              Chip(label: Text('Tersedia: ${facility.available}')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            facility.description.isNotEmpty
                ? facility.description
                : 'Tidak ada deskripsi.',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: facility.available > 0
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateBookingPage(facility: facility),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Buat Permintaan'),
          ),
        ],
      ),
    );
  }
}
