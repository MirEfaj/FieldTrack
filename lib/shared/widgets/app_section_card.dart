import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';

/// Shared rounded card shell used across profile, sync, and other screens.
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: context.appTheme.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: context.appTheme.borderColor.withValues(alpha: 0.55),
        ),
      ),
      child: child,
    );
  }
}
