import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  const LocationEntity({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    this.isActive = true,
  });

  final String id;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  String get coordinates =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  @override
  List<Object?> get props =>
      [id, locationName, latitude, longitude, radiusM, isActive];
}
