import '../data/vehicle_database.dart';
import '../services/vehicle_api_service.dart';

class VehicleRepository {
  VehicleRepository._();

  static final VehicleRepository instance = VehicleRepository._();

  Future<List<VehicleEntry>> getAllVehicles({bool forceRefresh = false}) {
    return VehicleApiService.getAllVehicles(forceRefresh: forceRefresh);
  }

  Future<List<String>> getMakes({required bool isMotorcycle}) {
    return VehicleApiService.getMakes(isMotorcycle: isMotorcycle);
  }

  Future<List<VehicleEntry>> searchVehicle({
    required String make,
    String? model,
    bool? isMotorcycle,
  }) {
    return VehicleApiService.searchVehicle(
      make: make,
      model: model,
      isMotorcycle: isMotorcycle,
    );
  }
}
