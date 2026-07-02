import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:field_track/core/connectivity/connectivity_service.dart';
import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/core/network/api_exception_handler.dart';
import 'package:field_track/core/storage/hive_service.dart';
import 'package:field_track/core/storage/secure_storage_service.dart';
import 'package:field_track/core/storage/session_storage_service.dart';
import 'package:field_track/core/theme/theme_cubit.dart';
import 'package:field_track/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:field_track/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:field_track/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:field_track/features/authentication/domain/repositories/auth_repository.dart';
import 'package:field_track/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';
import 'package:field_track/features/geofence/data/services/geofence_service.dart';
import 'package:field_track/features/locations/data/datasources/location_local_data_source.dart';
import 'package:field_track/features/locations/data/datasources/location_remote_data_source.dart';
import 'package:field_track/features/locations/data/repositories/location_repository_impl.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';
import 'package:field_track/features/locations/domain/usecases/location_usecases.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/notifications/data/services/notification_service.dart';
import 'package:field_track/features/todos/data/datasources/todo_local_data_source.dart';
import 'package:field_track/features/todos/data/datasources/todo_remote_data_source.dart';
import 'package:field_track/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';
import 'package:field_track/features/todos/domain/usecases/todo_usecases.dart';
import 'package:field_track/features/todos/presentation/bloc/sync_bloc.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_list_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton(SecureStorageService.new);
  getIt.registerLazySingleton(HiveService.new);
  getIt.registerLazySingleton(() => SessionStorageService(getIt<HiveService>()));
  getIt.registerLazySingleton(ApiExceptionHandler.new);
  getIt.registerLazySingleton(Connectivity.new);
  getIt.registerLazySingleton(
    () => ConnectivityService(getIt<Connectivity>()),
  );
  getIt.registerLazySingleton(NotificationService.new);
  getIt.registerLazySingleton(() => GeofenceService(getIt<HiveService>()));

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      secureStorage: getIt<SecureStorageService>(),
      onSessionExpired: () {
        if (getIt.isRegistered<AuthBloc>()) {
          getIt<AuthBloc>().add(const AuthSessionExpired());
        }
      },
    ),
  );

  // Auth
  getIt.registerLazySingleton(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => AuthLocalDataSource(
      getIt<SecureStorageService>(),
      getIt<HiveService>(),
    ),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      sessionStorageService: getIt<SessionStorageService>(),
      exceptionHandler: getIt<ApiExceptionHandler>(),
    ),
  );
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RestoreSessionUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => HasSessionUseCase(getIt<AuthRepository>()));

  getIt.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      restoreSessionUseCase: getIt<RestoreSessionUseCase>(),
      hasSessionUseCase: getIt<HasSessionUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // Locations
  getIt.registerLazySingleton(
    () => LocationRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => LocationLocalDataSource(getIt<HiveService>()),
  );
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: getIt<LocationRemoteDataSource>(),
      localDataSource: getIt<LocationLocalDataSource>(),
      exceptionHandler: getIt<ApiExceptionHandler>(),
    ),
  );
  getIt.registerLazySingleton(() => GetLocationsUseCase(getIt<LocationRepository>()));
  getIt.registerLazySingleton(() => CreateLocationUseCase(getIt<LocationRepository>()));
  getIt.registerLazySingleton(() => UpdateLocationUseCase(getIt<LocationRepository>()));
  getIt.registerLazySingleton(() => DeleteLocationUseCase(getIt<LocationRepository>()));
  getIt.registerLazySingleton(() => GetCachedLocationsUseCase(getIt<LocationRepository>()));
  getIt.registerFactory(
    () => LocationBloc(
      getLocationsUseCase: getIt<GetLocationsUseCase>(),
      createLocationUseCase: getIt<CreateLocationUseCase>(),
      updateLocationUseCase: getIt<UpdateLocationUseCase>(),
      deleteLocationUseCase: getIt<DeleteLocationUseCase>(),
    ),
  );

  // Todos
  getIt.registerLazySingleton(
    () => TodoRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => TodoLocalDataSource(getIt<HiveService>()),
  );
  getIt.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: getIt<TodoRemoteDataSource>(),
      localDataSource: getIt<TodoLocalDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      exceptionHandler: getIt<ApiExceptionHandler>(),
    ),
  );
  getIt.registerLazySingleton(() => GetTodosUseCase(getIt<TodoRepository>()));
  getIt.registerLazySingleton(() => ToggleTodoUseCase(getIt<TodoRepository>()));
  getIt.registerLazySingleton(() => SyncTodosUseCase(getIt<TodoRepository>()));
  getIt.registerLazySingleton(() => GetPendingSyncChangesUseCase(getIt<TodoRepository>()));
  getIt.registerLazySingleton(() => GetPendingSyncCountUseCase(getIt<TodoRepository>()));

  getIt.registerFactory(
    () => TodoListBloc(
      getTodosUseCase: getIt<GetTodosUseCase>(),
      toggleTodoUseCase: getIt<ToggleTodoUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => SyncBloc(
      syncTodosUseCase: getIt<SyncTodosUseCase>(),
      getPendingChangesUseCase: getIt<GetPendingSyncChangesUseCase>(),
      getPendingCountUseCase: getIt<GetPendingSyncCountUseCase>(),
      todoRepository: getIt<TodoRepository>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  // Theme
  getIt.registerLazySingleton(() => ThemeCubit(getIt<SecureStorageService>()));
}

Future<void> initializeApp() async {
  await getIt<HiveService>().init();
  await getIt<NotificationService>().init();
  await getIt<ThemeCubit>().load();

  final geofence = getIt<GeofenceService>();
  final notifications = getIt<NotificationService>();
  geofence.onEntry = (location) {
    notifications.showGeofenceEntry(location.locationName);
  };
}
