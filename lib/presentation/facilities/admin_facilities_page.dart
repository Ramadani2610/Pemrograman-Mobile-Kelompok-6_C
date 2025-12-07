import 'package:flutter/material.dart';
import 'package:spareapp_unhas/data/models/facility.dart';
import 'package:spareapp_unhas/data/services/mock_facility_service.dart';

class AdminFacilitiesPage extends StatefulWidget {
  const AdminFacilitiesPage({super.key});

  @override
  State<AdminFacilitiesPage> createState() => _AdminFacilitiesPageState();
}

class _AdminFacilitiesPageState extends State<AdminFacilitiesPage> {
  final service = MockFacilityService.instance;
  List<Facility> items = [];

  @override
  void initState() {
    super.initState();
    service.seed();
    _load();
  }

  void _load() {
    setState(() {
      items = service.getAll();
    });
  }

  Future<void> _showFacilityDialog({Facility? edit}) async {
    final nameCtrl = TextEditingController(text: edit?.name ?? '');
    final descCtrl = TextEditingController(text: edit?.description ?? '');
    final catCtrl = TextEditingController(text: edit?.category ?? '');
    final qtyCtrl = TextEditingController(
      text: edit?.quantity.toString() ?? '1',
    );
    final availCtrl = TextEditingController(
      text: edit?.available.toString() ?? '1',
    );
    final locCtrl = TextEditingController(text: edit?.location ?? '');

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          edit == null ? 'Tambah Fasilitas Baru' : 'Edit Fasilitas',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Fasilitas',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: catCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                    hintText: 'contoh: audio-visual, elektronik',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: qtyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Total',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => int.tryParse(v ?? '') == null
                            ? 'Harus angka'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: availCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tersedia',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => int.tryParse(v ?? '') == null
                            ? 'Harus angka'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: locCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final qty = int.tryParse(qtyCtrl.text) ?? 1;
                final avail = int.tryParse(availCtrl.text) ?? qty;

                if (edit == null) {
                  service.add(
                    Facility(
                      id: '',
                      name: nameCtrl.text,
                      description: descCtrl.text,
                      category: catCtrl.text,
                      quantity: qty,
                      available: avail,
                      location: locCtrl.text,
                    ),
                  );
                } else {
                  edit.name = nameCtrl.text;
                  edit.description = descCtrl.text;
                  edit.category = catCtrl.text;
                  edit.quantity = qty;
                  edit.available = avail;
                  edit.location = locCtrl.text;
                  service.update(edit.id, edit);
                }

                Navigator.pop(context, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) _load();
  }

  void _delete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Fasilitas?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus fasilitas ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              service.delete(id);
              Navigator.pop(context);
              _load();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fasilitas berhasil dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Fasilitas'),
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada fasilitas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah fasilitas baru',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final f = items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showFacilityDialog(edit: f),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      f.category,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') {
                                    _showFacilityDialog(edit: f);
                                  } else if (v == 'del') {
                                    _delete(f.id);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'del',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            f.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text('${f.available}/${f.quantity}'),
                                backgroundColor: f.available > 0
                                    ? Colors.green[100]
                                    : Colors.red[100],
                              ),
                              Text(
                                f.location,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFacilityDialog(),
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add),
      ),
    );
  }
}
