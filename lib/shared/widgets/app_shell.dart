import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/config/routes/route_names.dart';
import 'package:field_track/core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.locations)) return 1;
    if (location.startsWith(RouteNames.sync)) return 2;
    if (location.startsWith(RouteNames.profile)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.tasks);
      case 1:
        context.go(RouteNames.locations);
      case 2:
        context.go(RouteNames.sync);
      case 3:
        context.go(RouteNames.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 64.h,
          backgroundColor: isDark
              ? AppColors.darkSurface
              : Theme.of(context).colorScheme.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.14),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              height: 1.1,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 22.sp,
              color: selected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => _onTap(context, i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist, color: AppColors.primary),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on, color: AppColors.primary),
              label: 'Locations',
            ),
            NavigationDestination(
              icon: Icon(Icons.sync_outlined),
              selectedIcon: Icon(Icons.sync, color: AppColors.primary),
              label: 'Sync',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
