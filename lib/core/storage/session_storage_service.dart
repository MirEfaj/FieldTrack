import 'package:field_track/core/storage/hive_service.dart';

/// Clears persisted user-scoped data on logout.
class SessionStorageService {
  const SessionStorageService(this._hiveService);

  final HiveService _hiveService;

  Future<void> clearUserSessionData() => _hiveService.clearAll();
}
