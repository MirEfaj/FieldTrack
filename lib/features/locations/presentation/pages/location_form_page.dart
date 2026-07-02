import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/core/theme/app_colors.dart';
import 'package:field_track/core/theme/app_spacing.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class LocationFormPage extends StatefulWidget {
  const LocationFormPage({super.key, this.locationId});

  final String? locationId;

  bool get isEditing => locationId != null;

  @override
  State<LocationFormPage> createState() => _LocationFormPageState();
}

class _LocationFormPageState extends State<LocationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  double _radius = 150;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final state = context.read<LocationBloc>().state;
      LocationEntity? location;
      for (final item in state.locations) {
        if (item.id == widget.locationId) location = item;
      }
      if (location != null) _populate(location);
    }
  }

  void _populate(LocationEntity location) {
    _nameController.text = location.locationName;
    _latController.text = location.latitude.toString();
    _lngController.text = location.longitude.toString();
    _radius = location.radiusM;
    _isActive = location.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latController.text = position.latitude.toStringAsFixed(4);
      _lngController.text = position.longitude.toStringAsFixed(4);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final lat = double.parse(_latController.text);
    final lng = double.parse(_lngController.text);

    if (widget.isEditing) {
      context.read<LocationBloc>().add(
            LocationUpdateRequested(
              id: widget.locationId!,
              locationName: _nameController.text.trim(),
              latitude: lat,
              longitude: lng,
              radiusM: _radius,
              isActive: _isActive,
            ),
          );
    } else {
      context.read<LocationBloc>().add(
            LocationCreateRequested(
              locationName: _nameController.text.trim(),
              latitude: lat,
              longitude: lng,
              radiusM: _radius,
              isActive: _isActive,
            ),
          );
    }
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete location',
      message: 'This location will be permanently removed.',
      confirmLabel: 'Delete location',
      isDestructive: true,
    );
    if (confirmed == true && widget.locationId != null && mounted) {
      context.read<LocationBloc>().add(
            LocationDeleteRequested(widget.locationId!),
          );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit location' : 'New location'),
      ),
      body: BlocListener<LocationBloc, LocationState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == LocationStatus.failure &&
              state.errorMessage != null) {
            AppSnackBar.show(context, state.errorMessage!, isError: true);
            _wasSaving = false;
          }
          if (_wasSaving && state.status == LocationStatus.success) {
            _wasSaving = false;
            context.pop();
          }
        },
        child: SafeArea(
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              final isSaving = state.status == LocationStatus.saving;
              return SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MapPreview(radius: _radius),
                      SizedBox(height: AppSpacing.lg),
                      AppOutlinedButton(
                        label: 'Use my current location',
                        icon: Icons.my_location,
                        onPressed: _useCurrentLocation,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'Location name',
                        controller: _nameController,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Latitude',
                              controller: _latController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (v) =>
                                  double.tryParse(v ?? '') == null ? 'Invalid' : null,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              label: 'Longitude',
                              controller: _lngController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (v) =>
                                  double.tryParse(v ?? '') == null ? 'Invalid' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppSlider(
                        label: 'Geofence radius',
                        value: _radius,
                        displayValue: '${_radius.round()} m',
                        onChanged: (v) => setState(() => _radius = v),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppSwitchTile(
                        title: 'Active',
                        subtitle: 'Workers can check in here',
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                      SizedBox(height: AppSpacing.xxl),
                      AppButton(
                        label: widget.isEditing ? 'Update location' : 'Save location',
                        isLoading: isSaving,
                        onPressed: () {
                          _wasSaving = true;
                          _submit();
                        },
                      ),
                      if (widget.isEditing) ...[
                        SizedBox(height: AppSpacing.md),
                        AppOutlinedButton(
                          label: 'Delete location',
                          icon: Icons.delete_outline,
                          foregroundColor: AppColors.error,
                          borderColor: AppColors.error,
                          onPressed: _delete,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _wasSaving = false;
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius.clamp(50, 500) / 500 * 80 + 40;
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            context.appTheme.cardBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appTheme.borderColor),
      ),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.location_on, color: AppColors.primary, size: 28),
        ),
      ),
    );
  }
}
