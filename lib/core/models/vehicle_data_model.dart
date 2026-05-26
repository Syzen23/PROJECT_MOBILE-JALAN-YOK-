class VehicleData {
  final String description;
  final String registrationYear;
  final String carMake;
  final String carModel;
  final String? vehicleType;
  final String? colour;
  final String? fuelType;
  final String? engineSize;
  final String? stnkExpiry;
  final String? taxExpiry;
  final double? totalDue;
  final String? location;
  final String? imageUrl;
  // Fields from API-Ninjas
  final int? cylinders;
  final String? driveType;
  final String? transmission;
  final int? cityMpg;
  final int? highwayMpg;
  final int? combinationMpg;
  final String? vehicleClass;

  VehicleData({
    required this.description,
    required this.registrationYear,
    required this.carMake,
    required this.carModel,
    this.vehicleType,
    this.colour,
    this.fuelType,
    this.engineSize,
    this.stnkExpiry,
    this.taxExpiry,
    this.totalDue,
    this.location,
    this.imageUrl,
    this.cylinders,
    this.driveType,
    this.transmission,
    this.cityMpg,
    this.highwayMpg,
    this.combinationMpg,
    this.vehicleClass,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      description: json['Description'] ?? '',
      registrationYear: json['RegistrationYear'] ?? '',
      carMake: json['CarMake'] ?? json['MakeDescription'] ?? '',
      carModel: json['CarModel'] ?? json['ModelDescription'] ?? '',
      vehicleType: json['VehicleType'],
      colour: json['Colour'],
      fuelType: json['FuelType'],
      engineSize: json['EngineSize']?.toString(),
      stnkExpiry: json['StnkExpiry'],
      taxExpiry: json['TaxExpiry'],
      totalDue: json['TotalDue'] is num ? (json['TotalDue'] as num).toDouble() : null,
      location: json['Location'],
      imageUrl: json['ImageUrl'],
    );
  }

  /// Factory constructor for API-Ninjas Cars API response
  factory VehicleData.fromApiNinjas(Map<String, dynamic> json) {
    final make = _capitalize(json['make']?.toString() ?? '');
    final model = _capitalize(json['model']?.toString() ?? '');
    final year = json['year']?.toString() ?? '';
    final fuelType = _mapFuelType(json['fuel_type']?.toString() ?? '');
    final displacement = json['displacement']?.toString();
    final cylinders = json['cylinders'] is num ? (json['cylinders'] as num).toInt() : null;
    final drive = json['drive']?.toString();
    final transmission = json['transmission']?.toString();
    final vehicleClass = json['class']?.toString();
    final cityMpg = json['city_mpg'] is num ? (json['city_mpg'] as num).toInt() : null;
    final highwayMpg = json['highway_mpg'] is num ? (json['highway_mpg'] as num).toInt() : null;
    final combinationMpg = json['combination_mpg'] is num ? (json['combination_mpg'] as num).toInt() : null;

    return VehicleData(
      description: '$make $model ($year)',
      registrationYear: year,
      carMake: make,
      carModel: model,
      vehicleType: _mapVehicleClass(vehicleClass),
      fuelType: fuelType,
      engineSize: displacement,
      cylinders: cylinders,
      driveType: drive,
      transmission: _mapTransmission(transmission),
      vehicleClass: vehicleClass,
      cityMpg: cityMpg,
      highwayMpg: highwayMpg,
      combinationMpg: combinationMpg,
    );
  }

  /// Map API fuel_type to Indonesian fuel type
  static String _mapFuelType(String apiType) {
    final lower = apiType.toLowerCase();
    if (lower.contains('diesel')) return 'Solar';
    if (lower.contains('electricity') || lower.contains('electric')) return 'Listrik';
    return 'Bensin'; // gas, gasoline
  }

  /// Map vehicle class to Indonesian type
  static String? _mapVehicleClass(String? cls) {
    if (cls == null || cls.isEmpty) return null;
    final lower = cls.toLowerCase();
    if (lower.contains('suv') || lower.contains('sport utility')) return 'SUV';
    if (lower.contains('sedan') || lower.contains('compact') || lower.contains('midsize') || lower.contains('subcompact')) return 'Sedan';
    if (lower.contains('minivan') || lower.contains('van')) return 'MPV';
    if (lower.contains('pickup') || lower.contains('truck')) return 'Pickup/Truck';
    if (lower.contains('wagon') || lower.contains('station')) return 'Station Wagon';
    if (lower.contains('two seater') || lower.contains('coupe')) return 'Coupe/Sport';
    if (lower.contains('hatchback')) return 'Hatchback';
    return cls;
  }

  /// Map transmission abbreviation
  static String? _mapTransmission(String? t) {
    if (t == null) return null;
    final lower = t.toLowerCase();
    if (lower == 'a') return 'Otomatis';
    if (lower == 'm') return 'Manual';
    return t;
  }

  /// Capitalize first letter of each word
  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Determine transport type from VehicleType field
  String get transportType {
    final type = (vehicleType ?? '').toUpperCase();
    if (type.contains('SEPEDA MOTOR') || type.contains('MOTOR')) {
      return 'Motor';
    }
    return 'Mobil';
  }

  /// Engine size in liters for display
  String get engineSizeDisplay {
    if (engineSize == null || engineSize!.isEmpty) return '-';
    final cc = double.tryParse(engineSize!);
    if (cc == null) return engineSize!;
    // API-Ninjas returns displacement in liters (e.g., 1.5, 2.0)
    if (cc < 20) {
      // Already in liters
      return '${cc.toStringAsFixed(1)}L (${(cc * 1000).toStringAsFixed(0)} cc)';
    }
    // In cc
    return '${(cc / 1000).toStringAsFixed(1)}L ($cc cc)';
  }

  /// Estimate fuel consumption (km/l) based on model name and engine size
  double get estimatedConsumption {
    // If we have MPG data from API, convert to km/l
    if (combinationMpg != null && combinationMpg! > 0) {
      // 1 MPG = 0.425144 km/l
      return (combinationMpg! * 0.425144);
    }

    final model = carModel.toUpperCase();

    // Try to extract engine size from model name (e.g., "1.2", "1.5", "2.0")
    final engineRegex = RegExp(r'(\d+\.\d+)');
    final match = engineRegex.firstMatch(model);
    double? engineLiter;
    if (match != null) {
      engineLiter = double.tryParse(match.group(1)!);
    }

    // Parse engineSize field if available
    if (engineSize != null && engineSize!.isNotEmpty) {
      final cc = double.tryParse(engineSize!);
      if (cc != null && cc > 0) {
        if (cc < 20) {
          // Already in liters
          engineLiter = cc;
        } else {
          engineLiter = cc / 1000.0;
        }
      }
    }

    // Motor
    if (transportType == 'Motor') {
      if (engineLiter != null) {
        if (engineLiter < 0.2) return 45; // matic/bebek
        if (engineLiter < 0.4) return 35; // sport kecil
        return 30; // sport besar
      }
      return 45; // default motor
    }

    // Mobil - estimate from engine size
    if (engineLiter != null) {
      if (engineLiter <= 1.2) return 15; // city car
      if (engineLiter <= 1.5) return 13; // MPV kecil
      if (engineLiter <= 2.0) return 12; // MPV/sedan
      if (engineLiter <= 2.5) return 10; // SUV
      return 9; // SUV besar
    }

    // Fallback: guess from vehicle type
    final vType = (vehicleType ?? '').toUpperCase();
    if (vType.contains('SEDAN')) return 13;
    if (vType.contains('JEEP') || vType.contains('SUV')) return 9;
    if (vType.contains('PICK UP')) return 11;
    return 12; // default mobil
  }

  /// Get a short display name
  String get displayName {
    // Clean up model name - remove codes in parentheses
    String cleanModel = carModel.replaceAll(RegExp(r'\s*\([^)]*\)\s*'), '').trim();
    return '$carMake $cleanModel';
  }

  /// Detailed info string for display in card
  String get detailInfo {
    final parts = <String>[];
    if (registrationYear.isNotEmpty) parts.add('Tahun: $registrationYear');
    if (vehicleType != null) parts.add('Tipe: $vehicleType');
    if (fuelType != null) parts.add('BBM: $fuelType');
    if (engineSize != null) parts.add('Mesin: $engineSizeDisplay');
    if (cylinders != null) parts.add('Silinder: $cylinders');
    if (transmission != null) parts.add('Transmisi: $transmission');
    return parts.join(' | ');
  }
}
