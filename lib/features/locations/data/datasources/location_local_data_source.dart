import 'package:field_track/core/storage/hive_service.dart';
import 'package:field_track/features/locations/data/models/location_model.dart';

class LocationLocalDataSource {
  const LocationLocalDataSource(this._hiveService);
  final HiveService _hiveService;

  Future<void> cacheLocations(List<LocationModel> locations) async {
    final box = _hiveService.locations;
    await box.clear();
    for (final location in locations) {
      await box.put(location.id, location.toJson());
    }
  }

  List<LocationModel> getCachedLocations() {
    return _hiveService.locations.values
        .map((e) => LocationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> upsert(LocationModel location) async {
    await _hiveService.locations.put(location.id, location.toJson());
  }

  Future<void> remove(String id) async {
    await _hiveService.locations.delete(id);
  }
}
