import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';
import 'package:field_track/features/authentication/presentation/widgets/auth_widgets.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            fullName: _nameController.text.trim(),
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
                title: 'Create your account',
                subtitle: 'Join your team on FieldTrack',
              ),
              SizedBox(height: AuthSpacing.headerBottom),
              AuthNameField(controller: _nameController),
              SizedBox(height: AuthSpacing.fieldGap),
              AuthEmailField(controller: _emailController),
              SizedBox(height: AuthSpacing.fieldGap),
              AuthPasswordField(
                controller: _passwordController,
                onFieldSubmitted: (_) => _submit(),
              ),
              SizedBox(height: AuthSpacing.formBottom),
              AppButton(
                label: 'Create account',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              SizedBox(height: AuthSpacing.buttonBottom),
              AuthFooterLink(
                prefix: 'Already have an account? ',
                linkLabel: 'Sign in',
                onTap: () => context.pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}
