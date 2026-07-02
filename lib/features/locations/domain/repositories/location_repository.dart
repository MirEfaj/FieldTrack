import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';

abstract class LocationRepository {
  Future<Result<List<LocationEntity>>> getLocations();

  Future<Result<LocationEntity>> createLocation({
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    bool isActive = true,
  });

  Future<Result<LocationEntity>> updateLocation({
    required String id,
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    required bool isActive,
  });

  Future<Result<void>> deleteLocation(String id);

  List<LocationEntity> getCachedLocations();
}
