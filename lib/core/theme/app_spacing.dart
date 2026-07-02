import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppSpacing {
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;

  static EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);

  static EdgeInsets get cardPadding =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h);
}
