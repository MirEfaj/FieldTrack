import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_track/core/theme/app_colors.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';
import 'package:field_track/shared/widgets/app_section_card.dart';

abstract final class SyncSpacing {
  static EdgeInsets get screen =>
      EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h);

  static double get titleBottom => 12.h;
  static double get section => 12.h;
  static double get listTop => 10.h;
}

class SyncOfflineBanner extends StatelessWidget {
  const SyncOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.offlineBannerBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.offlineBannerText.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: theme.offlineBannerText.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 18.sp,
              color: theme.offlineBannerText,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're offline",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.offlineBannerText,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Changes are saved on this device',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.offlineBannerText.withValues(alpha: 0.9),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SyncSummaryCard extends StatelessWidget {
  const SyncSummaryCard({
    super.key,
    required this.pendingCount,
    required this.lastSyncedLabel,
  });

  final int pendingCount;
  final String lastSyncedLabel;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = context.appTheme.textSecondary;

    return AppSectionCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.sync, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount changes pending',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  lastSyncedLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: secondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SyncPendingTile extends StatelessWidget {
  const SyncPendingTile({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.icon,
  });

  final String title;
  final String actionLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = context.appTheme.textSecondary;
    final theme = context.appTheme;

    return AppSectionCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: context.appTheme.borderColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: secondary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
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
                  actionLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: secondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: theme.badgePendingBg,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Pending',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: theme.badgePendingText,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SyncEmptyState extends StatelessWidget {
  const SyncEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final secondary = context.appTheme.textSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 56.sp,
            color: secondary.withValues(alpha: 0.85),
          ),
          SizedBox(height: 12.h),
          Text(
            'No pending changes',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: secondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class SyncActionButton extends StatelessWidget {
  const SyncActionButton({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sync, size: 18.sp, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text(
                    'Sync now',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

IconData syncIconForTitle(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('inventory') || lower.contains('stock')) {
    return Icons.inventory_2_outlined;
  }
  if (lower.contains('visit') || lower.contains('manager')) {
    return Icons.description_outlined;
  }
  if (lower.contains('display') || lower.contains('location')) {
    return Icons.location_on_outlined;
  }
  return Icons.task_alt_outlined;
}
