import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppTypography {
  static TextStyle displayLarge(Color color) => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle headlineMedium(Color color) => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle titleLarge(Color color) => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle titleMedium(Color color) => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyLarge(Color color) => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium(Color color) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall(Color color) => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle labelLarge(Color color) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle labelSmall(Color color) => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.5,
        height: 1.4,
      );
}
