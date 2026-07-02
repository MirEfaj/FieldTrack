import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_track/core/theme/app_colors.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';
import 'package:field_track/core/theme/app_typography.dart';

import 'package:field_track/shared/widgets/app_section_card.dart';

/// Profile-screen spacing tuned to match Figma.
abstract final class ProfileSpacing {
  static EdgeInsets get screen =>
      EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h);

  static double get titleBottom => 12.h;
  static double get section => 12.h;
  static double get signOutTop => 16.h;
}


class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.initials,
    required this.name,
    required this.email,
    required this.roleLabel,
  });

  final String initials;
  final String name;
  final String email;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = context.appTheme.textSecondary;

    return AppSectionCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: onSurface,
              height: 1.25,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: secondary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 10.h),
          ProfileRoleBadge(label: roleLabel),
        ],
      ),
    );
  }
}

class ProfileRoleBadge extends StatelessWidget {
  const ProfileRoleBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 12.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final secondary = context.appTheme.textSecondary;

    return Expanded(
      child: AppSectionCard(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.15,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: secondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.showChevron = true,
    this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = context.appTheme.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: context.appTheme.borderColor.withValues(alpha: 0.45),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: context.appTheme.borderColor
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, size: 18.sp, color: secondary),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: subtitle != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: secondary,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: onSurface,
                              height: 1.25,
                            ),
                          ),
                  ),
                  if (showChevron)
                    Icon(
                      Icons.chevron_right,
                      size: 20.sp,
                      color: secondary.withValues(alpha: 0.7),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(child: Column(children: children));
  }
}

class ProfileSignOutButton extends StatelessWidget {
  const ProfileSignOutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(
            color: AppColors.error.withValues(alpha: 0.85),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18.sp, color: AppColors.error),
            SizedBox(width: 8.w),
            Text(
              'Sign out',
              style: AppTypography.labelLarge(AppColors.error).copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatProfileRole(String? role) {
  if (role == null || role.isEmpty) return 'Field User';
  return role
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
