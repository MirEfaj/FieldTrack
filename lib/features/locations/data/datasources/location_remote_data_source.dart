import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/features/locations/data/models/location_model.dart';

class LocationRemoteDataSource {
  const LocationRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<LocationModel>> getLocations() async {
    final response = await _apiClient.get<dynamic>('/api/v1/locations');
    final data = response.data;
    final list = data is List ? data : (data as Map)['data'] as List? ?? [];
    return list
        .map((e) => LocationModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<LocationModel> createLocation(Map<String, dynamic> body) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/v1/locations',
      data: body,
    );
    final data = response.data!;
    if (data.containsKey('id')) {
      return LocationModel.fromJson(data);
    }
    return LocationModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<LocationModel> updateLocation(String id, Map<String, dynamic> body) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/v1/locations/$id',
      data: body,
    );
    final data = response.data!;
    if (data.containsKey('id')) {
      return LocationModel.fromJson(data);
    }
    return LocationModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteLocation(String id) async {
    await _apiClient.delete('/api/v1/locations/$id');
  }
}
