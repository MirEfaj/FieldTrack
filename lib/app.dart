import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_track/config/di/injection.dart';
import 'package:field_track/config/env/app_config.dart';
import 'package:field_track/config/routes/app_router.dart';
import 'package:field_track/core/theme/app_theme.dart';
import 'package:field_track/core/theme/theme_cubit.dart';
import 'package:field_track/core/theme/theme_cubit_state.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';

class FieldTrackApp extends StatefulWidget {
  const FieldTrackApp({super.key});

  @override
  State<FieldTrackApp> createState() => _FieldTrackAppState();
}

class _FieldTrackAppState extends State<FieldTrackApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(getIt<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<AuthBloc>()),
            BlocProvider.value(value: getIt<ThemeCubit>()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeCubitState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                title: AppConfig.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeState.materialThemeMode,
                routerConfig: _appRouter.router,
              );
            },
          ),
        );
      },
    );
  }
}
