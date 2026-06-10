// Database lokal kendaraan populer di Indonesia.
// Data: merk, model, tipe, ukuran mesin (cc), bahan bakar, konsumsi BBM (km/l).

class VehicleEntry {
  final int? id;
  final String make;
  final String model;
  final String type; // City Car, MPV, SUV, Sedan, Pickup, Sport, Matic, Bebek
  final int? year;
  final String? transmission;
  final String? colour;
  final double? tankCapacityLiter;
  final double? price;
  final int engineCc;
  final String fuelType; // Bensin, Solar, Listrik
  final double consumption; // km/l

  const VehicleEntry({
    this.id,
    required this.make,
    required this.model,
    required this.type,
    this.year,
    this.transmission,
    this.colour,
    this.tankCapacityLiter,
    this.price,
    required this.engineCc,
    required this.fuelType,
    required this.consumption,
  });

  factory VehicleEntry.fromApiJson(Map<String, dynamic> json) {
    final kind = json['jenis_kendaraan']?.toString() ?? 'Mobil';
    final cc = (json['cc'] as num?)?.toInt() ?? 0;
    final fuel = json['jenis_bensin']?.toString() ?? 'Bensin';

    return VehicleEntry(
      id: (json['id'] as num?)?.toInt(),
      make: json['merk']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      type: kind,
      year: (json['tahun'] as num?)?.toInt(),
      transmission: json['transmisi']?.toString(),
      colour: json['warna']?.toString(),
      tankCapacityLiter: (json['kapasitas_tangki_liter'] as num?)?.toDouble(),
      price: (json['harga'] as num?)?.toDouble(),
      engineCc: cc,
      fuelType: fuel,
      consumption: _estimateConsumption(kind, cc),
    );
  }

  String get displayName => '$make $model';
  String get engineDisplay =>
      '${(engineCc / 1000).toStringAsFixed(1)}L ($engineCc cc)';
  bool get isMotorcycle =>
      type.toLowerCase().contains('motor') ||
      ['Matic', 'Bebek', 'Sport', 'Trail', 'Retro'].contains(type);

  String get detailInfo {
    final parts = <String>[];
    if (year != null) parts.add('Tahun: $year');
    parts.add(type);
    parts.add(fuelType);
    if (transmission != null && transmission!.isNotEmpty) {
      parts.add(transmission!);
    }
    if (colour != null && colour!.isNotEmpty) parts.add(colour!);
    if (engineCc > 0) parts.add(engineDisplay);
    return parts.join(' | ');
  }

  static double _estimateConsumption(String kind, int cc) {
    if (kind.toLowerCase().contains('motor')) {
      if (cc <= 125) return 50;
      if (cc <= 160) return 42;
      if (cc <= 250) return 32;
      return 28;
    }

    if (cc <= 0) return 12;
    if (cc <= 1200) return 15;
    if (cc <= 1500) return 13;
    if (cc <= 2000) return 11;
    if (cc <= 2500) return 10;
    return 9;
  }
}

class VehicleDatabase {
  static List<String> get carMakes => vehicles
      .where((v) => !v.isMotorcycle)
      .map((v) => v.make)
      .toSet()
      .toList();
  static List<String> get motorcycleMakes =>
      vehicles.where((v) => v.isMotorcycle).map((v) => v.make).toSet().toList();

  static List<VehicleEntry> getByMake(String make, {bool? isMotorcycle}) {
    return vehicles
        .where(
          (v) =>
              v.make.toLowerCase() == make.toLowerCase() &&
              (isMotorcycle == null || v.isMotorcycle == isMotorcycle),
        )
        .toList();
  }

  static List<VehicleEntry> search(String make, String query) {
    final q = query.toLowerCase();
    return vehicles
        .where(
          (v) =>
              v.make.toLowerCase() == make.toLowerCase() &&
              v.model.toLowerCase().contains(q),
        )
        .toList();
  }

