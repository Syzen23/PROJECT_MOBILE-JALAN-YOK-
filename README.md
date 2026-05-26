# 🚀 JalanYok

### Aplikasi Perencanaan Perjalanan dan Pengelolaan Anggaran Wisatawan Berbasis Mobile

---

## 📌 Deskripsi Proyek

**JalanYok** adalah aplikasi mobile yang membantu pengguna dalam merencanakan perjalanan wisata sekaligus mengelola anggaran secara efisien.
Aplikasi ini menyediakan informasi destinasi wisata, estimasi biaya perjalanan, serta analisis kecukupan budget secara otomatis.

---

## 🎯 Tujuan Pengembangan

* Membantu pengguna menemukan destinasi wisata di Indonesia
* Mempermudah perencanaan perjalanan
* Mengelola anggaran perjalanan secara efektif
* Mengurangi risiko overbudget saat wisata

---

## 💡 Permasalahan yang Diselesaikan

* Informasi wisata tersebar di berbagai platform
* Perencanaan perjalanan masih dilakukan secara manual
* Sulit memperkirakan total biaya perjalanan
* Risiko kehabisan budget saat perjalanan

---

## 🛠️ Solusi yang Ditawarkan

JalanYok menyediakan:

* Informasi destinasi wisata dalam satu platform
* Detail wisata (lokasi, harga tiket, deskripsi, rating)
* Estimasi biaya perjalanan otomatis
* Analisis kecukupan budget
* Penyimpanan riwayat perjalanan

---

## ✨ Fitur Utama

### 🏝️ Eksplorasi Destinasi

* Pencarian berdasarkan nama atau kategori
* Kategori: pantai, gunung, air terjun, budaya

### 📍 Detail Destinasi

* Foto wisata
* Deskripsi lengkap
* Harga tiket
* Lokasi & alamat
* Rating

### 🗺️ Perencanaan Perjalanan

* Input lokasi awal
* Pilih destinasi
* Pilih jenis kendaraan
* Input budget

### ⛽ Estimasi Biaya

* Perhitungan jarak & waktu tempuh
* Estimasi biaya bahan bakar
* Total biaya perjalanan

### 💰 Pengelolaan Anggaran

* Input biaya tambahan (tiket, parkir, makan, penginapan)
* Analisis budget (cukup / tidak)
* Informasi sisa / kekurangan dana

### 📜 Riwayat Perjalanan

* Menyimpan data perjalanan
* Melihat kembali perjalanan sebelumnya

---

## 🔄 Alur Sistem

1. User login ke aplikasi
2. Sistem menampilkan destinasi wisata
3. User memilih destinasi
4. User menginput data perjalanan
5. Sistem mengambil data lokasi (GPS & Maps API)
6. Sistem menghitung estimasi biaya
7. Sistem menganalisis kecukupan budget
8. Sistem menampilkan hasil
9. Data perjalanan dapat disimpan ke database

---

## 🧠 Logika Perhitungan

* **Jarak & waktu** → dari Maps API
* **Biaya BBM** → berdasarkan jarak & jenis kendaraan
* **Total biaya** → BBM + biaya tambahan
* **Analisis budget**:

  * Jika budget ≥ total biaya → *Cukup*
  * Jika budget < total biaya → *Tidak Cukup*

---

## 🗄️ Struktur Database

### User

* id (PK)
* name
* email
* password
* profile_image

### Categories

* id (PK)
* name
* icon

### Destinations

* id (PK)
* category_id (FK)
* name
* province
* city
* address
* description
* ticket_price
* rating
* latitude
* longitude
* image_url

### Trips

* id (PK)
* user_id (FK)
* destination_id (FK)
* start_location
* vehicle_type
* budget
* distance
* duration
* fuel_cost
* total_cost
* budget_status
* remaining_budget
* created_at

### Trip Expenses

* id (PK)
* trip_id (FK)
* ticket_cost
* parking_cost
* food_cost
* lodging_cost

---

## 🏗️ Tech Stack & API

* **Frontend:** Flutter
* **Backend & Database:** Firebase Authentication, Cloud Firestore
* **API Terintegrasi:**
  * **Groq API (Llama 3):** Untuk fitur asisten AI (Chatbot) travel.
  * **OpenStreetMap (OSRM) & Nominatim API:** Untuk fitur peta, pencarian lokasi, dan routing navigasi (menggantikan Google Maps API).
  * **MockAPI / REST API:** Untuk manajemen data destinasi pariwisata dari server eksternal.
  * **Database Kendaraan Lokal:** Database embedded berisi 80+ kendaraan Indonesia (menggantikan API eksternal kendaraan).

---

## 📊 Status Pengembangan

| Komponen             | Status        |
| -------------------- | ------------- |
| UI/UX Design         | ✅ 100%        |
| Database Design      | ✅ 100%        |
| Implementasi Flutter | ⏳ 30%         |
| Integrasi API        | ⏳ On Progress |
| Testing              | ⏳ Belum       |

---

## 📌 Scope & Batasan Sistem

* Aplikasi berbasis mobile (Android)
* Data disimpan secara lokal (SQLite)
* Fokus pada perencanaan perjalanan individu
* Tidak mencakup fitur booking atau pembayaran

---

## 🤝 Panduan Kolaborasi

* Gunakan branch sesuai fitur (feature/nama-fitur)
* Lakukan commit dengan pesan yang jelas
* Pull request wajib sebelum merge ke main
* Hindari perubahan langsung di branch utama

---

## 📈 Pengembangan Selanjutnya

* Integrasi online database
* Fitur rekomendasi destinasi (AI)
* Sinkronisasi antar perangkat
* Integrasi booking & pembayaran

---

## 👥 Tim Pengembang

**Universitas Teknokrat Indonesia**

Kelompok: **Izin Serius**

Anggota:
1. Ma'ruf Budi Santoso (24312031)
2. M. Sajid Izzulhaq (24312039)
3. M. Atha Dzaki Yunada (24312029)
4. Erwin Wijaya (24312092)
5. Farrel Ady Rangga (24312019)

---

## 📬 Penutup

Dokumentasi ini dibuat sebagai acuan utama pengembangan aplikasi JalanYok agar seluruh stakeholder memiliki pemahaman yang sama terhadap sistem yang dibangun.
