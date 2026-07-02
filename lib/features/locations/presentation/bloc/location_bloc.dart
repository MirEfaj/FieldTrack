import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/locations/domain/entities/location_entity.dart';
import 'package:field_track/features/locations/domain/usecases/location_usecases.dart';

enum LocationStatus { initial, loading, success, failure, saving }

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.locations = const [],
    this.filteredLocations = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.selectedLocation,
  });

  final LocationStatus status;
  final List<LocationEntity> locations;
  final List<LocationEntity> filteredLocations;
  final String searchQuery;
  final String? errorMessage;
  final LocationEntity? selectedLocation;

  LocationState copyWith({
    LocationStatus? status,
    List<LocationEntity>? locations,
    List<LocationEntity>? filteredLocations,
    String? searchQuery,
    String? errorMessage,
    LocationEntity? selectedLocation,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      filteredLocations: filteredLocations ?? this.filteredLocations,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedLocation:
          clearSelected ? null : selectedLocation ?? this.selectedLocation,
    );
  }

  @override
  List<Object?> get props =>
      [status, locations, filteredLocations, searchQuery, errorMessage, selectedLocation];
}

sealed class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

final class LocationsLoadRequested extends LocationEvent {
  const LocationsLoadRequested();
}

final class LocationsSearchChanged extends LocationEvent {
  const LocationsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class LocationCreateRequested extends LocationEvent {
  const LocationCreateRequested({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    this.isActive = true,
  });

  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  @override
  List<Object?> get props =>
      [locationName, latitude, longitude, radiusM, isActive];
}

final class LocationUpdateRequested extends LocationEvent {
  const LocationUpdateRequested({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    required this.isActive,
  });

  final String id;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  @override
  List<Object?> get props =>
      [id, locationName, latitude, longitude, radiusM, isActive];
}

final class LocationDeleteRequested extends LocationEvent {
  const LocationDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

final class LocationSelectRequested extends LocationEvent {
  const LocationSelectRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({
    required this._getLocationsUseCase,
    required this._createLocationUseCase,
    required this._updateLocationUseCase,
    required this._deleteLocationUseCase,
  }) : super(const LocationState()) {
    on<LocationsLoadRequested>(_onLoad);
    on<LocationsSearchChanged>(_onSearch);
    on<LocationCreateRequested>(_onCreate);
    on<LocationUpdateRequested>(_onUpdate);
    on<LocationDeleteRequested>(_onDelete);
    on<LocationSelectRequested>(_onSelect);
  }

  final GetLocationsUseCase _getLocationsUseCase;
  final CreateLocationUseCase _createLocationUseCase;
  final UpdateLocationUseCase _updateLocationUseCase;
  final DeleteLocationUseCase _deleteLocationUseCase;

  Future<void> _onLoad(
    LocationsLoadRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.loading, clearError: true));
    final result = await _getLocationsUseCase();
    switch (result) {
      case Success(:final data):
        emit(_applyFilter(data, state.searchQuery).copyWith(
          status: LocationStatus.success,
          locations: data,
        ));
      case Error(:final failure):
        emit(state.copyWith(
          status: LocationStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  void _onSearch(LocationsSearchChanged event, Emitter<LocationState> emit) {
    emit(_applyFilter(state.locations, event.query).copyWith(
      searchQuery: event.query,
    ));
  }

  Future<void> _onCreate(
    LocationCreateRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.saving, clearError: true));
    final result = await _createLocationUseCase(
      locationName: event.locationName,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusM: event.radiusM,
      isActive: event.isActive,
    );
    switch (result) {
      case Success():
        add(const LocationsLoadRequested());
      case Error(:final failure):
        emit(state.copyWith(
          status: LocationStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onUpdate(
    LocationUpdateRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.saving, clearError: true));
    final result = await _updateLocationUseCase(
      id: event.id,
      locationName: event.locationName,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusM: event.radiusM,
      isActive: event.isActive,
    );
    switch (result) {
      case Success():
        add(const LocationsLoadRequested());
      case Error(:final failure):
        emit(state.copyWith(
          status: LocationStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onDelete(
    LocationDeleteRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.saving, clearError: true));
    final result = await _deleteLocationUseCase(event.id);
    switch (result) {
      case Success():
        add(const LocationsLoadRequested());
      case Error(:final failure):
        emit(state.copyWith(
          status: LocationStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  void _onSelect(LocationSelectRequested event, Emitter<LocationState> emit) {
    final location = state.locations.cast<LocationEntity?>().firstWhere(
          (l) => l?.id == event.id,
          orElse: () => null,
        );
    emit(state.copyWith(selectedLocation: location));
  }

  LocationState _applyFilter(List<LocationEntity> locations, String query) {
    if (query.isEmpty) {
      return state.copyWith(locations: locations, filteredLocations: locations);
    }
    final lower = query.toLowerCase();
    final filtered = locations
        .where((l) => l.locationName.toLowerCase().contains(lower))
        .toList();
    return state.copyWith(locations: locations, filteredLocations: filtered);
  }
}
