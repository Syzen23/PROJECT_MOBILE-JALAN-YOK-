# 🚀 JalanYok (Technical Documentation)

### Mobile Travel Planning & Budget Management Application

---

## 🏗️ System Overview

JalanYok adalah aplikasi mobile berbasis **Flutter** yang digunakan untuk:

* Manajemen perencanaan perjalanan
* Perhitungan estimasi biaya
* Analisis kecukupan anggaran

Sistem menggunakan:

* **Local Database (SQLite)** untuk penyimpanan data
* **Maps API** untuk perhitungan jarak dan waktu tempuh

---

## 🧱 System Architecture

```
[ UI Layer (Flutter) ]
        ↓
[ Business Logic Layer ]
        ↓
[ Data Layer (SQLite) ]
        ↓
[ External API (Maps) ]
```

---

## 🔄 System Workflow

### 1. Authentication

* Input: email, password
* Validasi: query ke tabel `user`
* Output: akses ke sistem

---

### 2. Fetch Destinations

* Query data dari tabel `destinations`
* Filter berdasarkan:

  * category
  * keyword search

---

### 3. Select Destination

* User memilih destinasi
* Data disimpan sementara (state)

---

### 4. Input Trip Data

Input:

* start_location
* destination_id
* vehicle_type
* budget
* additional_costs

---

### 5. Location Processing

* Ambil koordinat user (GPS)
* Hitung:

  * distance
  * duration
    menggunakan Maps API

---

### 6. Cost Calculation

#### Fuel Cost:

```
fuel_cost = distance × fuel_rate(vehicle_type)
```

#### Total Cost:

```
total_cost = fuel_cost + ticket_cost + parking_cost + food_cost + lodging_cost
```

---

### 7. Budget Analysis

```
if (budget >= total_cost):
    status = "Cukup"
    remaining = budget - total_cost
else:
    status = "Tidak Cukup"
    remaining = budget - total_cost
```

---

### 8. Output Result

Menampilkan:

* distance
* duration
* total_cost
* budget_status
* remaining_budget

---

### 9. Data Persistence

* Simpan ke tabel `trips`
* Simpan detail ke `trip_expenses`

---

### 10. History Retrieval

* Query semua data dari `trips`
* Join dengan `destinations`

---

## 🗄️ Database Schema

### 1. User

```
id (PK)
name
email
password
profile_image
```

---

### 2. Categories

```
id (PK)
name
icon
```

---

### 3. Destinations

```
id (PK)
category_id (FK)
name
province
city
address
description
ticket_price
rating
latitude
longitude
image_url
```

---

### 4. Trips

```
id (PK)
user_id (FK)
destination_id (FK)
start_location
vehicle_type
budget
distance
duration
fuel_cost
total_cost
budget_status
remaining_budget
created_at
```

---

### 5. Trip Expenses

```
id (PK)
trip_id (FK)
ticket_cost
parking_cost
food_cost
lodging_cost
```

---

## 🔗 Database Relationships

* 1 User → Many Trips
* 1 Destination → Many Trips
* 1 Trip → 1 Trip Expenses

---

## ⚙️ Tech Stack

* **Frontend:** Flutter
* **Database:** SQLite
* **State Management:** (Optional: Provider / Riverpod)
* **API:** Maps API (distance & duration)

---

## 📂 Project Structure (Flutter)

```
lib/
├── models/
├── services/
├── screens/
├── widgets/
├── database/
└── main.dart
```

---

## 📊 Current Development Status

| Module                 | Status    |
| ---------------------- | --------- |
| UI/UX                  | ✅ 100%    |
| Database Schema        | ✅ 100%    |
| Business Logic         | ⏳ 40%     |
| Flutter Implementation | ⏳ 30%     |
| API Integration        | ⏳ Pending |

---

## ⚠️ System Constraints

* Offline-first (SQLite only)
* Maps API membutuhkan koneksi internet
* Tidak mendukung multi-user real-time
* Tidak ada sistem pembayaran

---

## 🔮 Future Improvements

* Cloud database integration
* AI-based recommendation system
* Real-time sync antar device
* Booking & payment integration

---

## 📌 Notes for Stakeholders

Dokumentasi ini menjadi acuan utama pengembangan sistem untuk memastikan:

* Konsistensi implementasi
* Keselarasan fitur dengan desain awal
* Menghindari scope creep selama development
