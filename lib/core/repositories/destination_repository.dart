import '../models/api_destination_model.dart';
import '../services/destination_api_service.dart';

class DestinationRepository {
  DestinationRepository._();

  static final DestinationRepository instance = DestinationRepository._();

  Future<List<ApiDestination>> getAllDestinations({bool forceRefresh = false}) {
    return DestinationApiService.instance.getAllDestinations(
      forceRefresh: forceRefresh,
    );
  }

  Future<ApiDestination?> getDestinationById(int id) {
    return DestinationApiService.instance.getDestinationById(id);
  }

  Future<List<ApiDestination>> searchDestinations(String query) {
    return DestinationApiService.instance.searchDestinations(query);
  }
}
