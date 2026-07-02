import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_track/core/theme/theme_cubit.dart';
import 'package:field_track/core/theme/theme_cubit_state.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';
import 'package:field_track/features/authentication/presentation/widgets/profile_widgets.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_list_bloc.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final todoState = context.watch<TodoListBloc>().state;
    final locationState = context.watch<LocationBloc>().state;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: ProfileSpacing.screen,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: onSurface,
                height: 1.2,
              ),
            ),
            SizedBox(height: ProfileSpacing.titleBottom),
            ProfileHeaderCard(
              initials: user?.initials ?? '?',
              name: user?.fullName ?? 'User',
              email: user?.email ?? '',
              roleLabel: formatProfileRole(user?.role),
            ),
            SizedBox(height: ProfileSpacing.section),
            Row(
              children: [
                ProfileStatCard(
                  value: '${todoState.completedCount}/${todoState.totalCount}',
                  label: 'Tasks done today',
                ),
                SizedBox(width: 10.w),
                ProfileStatCard(
                  value:
                      '${locationState.locations.where((l) => l.isActive).length}',
                  label: 'Active locations',
                ),
              ],
            ),
            SizedBox(height: ProfileSpacing.section),
            ProfileMenuGroup(
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline,
                  title: 'Edit profile',
                  onTap: () {},
                ),
                ProfileMenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  showDivider: true,
                  onTap: () {},
                ),
                ProfileMenuTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: 'Light, dark, or system',
                  showDivider: true,
                  showChevron: false,
                  onTap: () => _showThemePicker(context),
                ),
                ProfileMenuTile(
                  icon: Icons.help_outline,
                  title: 'Help & support',
                  showDivider: true,
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: ProfileSpacing.signOutTop),
            ProfileSignOutButton(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context,
                  title: 'Sign out',
                  message: 'Are you sure you want to sign out?',
                  confirmLabel: 'Sign out',
                  isDestructive: true,
                );
                if (confirmed == true && context.mounted) {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                }
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return BlocBuilder<ThemeCubit, ThemeCubitState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('System'),
                    trailing: state.mode == AppThemeMode.system
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      context.read<ThemeCubit>().setMode(AppThemeMode.system);
                      Navigator.pop(ctx);
                    },
                  ),
                  ListTile(
                    title: const Text('Light'),
                    trailing: state.mode == AppThemeMode.light
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      context.read<ThemeCubit>().setMode(AppThemeMode.light);
                      Navigator.pop(ctx);
                    },
                  ),
                  ListTile(
                    title: const Text('Dark'),
                    trailing: state.mode == AppThemeMode.dark
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      context.read<ThemeCubit>().setMode(AppThemeMode.dark);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
