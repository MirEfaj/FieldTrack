import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/config/env/app_config.dart';
import 'package:field_track/core/storage/secure_storage_service.dart';
import 'package:field_track/core/theme/theme_cubit_state.dart';

class ThemeCubit extends Cubit<ThemeCubitState> {
  ThemeCubit(this._secureStorage)
      : super(const ThemeCubitState(mode: AppThemeMode.system));

  final SecureStorageService _secureStorage;

  Future<void> load() async {
    final saved = await _secureStorage.read(AppConfig.themeModeKey);
    final mode = switch (saved) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
    emit(state.copyWith(mode: mode));
  }

  Future<void> setMode(AppThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _secureStorage.write(
      AppConfig.themeModeKey,
      switch (mode) {
        AppThemeMode.light => 'light',
        AppThemeMode.dark => 'dark',
        AppThemeMode.system => 'system',
      },
    );
  }
}
