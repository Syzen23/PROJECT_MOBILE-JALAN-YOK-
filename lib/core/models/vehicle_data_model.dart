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

  /// Determine transport type from VehicleType field
  String get transportType {
    final type = (vehicleType ?? '').toUpperCase();
    if (type.contains('SEPEDA MOTOR') || type.contains('MOTOR')) {
      return 'Motor';
    }
    return 'Mobil';
  }

  /// Estimate fuel consumption (km/l) based on model name and engine size
  double get estimatedConsumption {
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
        engineLiter = cc / 1000.0;
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
}