  static const List<VehicleEntry> vehicles = [
    // === TOYOTA ===
    VehicleEntry(
      make: 'Toyota',
      model: 'Agya',
      type: 'City Car',
      engineCc: 1197,
      fuelType: 'Bensin',
      consumption: 15,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Calya',
      type: 'LCGC MPV',
      engineCc: 1197,
      fuelType: 'Bensin',
      consumption: 15,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Avanza',
      type: 'MPV',
      engineCc: 1496,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Veloz',
      type: 'MPV',
      engineCc: 1496,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Innova Zenix',
      type: 'MPV',
      engineCc: 1987,
      fuelType: 'Bensin',
      consumption: 10,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Innova Zenix HEV',
      type: 'MPV Hybrid',
      engineCc: 1987,
      fuelType: 'Bensin',
      consumption: 18,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Rush',
      type: 'SUV',
      engineCc: 1496,
      fuelType: 'Bensin',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Fortuner 2.4',
      type: 'SUV',
      engineCc: 2393,
      fuelType: 'Solar',
      consumption: 10,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Fortuner 2.7',
      type: 'SUV',
      engineCc: 2694,
      fuelType: 'Bensin',
      consumption: 8,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Raize',
      type: 'Compact SUV',
      engineCc: 1197,
      fuelType: 'Bensin',
      consumption: 15,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Yaris Cross',
      type: 'Compact SUV',
      engineCc: 1496,
      fuelType: 'Bensin',
      consumption: 14,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Vios',
      type: 'Sedan',
      engineCc: 1496,
      fuelType: 'Bensin',
      consumption: 14,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Camry',
      type: 'Sedan',
      engineCc: 2487,
      fuelType: 'Bensin',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'Hilux',
      type: 'Pickup',
      engineCc: 2393,
      fuelType: 'Solar',
      consumption: 10,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'HiAce',
      type: 'Van',
      engineCc: 2393,
      fuelType: 'Solar',
      consumption: 9,
    ),
    VehicleEntry(
      make: 'Toyota',
      model: 'GR86',
      type: 'Mobil Sport',
      engineCc: 2387,
      fuelType: 'Bensin',
      consumption: 11,
    ),

    // === HONDA ===
    VehicleEntry(
      make: 'Honda',
      model: 'Brio',
      type: 'City Car',
      engineCc: 1199,
      fuelType: 'Bensin',
      consumption: 16,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'Mobilio',
      type: 'MPV',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'BRV',
      type: 'MPV',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'HRV',
      type: 'SUV',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'CRV',
      type: 'SUV',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'City',
      type: 'Sedan',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 14,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'Civic',
      type: 'Sedan',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'Accord',
      type: 'Sedan',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'WRV',
      type: 'Compact SUV',
      engineCc: 1199,
      fuelType: 'Bensin',
      consumption: 15,
    ),

    // === SUZUKI ===
    VehicleEntry(
      make: 'Suzuki',
      model: 'Ertiga',
      type: 'MPV',
      engineCc: 1462,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'XL7',
      type: 'SUV',
      engineCc: 1462,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'Baleno',
      type: 'Hatchback',
      engineCc: 1462,
      fuelType: 'Bensin',
      consumption: 15,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'Ignis',
      type: 'City Car',
      engineCc: 1197,
      fuelType: 'Bensin',
      consumption: 16,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'Jimny 5-Door',
      type: 'SUV',
      engineCc: 1462,
      fuelType: 'Bensin',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'APV',
      type: 'Van',
      engineCc: 1493,
      fuelType: 'Bensin',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'Carry',
      type: 'Pickup',
      engineCc: 1462,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'SX4 S-Cross',
      type: 'Compact SUV',
      engineCc: 1462,
      fuelType: 'Bensin',
      consumption: 14,
    ),

    // === DAIHATSU ===
    VehicleEntry(
      make: 'Daihatsu',
      model: 'Ayla',
      type: 'City Car',
      engineCc: 1197,
      fuelType: 'Bensin',
      consumption: 15,
    ),
    VehicleEntry(
      make: 'Daihatsu',
      model: 'Sigra',
      type: 'LCGC MPV',
      engineCc: 1197,
      fuelType: 'Bensin',
      consumption: 15,
    ),
    VehicleEntry(
      make: 'Daihatsu',
      model: 'Xenia',
      type: 'MPV',
      engineCc: 1496,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Daihatsu',
      model: 'Terios',
      type: 'SUV',
      engineCc: 1496,
      fuelType: 'Bensin',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'Daihatsu',
      model: 'Rocky',
      type: 'Compact SUV',
      engineCc: 1197,
      fuelType: 'Bensin',
      consumption: 15,
    ),
    VehicleEntry(
      make: 'Daihatsu',
      model: 'Gran Max PU',
      type: 'Pickup',
      engineCc: 1298,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Daihatsu',
      model: 'Luxio',
      type: 'Van',
      engineCc: 1495,
      fuelType: 'Bensin',
      consumption: 11,
    ),

    // === MITSUBISHI ===
    VehicleEntry(
      make: 'Mitsubishi',
      model: 'Xpander',
      type: 'MPV',
      engineCc: 1499,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Mitsubishi',
      model: 'Xpander Cross',
      type: 'Crossover',
      engineCc: 1499,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Mitsubishi',
      model: 'Pajero Sport',
      type: 'SUV',
      engineCc: 2442,
      fuelType: 'Solar',
      consumption: 10,
    ),
    VehicleEntry(
      make: 'Mitsubishi',
      model: 'Triton',
      type: 'Pickup',
      engineCc: 2442,
      fuelType: 'Solar',
      consumption: 10,
    ),
    VehicleEntry(
      make: 'Mitsubishi',
      model: 'Outlander PHEV',
      type: 'SUV Hybrid',
      engineCc: 2360,
      fuelType: 'Bensin',
      consumption: 18,
    ),
    VehicleEntry(
      make: 'Mitsubishi',
      model: 'Colt L300',
      type: 'Van',
      engineCc: 2477,
      fuelType: 'Solar',
      consumption: 10,
    ),

    // === NISSAN ===
    VehicleEntry(
      make: 'Nissan',
      model: 'Livina',
      type: 'MPV',
      engineCc: 1499,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Nissan',
      model: 'Magnite',
      type: 'Compact SUV',
      engineCc: 999,
      fuelType: 'Bensin',
      consumption: 16,
    ),
    VehicleEntry(
      make: 'Nissan',
      model: 'Kicks e-Power',
      type: 'SUV Hybrid',
      engineCc: 1198,
      fuelType: 'Bensin',
      consumption: 20,
    ),
    VehicleEntry(
      make: 'Nissan',
      model: 'X-Trail',
      type: 'SUV',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Nissan',
      model: 'Serena',
      type: 'MPV',
      engineCc: 1997,
      fuelType: 'Bensin',
      consumption: 11,
    ),

    // === HYUNDAI ===
    VehicleEntry(
      make: 'Hyundai',
      model: 'Creta',
      type: 'Compact SUV',
      engineCc: 1497,
      fuelType: 'Bensin',
      consumption: 14,
    ),
    VehicleEntry(
      make: 'Hyundai',
      model: 'Stargazer',
      type: 'MPV',
      engineCc: 1497,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Hyundai',
      model: 'Santa Fe',
      type: 'SUV',
      engineCc: 2497,
      fuelType: 'Solar',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'Hyundai',
      model: 'Ioniq 5',
      type: 'SUV Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),
    VehicleEntry(
      make: 'Hyundai',
      model: 'Ioniq 6',
      type: 'Sedan Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),
    VehicleEntry(
      make: 'Hyundai',
      model: 'Palisade',
      type: 'SUV',
      engineCc: 2199,
      fuelType: 'Solar',
      consumption: 10,
    ),

    // === KIA ===
    VehicleEntry(
      make: 'Kia',
      model: 'Sonet',
      type: 'Compact SUV',
      engineCc: 1497,
      fuelType: 'Bensin',
      consumption: 14,
    ),
    VehicleEntry(
      make: 'Kia',
      model: 'Seltos',
      type: 'SUV',
      engineCc: 1497,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Kia',
      model: 'Carens',
      type: 'MPV',
      engineCc: 1497,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Kia',
      model: 'EV6',
      type: 'SUV Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),

    // === MAZDA ===
    VehicleEntry(
      make: 'Mazda',
      model: 'CX-3',
      type: 'Compact SUV',
      engineCc: 1998,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Mazda',
      model: 'CX-5',
      type: 'SUV',
      engineCc: 2488,
      fuelType: 'Bensin',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'Mazda',
      model: 'CX-30',
      type: 'Compact SUV',
      engineCc: 1998,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'Mazda',
      model: 'Mazda3',
      type: 'Sedan',
      engineCc: 1998,
      fuelType: 'Bensin',
      consumption: 14,
    ),

    // === WULING ===
    VehicleEntry(
      make: 'Wuling',
      model: 'Confero',
      type: 'MPV',
      engineCc: 1499,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Wuling',
      model: 'Almaz',
      type: 'SUV',
      engineCc: 1499,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'Wuling',
      model: 'Air EV',
      type: 'City Car Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),
    VehicleEntry(
      make: 'Wuling',
      model: 'BinguoEV',
      type: 'City Car Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),
    VehicleEntry(
      make: 'Wuling',
      model: 'Starlight EV',
      type: 'Sedan Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),

    // === MG ===
    VehicleEntry(
      make: 'MG',
      model: 'ZS',
      type: 'Compact SUV',
      engineCc: 1498,
      fuelType: 'Bensin',
      consumption: 14,
    ),
    VehicleEntry(
      make: 'MG',
      model: 'ZS EV',
      type: 'SUV Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),
    VehicleEntry(
      make: 'MG',
      model: 'HS',
      type: 'SUV',
      engineCc: 1490,
      fuelType: 'Bensin',
      consumption: 12,
    ),
    VehicleEntry(
      make: 'MG',
      model: '4 EV',
      type: 'Hatchback Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),

    // === BMW ===
    VehicleEntry(
      make: 'BMW',
      model: 'X1',
      type: 'Compact SUV',
      engineCc: 1499,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'BMW',
      model: 'X3',
      type: 'SUV',
      engineCc: 1998,
      fuelType: 'Bensin',
      consumption: 11,
    ),
    VehicleEntry(
      make: 'BMW',
      model: '320i',
      type: 'Sedan',
      engineCc: 1998,
      fuelType: 'Bensin',
      consumption: 13,
    ),
    VehicleEntry(
      make: 'BMW',
      model: 'iX',
      type: 'SUV Listrik',
      engineCc: 0,
      fuelType: 'Listrik',
      consumption: 0,
    ),

    // === MOTOR - HONDA ===
    VehicleEntry(
      make: 'Honda',
      model: 'Beat',
      type: 'Matic',
      engineCc: 110,
      fuelType: 'Bensin',
      consumption: 50,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'Vario 125',
      type: 'Matic',
      engineCc: 125,
      fuelType: 'Bensin',
      consumption: 45,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'Vario 160',
      type: 'Matic',
      engineCc: 157,
      fuelType: 'Bensin',
      consumption: 42,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'PCX 160',
      type: 'Matic',
      engineCc: 157,
      fuelType: 'Bensin',
      consumption: 40,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'Scoopy',
      type: 'Matic',
      engineCc: 110,
      fuelType: 'Bensin',
      consumption: 50,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'ADV 160',
      type: 'Matic',
      engineCc: 157,
      fuelType: 'Bensin',
      consumption: 40,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'Supra X 125',
      type: 'Bebek',
      engineCc: 125,
      fuelType: 'Bensin',
      consumption: 55,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'CBR150R',
      type: 'Sport',
      engineCc: 149,
      fuelType: 'Bensin',
      consumption: 35,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'CBR250RR',
      type: 'Sport',
      engineCc: 249,
      fuelType: 'Bensin',
      consumption: 30,
    ),
    VehicleEntry(
      make: 'Honda',
      model: 'CRF150L',
      type: 'Trail',
      engineCc: 149,
      fuelType: 'Bensin',
      consumption: 35,
    ),

    // === MOTOR - YAMAHA ===
    VehicleEntry(
      make: 'Yamaha',
      model: 'NMAX 155',
      type: 'Matic',
      engineCc: 155,
      fuelType: 'Bensin',
      consumption: 42,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'Aerox 155',
      type: 'Matic',
      engineCc: 155,
      fuelType: 'Bensin',
      consumption: 40,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'Lexi 125',
      type: 'Matic',
      engineCc: 125,
      fuelType: 'Bensin',
      consumption: 45,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'Fazzio',
      type: 'Matic',
      engineCc: 125,
      fuelType: 'Bensin',
      consumption: 48,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'Mio M3',
      type: 'Matic',
      engineCc: 125,
      fuelType: 'Bensin',
      consumption: 50,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'R15',
      type: 'Sport',
      engineCc: 155,
      fuelType: 'Bensin',
      consumption: 35,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'R25',
      type: 'Sport',
      engineCc: 249,
      fuelType: 'Bensin',
      consumption: 28,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'MT-25',
      type: 'Sport',
      engineCc: 249,
      fuelType: 'Bensin',
      consumption: 28,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'XSR 155',
      type: 'Retro',
      engineCc: 155,
      fuelType: 'Bensin',
      consumption: 38,
    ),
    VehicleEntry(
      make: 'Yamaha',
      model: 'Jupiter Z1',
      type: 'Bebek',
      engineCc: 115,
      fuelType: 'Bensin',
      consumption: 55,
    ),

    // === MOTOR - KAWASAKI ===
    VehicleEntry(
      make: 'Kawasaki',
      model: 'Ninja 250',
      type: 'Sport',
      engineCc: 249,
      fuelType: 'Bensin',
      consumption: 28,
    ),
    VehicleEntry(
      make: 'Kawasaki',
      model: 'Ninja ZX-25R',
      type: 'Sport',
      engineCc: 249,
      fuelType: 'Bensin',
      consumption: 25,
    ),
    VehicleEntry(
      make: 'Kawasaki',
      model: 'KLX 150',
      type: 'Trail',
      engineCc: 144,
      fuelType: 'Bensin',
      consumption: 35,
    ),
    VehicleEntry(
      make: 'Kawasaki',
      model: 'W175',
      type: 'Retro',
      engineCc: 177,
      fuelType: 'Bensin',
      consumption: 40,
    ),

    // === MOTOR - SUZUKI ===
    VehicleEntry(
      make: 'Suzuki',
      model: 'GSX-R150',
      type: 'Sport',
      engineCc: 147,
      fuelType: 'Bensin',
      consumption: 35,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'Satria F150',
      type: 'Bebek',
      engineCc: 147,
      fuelType: 'Bensin',
      consumption: 38,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'Address',
      type: 'Matic',
      engineCc: 113,
      fuelType: 'Bensin',
      consumption: 45,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'Nex II',
      type: 'Matic',
      engineCc: 113,
      fuelType: 'Bensin',
      consumption: 48,
    ),
    VehicleEntry(
      make: 'Suzuki',
      model: 'V-Strom 250SX',
      type: 'Trail',
      engineCc: 249,
      fuelType: 'Bensin',
      consumption: 30,
    ),
  ];
}
