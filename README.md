# JalanYok - Travel Planner App ✈️🏖️

JalanYok adalah aplikasi *mobile* berbasis Flutter yang dirancang untuk membantu pengguna merencanakan perjalanan wisata mereka. Aplikasi ini memungkinkan pengguna untuk mencari destinasi wisata, menghitung estimasi biaya perjalanan (BBM, tiket, parkir, makan, penginapan), dan menyimpan riwayat rencana perjalanan mereka.

## 🚀 Fitur Utama

Aplikasi ini menggunakan sistem **Role-Based Access Control** (Admin & User) yang didukung penuh oleh database SQLite lokal.

### 👤 Fitur User
- **Autentikasi**: Sistem Login & Register dinamis.
- **Beranda (Home)**: Menampilkan destinasi populer dan perjalanan terbaru yang diambil langsung dari database.
- **Pencarian (Search)**: Fitur pencarian *real-time* untuk menemukan destinasi wisata.
- **Rencana Perjalanan (Plan)**: 
  - Kalkulator *budget* otomatis (BBM, tiket wisata, parkir berdasarkan jenis kendaraan).
  - Form dinamis untuk menghitung total biaya (Makan, Penginapan, dll).
  - **Simpan ke Riwayat**: Simpan hasil kalkulasi *budget* ke riwayat akun.
- **Riwayat (History)**: Menampilkan daftar rencana perjalanan yang pernah disimpan oleh User yang sedang *login* secara terisolasi (User A tidak bisa melihat riwayat User B).
- **Profil**: Menampilkan informasi akun dan fitur Logout.

### 👑 Fitur Admin
*(Akses khusus menggunakan akun Admin)*
- **Admin Dashboard**: Menampilkan statistik total pengguna terdaftar dan jumlah destinasi yang tersedia.
- **Manajemen Destinasi (CRUD)**:
  - Melihat daftar seluruh destinasi.
  - Menambah destinasi wisata baru (mendukung *input* harga tiket, jarak, dsb).
  - Mengubah (*Edit*) data destinasi yang sudah ada.
  - Menghapus (*Delete*) destinasi.
- **Manajemen Pengguna**: Melihat daftar seluruh pengguna yang terdaftar beserta *role* mereka.

---

## 🛠️ Teknologi & Arsitektur

- **Framework**: Flutter (Dart)
- **Routing**: `go_router` (mendukung *Stateful Nested Navigation* / *Shell Route*)
- **Database Lokal**: `sqflite` & `path`
- **Manajemen Sesi**: `shared_preferences`
- **Arsitektur**: Modular (berbasis fitur)
  - `lib/core/` (Database, Model, Service)
  - `lib/features/` (Home, Plan, Search, History, Profile, Auth, Admin)

---

## 🗄️ Struktur Database (SQLite)

Aplikasi ini mengelola 3 tabel utama secara lokal:
1. **`users`**: `id`, `name`, `email`, `password`, `role` (admin/user)
2. **`destinations`**: `id`, `title`, `location`, `image`, `rating`, `visitors`, `tiket`, `jarak`, `waktu`
3. **`trip_history`**: `id`, `user_id`, `destination_id`, `transport`, `total_budget`, `date`

---

## 🔐 Akun Default (Dummy)

Saat aplikasi pertama kali dijalankan, database akan otomatis membuat tabel dan menyisipkan 2 akun *default* untuk keperluan *testing*:

**1. Akun Admin:**
- **Email:** `admin@jalanyok.com`
- **Password:** `password123`

**2. Akun User Biasa:**
- **Email:** `user@jalanyok.com`
- **Password:** `password123`

> *Anda juga dapat mendaftar sebagai User baru melalui halaman pendaftaran (Sign Up).*

---

## 💻 Cara Menjalankan Aplikasi

1. Pastikan Flutter SDK telah terinstal di komputer Anda.
2. *Clone* repositori ini atau buka folder proyek di IDE Anda (VS Code / Android Studio).
3. Jalankan perintah untuk mengunduh semua dependensi:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi di emulator atau perangkat fisik:
   ```bash
   flutter run
   ```

*(Catatan untuk pengguna Windows: Jika Anda mengalami masalah `shared_preferences` saat build, pastikan mode "Developer Mode" diaktifkan di Windows Settings).*
