# Wisata & Kendaraan API

Mock API berbasis Express untuk data wisata Indonesia dan data kendaraan.

## Base URL

- Production: `https://mobile-api-beryl.vercel.app`
- Local: `http://localhost:3000`

## Menjalankan Project

```bash
npm install
npm run start
```

Server berjalan di `http://localhost:3000`.

## API Docs (Swagger)

- UI: `/api-docs`
- JSON: `/api-docs/swagger.json`

## Endpoint Wisata

Base path: `/api/data`

- `GET /api/data` ambil semua data wisata
- `GET /api/data/:id` ambil data wisata berdasarkan ID
- `POST /api/data` tambah data wisata
- `PUT /api/data/:id` update data wisata
- `DELETE /api/data/:id` hapus data wisata

Contoh body `POST/PUT` wisata:

```json
{
  "nama": "Danau Kelimutu",
  "kategori": "Danau",
  "kota": "Ende",
  "provinsi": "NTT",
  "rating": 4.9,
  "gambar": "https://example.com/image.jpg",
  "deskripsi": "Danau kawah dengan tiga warna."
}
```

## Endpoint Kendaraan

Base path: `/api/kendaraan`

- `GET /api/kendaraan` ambil semua data kendaraan (sudah dipisah `motor` dan `mobil`)
- `GET /api/kendaraan/:id` ambil kendaraan berdasarkan ID
- `POST /api/kendaraan` tambah data kendaraan
- `PUT /api/kendaraan/:id` update data kendaraan
- `DELETE /api/kendaraan/:id` hapus data kendaraan

Contoh response `GET /api/kendaraan`:

```json
{
  "success": true,
  "total": 20,
  "total_motor": 9,
  "total_mobil": 11,
  "data": {
    "motor": [],
    "mobil": []
  }
}
```

Contoh body `POST/PUT` kendaraan:

```json
{
  "merk": "Honda",
  "model": "CBR150R",
  "tahun": 2023,
  "cc": 150,
  "jenis_kendaraan": "Motor",
  "transmisi": "Manual",
  "jenis_bensin": "Pertamax",
  "kapasitas_tangki_liter": 12,
  "warna": "Merah",
  "harga": 38000000
}
```

Catatan:

- Jika `jenis_kendaraan` bernilai `Motor` (tidak case-sensitive), data masuk ke kategori `motor`.
- Selain itu, data akan masuk ke kategori `mobil`.
