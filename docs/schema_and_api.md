# SPARE App — Data Schema & API Specification

Dokumen ini merinci skema data (model) dan spesifikasi API (REST/Firestore style) untuk aplikasi SPARE (fasilitas & ruang kelas).

---

## Ringkasan entitas utama

- User
- Facility (Fasilitas)
- Room (RuangKelas)
- Booking / Loan (Peminjaman)
- Notification
- Report (Laporan) — biasanya derived dari Booking / Facility / Room

---

## Pilihan penyimpanan rekomendasi

- Pilihan cepat & terukur: **Firebase Firestore** untuk prototyping + Auth (Firebase Auth) jika akan pakai backend serverless.
- Alternatif lokal (untuk prototype offline): **Hive** atau **SQLite (sqflite)**.

Keuntungan Firestore: realtime updates (berguna untuk status room availability), otentikasi terintegrasi, rules untuk security.

---

## 1) Model: User

Tujuan: menyimpan informasi user (Mahasiswa / Dosen / Admin)

Contoh struktur (Firestore document)

Collection: `users` (docId = uid atau NIM/NIP jika unik)

{
  "id": "user_abc123",            // uid atau generated id
  "type": "student" | "lecturer" | "admin",
  "role": "user" | "admin",     // tambahan untuk otorisasi
  "nim": "12345678",              // untuk mahasiswa (opsional jika admin)
  "nip": "08123456",              // untuk dosen (opsional)
  "username": "admin1",
  "email": "admin@gmail.com",
  "name": "Nama Lengkap",
  "phone": "+6285...",
  "department": "Teknik Informatika",
  "avatarUrl": "https://...",
  "createdAt": 1670000000000,
  "updatedAt": 1670000000000,
  "isActive": true
}

Index yang direkomendasikan: `type`, `nim`, `nip`, `email` untuk pencarian.

---

## 2) Model: Facility (Fasilitas)

Collection: `facilities`

{
  "id": "fac_001",
  "name": "Proyektor Epson X123",
  "description": "Proyektor untuk ruang A101",
  "category": "audio-visual",      // elektronik, alat tulis, audio-visual, dll
  "quantity": 5,                     // total unit
  "available": 3,                    // unit tersedia
  "status": "available" | "borrowed" | "broken" | "lost",
  "location": "Gudang Gedung A",
  "images": ["https://.../img1.jpg"],
  "createdBy": "user_adminId",
  "createdAt": 1670000000000,
  "updatedAt": 1670000000000
}

Fitur: CRUD, upload foto (store URL di `images`).

Queries umum: filter by `category`, `status`, `available > 0`.

---

## 3) Model: Room (RuangKelas)

Collection: `rooms`

{
  "id": "room_A101",
  "name": "A101",
  "building": "Gedung A",
  "floor": 1,
  "capacity": 40,
  "facilities": ["Proyektor", "Kipas"],
  "locationNotes": "Dekat tangga utama",
  "images": [],
  "createdAt": 1670000000000,
  "updatedAt": 1670000000000
}

Jadwal pemakaian (bisa disimpan sebagai subcollection `rooms/{roomId}/schedules`):

Subcollection `schedules` document:
{
  "id": "sched_2025_11_05_09_11",
  "start": 1699174800000, // epoch ms
  "end": 1699182000000,
  "title": "Matakuliah X",
  "ownerId": "user_abc123",
  "type": "class" | "event" | "reservation",
  "createdAt": 1670000000000
}

Query "cek ruangan kosong sekarang": cari schedule yang tumpang tindih; jika tidak ada => kosong.

---

## 4) Model: Booking / Loan (Peminjaman)

Collection: `bookings` (atau `loans`)

{
  "id": "booking_0001",
  "type": "facility" | "room",    // tipe peminjaman
  "itemId": "fac_001" | "room_A101", // id dari facility atau room
  "units": 1,                         // untuk fasilitas: jumlah unit
  "requesterId": "user_abc123",
  "requesterName": "Budi",
  "requesterEmail": "budi@...",
  "start": 1699174800000,
  "end": 1699182000000,
  "purpose": "Praktikum/Presentasi",
  "classInfo": {
    "course": "IF123",
    "lecturer": "Dr. X"
  },
  "status": "pending" | "approved" | "rejected" | "returned",
  "adminNote": "",
  "approvedBy": "admin_01",
  "createdAt": 1670000000000,
  "updatedAt": 1670000000000
}

Alur: user membuat booking -> status `pending` -> admin melihat daftar -> `approved` atau `rejected`.

Jika `approved` dan type == facility, kurangi `facilities.available` sesuai `units`; jika `returned`, kembalikan.

---

## 5) Model: Notification (opsional)

Collection: `notifications` (per user atau global)

{
  "id": "notif_001",
  "userId": "user_abc123", // null untuk global
  "title": "Pengajuan Disetujui",
  "body": "Pengajuan fasilitas proyektor Anda disetujui",
  "type": "booking_update" | "system",
  "data": {"bookingId": "booking_0001"},
  "createdAt": 1670000000000,
  "read": false
}

