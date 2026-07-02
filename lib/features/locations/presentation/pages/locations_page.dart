import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/config/routes/route_names.dart';
import 'package:field_track/core/theme/app_colors.dart';
import 'package:field_track/core/theme/app_spacing.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';
import 'package:field_track/core/theme/app_typography.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(const LocationsLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.locationNew),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocConsumer<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state.status == LocationStatus.failure &&
                state.errorMessage != null) {
              AppSnackBar.show(context, state.errorMessage!, isError: true);
            }
          },
          builder: (context, state) {
            if (state.status == LocationStatus.loading &&
                state.locations.isEmpty) {
              return const AppLoading();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Locations',
                        style: AppTypography.displayLarge(
                          Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppSearchField(
                        hint: 'Search locations',
                        controller: _searchController,
                        onChanged: (q) => context
                            .read<LocationBloc>()
                            .add(LocationsSearchChanged(q)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.filteredLocations.isEmpty
                      ? const AppEmptyView(
                          message: 'No locations yet',
                          icon: Icons.location_off_outlined,
                        )
                      : ListView.separated(
                          padding: AppSpacing.screenPadding,
                          itemCount: state.filteredLocations.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final location = state.filteredLocations[index];
                            return _LocationCard(
                              location: location,
                              onTap: () => context.push(
                                '/locations/${location.id}/edit',
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.onTap});

  final LocationEntity location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.locationName,
                  style: AppTypography.titleMedium(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  location.coordinates,
                  style: AppTypography.bodySmall(theme.textSecondary),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${location.radiusM.round()} m radius',
                      style: AppTypography.bodySmall(theme.textSecondary),
                    ),
                    SizedBox(width: AppSpacing.md),
                    AppBadge(
                      label: location.isActive ? 'Active' : 'Inactive',
                      backgroundColor: location.isActive
                          ? theme.badgeCompletedBg
                          : AppColors.badgeInactiveBg,
                      textColor: location.isActive
                          ? theme.badgeCompletedText
                          : AppColors.badgeInactiveText,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.textSecondary),
        ],
      ),
    );
  }
}
