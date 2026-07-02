import 'package:field_track/core/error/result.dart';
import 'package:field_track/core/network/api_exception_handler.dart';
import 'package:field_track/features/locations/data/datasources/location_local_data_source.dart';
import 'package:field_track/features/locations/data/datasources/location_remote_data_source.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({
    required LocationRemoteDataSource remoteDataSource,
    required LocationLocalDataSource localDataSource,
    required ApiExceptionHandler exceptionHandler,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _handler = exceptionHandler;

  final LocationRemoteDataSource _remote;
  final LocationLocalDataSource _local;
  final ApiExceptionHandler _handler;

  @override
  Future<Result<List<LocationEntity>>> getLocations() async {
    return _handler.guard(() async {
      try {
        final locations = await _remote.getLocations();
        await _local.cacheLocations(locations);
        return locations.map((e) => e.toEntity()).toList();
      } catch (e) {
        final cached = _local.getCachedLocations();
        if (cached.isNotEmpty) return cached.map((e) => e.toEntity()).toList();
        rethrow;
      }
    });
  }

  @override
  Future<Result<LocationEntity>> createLocation({
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    bool isActive = true,
  }) async {
    return _handler.guard(() async {
      final model = await _remote.createLocation({
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'radius_m': radiusM.round(),
        'is_active': isActive,
      });
      await _local.upsert(model);
      return model.toEntity();
    });
  }

  @override
  Future<Result<LocationEntity>> updateLocation({
    required String id,
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    required bool isActive,
  }) async {
    return _handler.guard(() async {
      final model = await _remote.updateLocation(id, {
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'radius_m': radiusM.round(),
        'is_active': isActive,
      });
      await _local.upsert(model);
      return model.toEntity();
    });
  }

  @override
  Future<Result<void>> deleteLocation(String id) async {
    return _handler.guard(() async {
      await _remote.deleteLocation(id);
      await _local.remove(id);
    });
  }

  @override
  List<LocationEntity> getCachedLocations() =>
      _local.getCachedLocations().map((e) => e.toEntity()).toList();
}
