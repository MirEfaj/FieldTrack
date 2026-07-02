import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {},
    );
    _initialized = true;
  }

  Future<void> showGeofenceEntry(String locationName) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Alerts',
      channelDescription: 'Notifications when entering a saved location',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      locationName.hashCode,
      'Location entered',
      'You entered $locationName',
      details,
    );
  }
}
