import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/config/routes/route_names.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';
import 'package:field_track/features/authentication/presentation/widgets/auth_widgets.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      builder: (context, isLoading) {
        return Form(
          key: _formKey,
          child: AuthFormColumn(
            children: [
              const AuthLogo(),
              SizedBox(height: AuthSpacing.logoBottom),
              const AuthHeader(
                title: 'Welcome back',
                subtitle: 'Sign in to start your shift',
              ),
              SizedBox(height: AuthSpacing.headerBottom),
              AuthEmailField(controller: _emailController),
              SizedBox(height: AuthSpacing.fieldGap),
              AuthPasswordField(
                controller: _passwordController,
                hint: null,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              SizedBox(height: AuthSpacing.forgotTop),
              const AuthForgotPasswordLink(),
              SizedBox(height: AuthSpacing.forgotBottom),
              AppButton(
                label: 'Sign in',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              SizedBox(height: AuthSpacing.buttonBottom),
              AuthFooterLink(
                prefix: "Don't have an account? ",
                linkLabel: 'Register',
                onTap: () => context.push(RouteNames.register),
              ),
            ],
          ),
        );
      },
    );
  }
}
