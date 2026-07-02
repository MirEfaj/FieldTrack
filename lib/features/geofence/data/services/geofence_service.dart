import 'dart:async';
import 'dart:math';

import 'package:field_track/config/env/app_config.dart';
import 'package:field_track/core/storage/hive_service.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';
import 'package:geolocator/geolocator.dart';

typedef GeofenceEntryCallback = void Function(LocationEntity location);

class GeofenceService {
  GeofenceService(this._hiveService);

  final HiveService _hiveService;
  StreamSubscription<Position>? _positionSubscription;
  final Map<String, bool> _insideState = {};
  GeofenceEntryCallback? onEntry;

  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> startMonitoring(List<LocationEntity> locations) async {
    await stopMonitoring();

    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) => _evaluate(position, locations));
  }

  Future<void> stopMonitoring() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _evaluate(Position position, List<LocationEntity> locations) {
    for (final location in locations.where((l) => l.isActive)) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        location.latitude,
        location.longitude,
      );

      final isInside = distance <= location.radiusM;
      final wasInside = _insideState[location.id] ?? false;
      _insideState[location.id] = isInside;

      if (isInside && !wasInside && !_isInCooldown(location.id)) {
        _recordNotification(location.id);
        onEntry?.call(location);
      }

      if (!isInside && wasInside) {
        _insideState[location.id] = false;
      }
    }
  }

  bool _isInCooldown(String locationId) {
    final raw = _hiveService.geofenceState.get(locationId);
    if (raw == null) return false;
    final lastNotified = DateTime.tryParse(raw['last_notified'] as String? ?? '');
    if (lastNotified == null) return false;
    return DateTime.now().difference(lastNotified) <
        Duration(minutes: AppConfig.geofenceCooldownMinutes);
  }

  Future<void> _recordNotification(String locationId) async {
    await _hiveService.geofenceState.put(locationId, {
      'last_notified': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static double haversineDistanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;
}
