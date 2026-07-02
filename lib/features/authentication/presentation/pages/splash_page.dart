import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoading(),
    );
  }
}
