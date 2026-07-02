import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';

class GetLocationsUseCase {
  const GetLocationsUseCase(this._repository);
  final LocationRepository _repository;
  Future<Result<List<LocationEntity>>> call() => _repository.getLocations();
}

class CreateLocationUseCase {
  const CreateLocationUseCase(this._repository);
  final LocationRepository _repository;

  Future<Result<LocationEntity>> call({
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    bool isActive = true,
  }) =>
      _repository.createLocation(
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        radiusM: radiusM,
        isActive: isActive,
      );
}

class UpdateLocationUseCase {
  const UpdateLocationUseCase(this._repository);
  final LocationRepository _repository;

  Future<Result<LocationEntity>> call({
    required String id,
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    required bool isActive,
  }) =>
      _repository.updateLocation(
        id: id,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        radiusM: radiusM,
        isActive: isActive,
      );
}

class DeleteLocationUseCase {
  const DeleteLocationUseCase(this._repository);
  final LocationRepository _repository;
  Future<Result<void>> call(String id) => _repository.deleteLocation(id);
}

class GetCachedLocationsUseCase {
  const GetCachedLocationsUseCase(this._repository);
  final LocationRepository _repository;
  List<LocationEntity> call() => _repository.getCachedLocations();
}
