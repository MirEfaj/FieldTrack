import 'package:json_annotation/json_annotation.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  const LocationModel({
    required this.id,
    @JsonKey(name: 'location_name') required this.locationName,
    required this.latitude,
    required this.longitude,
    @JsonKey(name: 'radius_m') required this.radiusM,
    @JsonKey(name: 'is_active') this.isActive = true,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  final String id;
  @JsonKey(name: 'location_name')
  final String locationName;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'radius_m')
  final double radiusM;
  @JsonKey(name: 'is_active')
  final bool isActive;

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);

  LocationEntity toEntity() => LocationEntity(
        id: id,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        radiusM: radiusM,
        isActive: isActive,
      );
}