---

## 6) Report

Laporan dibuat dengan meng-aggregate collection `bookings`, `facilities`, `rooms`.
Contoh field pada exported CSV/PDF: tanggal, id booking, user, item, jenis, durasi, status.

---

## API Endpoints (REST-style) — contoh base paths

Base: `/api/v1`
Authentication: Bearer token (JWT) or Firebase ID token

Auth
- POST `/auth/login`  (body: { username, password })
  - response: { token, user }
- POST `/auth/logout`
- POST `/auth/forgot-password` (body: { email / nim / nip })

Users
- GET `/users/{id}`
- POST `/users` (add admin / seed)
- PUT `/users/{id}` (update profile)
- GET `/users?role=lecturer|student|admin&search=...`

Facilities
- GET `/facilities`  (params: ?category=&status=&q=&page=&limit=)
- GET `/facilities/{id}`
- POST `/facilities` (admin) — body: { name, category, quantity, location, images }
- PUT `/facilities/{id}` (admin)
- DELETE `/facilities/{id}` (admin)

Rooms
- GET `/rooms` (?building=&capacity=&q=&page=&limit=)
- GET `/rooms/{id}`
- POST `/rooms` (admin)
- PUT `/rooms/{id}`
- DELETE `/rooms/{id}`
- POST `/rooms/{id}/schedules` (admin or user request)
- GET `/rooms/{id}/schedules?date=YYYY-MM-DD`

Bookings
- GET `/bookings` (?status=&type=&requesterId=&page=&limit=)
- GET `/bookings/{id}`
- POST `/bookings` — body: { type, itemId, start, end, units, purpose }
- PUT `/bookings/{id}` — (admin: approve/reject/update)
  - body: { status: 'approved'|'rejected'|'returned', adminNote }
- DELETE `/bookings/{id}` (admin)

Notifications
- GET `/notifications?userId=&unreadOnly=true`
- POST `/notifications` (system/admin)
- PUT `/notifications/{id}` (mark read)

Reports
- GET `/reports/bookings?from=&to=&format=pdf|csv`

---

## Status enums & validation rules

- Booking.status ∈ { pending, approved, rejected, returned }
- Facility.status ∈ { available, borrowed, broken, lost }
- type fields must be validated server-side

Input validation examples:
- NIM: 8 digits (regex `^[0-9]{8}$`)
- NIP: numeric (length rule depends on institution)
- Email: valid email format
- start < end, both epoch ms or ISO8601

---

## Concurrency & availability checks

- Untuk meminimalkan race conditions pada `available` unit:
  - Jika menggunakan Firestore: gunakan transaction (batasi read/write operasional untuk decrement available).
  - Jika REST+SQL: gunakan transaction + row locking.

Room availability:
- To check for emptiness at time T: query schedules overlapping T. Overlap test: (start < requestedEnd) && (end > requestedStart)

---

## Security (Firestore rules notes)

- `users/{uid}`: allow read/write to owner or admin
- `facilities/*`: allow read to all authenticated users; write only to admin
- `bookings`: create allowed to authenticated users; update/delete only by admin or owner (with constraints)
- `rooms/*/schedules`: create allowed to admin; or create requests to `bookings` first and admin approves schedule

---

## Example JSON flows

1) Mahasiswa mengajukan peminjaman proyektor
POST /api/v1/bookings
Body:
{
  "type": "facility",
  "itemId": "fac_001",
  "units": 1,
  "requesterId": "user_123",
  "start": 1699174800000,
  "end": 1699182000000,
  "purpose": "Presentasi tugas"
}

Server response 201 Created:
{
  "id": "booking_007",
  "status": "pending",
  "createdAt": 1699...
}

2) Admin melihat pending bookings
GET /api/v1/bookings?status=pending

3) Admin approve
PUT /api/v1/bookings/booking_007
Body: { "status": "approved", "approvedBy": "admin_01" }

Server notes: decrement `facilities.available` via transaction.

---

## Decision & next steps rekomendasi

1. Untuk prototipe cepat: gunakan Firestore + Firebase Auth. Ini memberi realtime updates (bagus untuk cek ruangan kosong) dan memudahkan deployment.
2. Jika butuh offline-first: tambahkan local cache via Hive dan sinkronisasi ke server.
3. Setelah Anda setuju dengan skema ini, langkah selanjutnya yang saya kerjakan:
   - implementasi model Dart + mock service untuk `facilities` & `bookings` (local in-memory)
   - sambungkan `login_page.dart` ke AuthService (sudah ada) untuk routing berdasarkan role
   - buat halaman daftar fasilitas (read-only) + detail

---

## Lampiran: contoh query pencarian ruang kosong (pseudocode)

```
function isRoomAvailable(roomId, desiredStart, desiredEnd):
  schedules = db.collection('rooms').doc(roomId).collection('schedules')
    .where('end', '>', desiredStart).where('start', '<', desiredEnd)
    .get()
  return schedules.empty
```

---

Dokumentasi ini bisa diperbarui saat kita melangkah ke implementasi.
