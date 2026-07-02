class AppConfig {
  const AppConfig._();

  static const String appName = 'FieldTrack';
  static const String baseUrl = 'https://todo.progressivebyte.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String themeModeKey = 'theme_mode';
  static const int geofenceCooldownMinutes = 5;
  static const int locationUpdateIntervalSeconds = 30;
}
