import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class ThemeCubitState extends Equatable {
  const ThemeCubitState({required this.mode});

  final AppThemeMode mode;

  ThemeMode get materialThemeMode => switch (mode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };

  ThemeCubitState copyWith({AppThemeMode? mode}) =>
      ThemeCubitState(mode: mode ?? this.mode);

  @override
  List<Object?> get props => [mode];
}
