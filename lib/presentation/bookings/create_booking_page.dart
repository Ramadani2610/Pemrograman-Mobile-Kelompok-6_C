import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spareapp_unhas/data/models/facility.dart';
import 'package:spareapp_unhas/data/models/booking.dart';
import 'package:spareapp_unhas/data/services/mock_booking_service.dart';
import 'package:spareapp_unhas/data/services/mock_facility_service.dart';

class CreateBookingPage extends StatefulWidget {
  final Facility facility;
  const CreateBookingPage({super.key, required this.facility});

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _purposeCtrl = TextEditingController();
  int _quantity = 1;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 3));

  final bookingService = MockBookingService.instance;
  final facilityService = MockFacilityService.instance;

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_start),
      );
      if (t != null) {
        setState(() {
          _start = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          if (!_end.isAfter(_start))
            _end = _start.add(const Duration(hours: 1));
        });
      }
    }
  }

  Future<void> _pickEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_end),
      );
      if (t != null) {
        setState(() {
          _end = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        });
      }
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final facility = widget.facility;
    if (_quantity > facility.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah melebihi ketersediaan')),
      );
      return;
    }

    final b = Booking(
      id: '',
      userId: 'user001',
      facilityId: facility.id,
      startDate: _start,
      endDate: _end,
      purpose: _purposeCtrl.text,
      quantity: _quantity,
    );

    bookingService.add(b);

    // reduce available locally
    facility.available = (facility.available - _quantity).clamp(
      0,
      facility.quantity,
    );
    facilityService.update(facility.id, facility);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Permintaan terkirim')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.facility;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Peminjaman'),
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(f.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Tersedia: ${f.available} • Total: ${f.quantity}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeCtrl,
                decoration: const InputDecoration(labelText: 'Keperluan'),
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Keperluan wajib diisi' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Jumlah:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _quantity,
                    items:
                        List.generate(
                              f.available > 0 ? f.available : 1,
                              (i) => i + 1,
                            )
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toString()),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _quantity = v ?? 1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Waktu Mulai'),
                subtitle: Text(fmt.format(_start)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  onPressed: _pickStart,
                ),
              ),
              ListTile(
                title: const Text('Waktu Selesai'),
                subtitle: Text(fmt.format(_end)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  onPressed: _pickEnd,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submit,
                child: const Text('Kirim Permintaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
