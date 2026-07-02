import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/config/di/injection.dart';
import 'package:field_track/config/routes/route_names.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';
import 'package:field_track/features/authentication/presentation/pages/login_page.dart';
import 'package:field_track/features/authentication/presentation/pages/profile_page.dart';
import 'package:field_track/features/authentication/presentation/pages/register_page.dart';
import 'package:field_track/features/authentication/presentation/pages/splash_page.dart';
import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/geofence/data/services/geofence_service.dart';
import 'package:field_track/features/locations/domain/usecases/location_usecases.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/locations/presentation/pages/location_form_page.dart';
import 'package:field_track/features/locations/presentation/pages/locations_page.dart';
import 'package:field_track/features/todos/presentation/bloc/sync_bloc.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_list_bloc.dart';
import 'package:field_track/features/todos/presentation/pages/sync_page.dart';
import 'package:field_track/features/todos/presentation/pages/tasks_page.dart';
import 'package:field_track/shared/widgets/app_shell.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: _AuthRefreshListenable(_authBloc),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;
      final path = state.uri.path;

      final isAuthRoute =
          path == RouteNames.login || path == RouteNames.register;
      final isSplash = path == RouteNames.splash;

      if (isSplash) {
        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading) {
          return null;
        }
        return isAuthenticated ? RouteNames.tasks : RouteNames.login;
      }

      if (isLoading && !isAuthRoute) {
        return RouteNames.splash;
      }

      if (!isAuthenticated && !isAuthRoute && path != RouteNames.splash) {
        return RouteNames.login;
      }

      if (isAuthenticated && isAuthRoute) {
        return RouteNames.tasks;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, _) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          _startGeofenceMonitoring();
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<TodoListBloc>()),
              BlocProvider(create: (_) => getIt<LocationBloc>()..add(const LocationsLoadRequested())),
              BlocProvider(create: (_) => getIt<SyncBloc>()),
            ],
            child: AppShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: RouteNames.tasks,
            builder: (_, _) => const TasksPage(),
          ),
          GoRoute(
            path: RouteNames.locations,
            builder: (_, _) => const LocationsPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, _) => const LocationFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (_, state) => LocationFormPage(
                  locationId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.sync,
            builder: (_, _) => const SyncPage(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, _) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );

  void _startGeofenceMonitoring() {
    final locations = getIt<GetCachedLocationsUseCase>()();
    if (locations.isNotEmpty) {
      getIt<GeofenceService>().startMonitoring(locations);
    } else {
      getIt<GetLocationsUseCase>()().then((result) {
        if (result case Success(:final data)) {
          getIt<GeofenceService>().startMonitoring(data);
        }
      });
    }
  }
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._authBloc) {
    _authBloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _authBloc;
}
