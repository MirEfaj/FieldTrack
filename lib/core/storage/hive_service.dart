import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String todosBox = 'todos';
  static const String locationsBox = 'locations';
  static const String syncQueueBox = 'sync_queue';
  static const String geofenceStateBox = 'geofence_state';
  static const String userBox = 'user_cache';

  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(todosBox),
      Hive.openBox<Map>(locationsBox),
      Hive.openBox<Map>(syncQueueBox),
      Hive.openBox<Map>(geofenceStateBox),
      Hive.openBox<Map>(userBox),
    ]);
  }

  Box<Map> get todos => Hive.box<Map>(todosBox);
  Box<Map> get locations => Hive.box<Map>(locationsBox);
  Box<Map> get syncQueue => Hive.box<Map>(syncQueueBox);
  Box<Map> get geofenceState => Hive.box<Map>(geofenceStateBox);
  Box<Map> get userCache => Hive.box<Map>(userBox);

  Future<void> clearAll() async {
    await Future.wait([
      todos.clear(),
      locations.clear(),
      syncQueue.clear(),
      geofenceState.clear(),
      userCache.clear(),
    ]);
  }
}
