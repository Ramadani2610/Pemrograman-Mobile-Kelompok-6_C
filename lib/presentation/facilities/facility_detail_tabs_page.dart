import 'package:flutter/material.dart';

class FacilityDetailTabsPage extends StatefulWidget {
  final String facilityName;

  const FacilityDetailTabsPage({
    super.key,
    required this.facilityName,
  });

  @override
  State<FacilityDetailTabsPage> createState() => _FacilityDetailTabsPageState();
}

class _FacilityDetailTabsPageState extends State<FacilityDetailTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.facilityName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD32F2F),
          labelColor: const Color(0xFFD32F2F),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Tersedia'),
            Tab(text: 'Dipinjam'),
            Tab(text: 'Lainnya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableTab(),
          _buildBorrowedTab(),
          _buildOtherTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableTab() {
    List<String> items = ['A1', 'A2', 'A3', 'A5', 'A6'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(
          items[index],
          'Tersedia',
          '15/04/2005',
          'Isab wira',
          showEditButton: false,
        );
      },
    );
  }

  Widget _buildBorrowedTab() {
    List<String> items = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(
          items[index],
          'Dipinjam',
          '15/04/2005',
          'Isab wira',
          showEditButton: true,
        );
      },
    );
  }

  Widget _buildOtherTab() {
    List<String> items = ['R1', 'R2', 'R3', 'R4', 'R5'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(
          items[index],
          'Rusak',
          '15/04/2005',
          '-',
          showEditButton: false,
        );
      },
    );
  }

  Widget _buildItemCard(
    String code,
    String status,
    String entryDate,
    String lastBorrowed, {
    required bool showEditButton,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Kode Item
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromRGBO(211, 47, 47, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Info Item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$code ${widget.facilityName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      color: _getStatusColor(status),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk: $entryDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Kolom Kanan (untuk yang dipinjam)
            if (showEditButton)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lastBorrowed,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tombol Edit
                  OutlinedButton(
                    onPressed: () => _showEditDialog(
                      '$code ${widget.facilityName}',
                      entryDate,
                      lastBorrowed,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return Colors.green;
      case 'Dipinjam':
        return Colors.orange;
      case 'Rusak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(String name, String entryDate, String lastBorrowed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Fasilitas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: 'Nama Fasilitas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: entryDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Masuk',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
               TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Terakhir dipinjam: $lastBorrowed',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perubahan berhasil disimpan'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}