import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_track/config/routes/route_names.dart';
import 'package:field_track/core/theme/app_radius.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';
import 'package:field_track/core/theme/app_typography.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc_impl.dart';
import 'package:field_track/features/authentication/presentation/utils/auth_validators.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

/// Authentication-screen spacing tuned to match Figma.
abstract final class AuthSpacing {
  static EdgeInsets get screen =>
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h);

  static double get logoBottom => 24.h;
  static double get titleBottom => 8.h;
  static double get headerBottom => 32.h;
  static double get fieldGap => 16.h;
  static double get forgotTop => 8.h;
  static double get forgotBottom => 24.h;
  static double get formBottom => 24.h;
  static double get buttonBottom => 24.h;
  static double get keyboardExtra => 8.h;
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(
          Icons.location_on_rounded,
          color: colorScheme.onPrimary,
          size: 28.sp,
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = context.appTheme.textSecondary;

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.displayLarge(onSurface),
        ),
        SizedBox(height: AuthSpacing.titleBottom),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge(secondary),
        ),
      ],
    );
  }
}

class AuthForgotPasswordLink extends StatelessWidget {
  const AuthForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    final linkColor = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: linkColor,
        ),
        child: Text(
          'Forgot password?',
          style: AppTypography.bodyMedium(linkColor).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.linkLabel,
    required this.onTap,
  });

  final String prefix;
  final String linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = context.appTheme.textSecondary;
    final linkColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            prefix,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(secondary),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkLabel,
            style: AppTypography.bodyMedium(linkColor).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthNameField extends StatelessWidget {
  const AuthNameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Full name',
      controller: controller,
      hint: 'John Doe',
      prefixIcon: Icons.person_outline,
      textInputAction: TextInputAction.next,
      validator: AuthValidators.name,
    );
  }
}

class AuthEmailField extends StatelessWidget {
  const AuthEmailField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Email',
      controller: controller,
      hint: 'john.doe@example.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      validator: AuthValidators.email,
    );
  }
}

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.hint = 'Create a password',
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Password',
      controller: controller,
      hint: hint,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: AuthValidators.password,
    );
  }
}

/// Vertically centers auth content while keeping scroll on small screens.
class AuthScreenLayout extends StatelessWidget {
  const AuthScreenLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final padding = AuthSpacing.screen;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding.copyWith(
            bottom: padding.bottom + bottomInset + AuthSpacing.keyboardExtra,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: bottomInset > 0
                  ? 0
                  : constraints.maxHeight - padding.vertical,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class AuthFormColumn extends StatelessWidget {
  const AuthFormColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Column(
      mainAxisAlignment:
          keyboardOpen ? MainAxisAlignment.start : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

typedef AuthPageBuilder = Widget Function(BuildContext context, bool isLoading);

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({super.key, required this.builder});

  final AuthPageBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go(RouteNames.tasks);
            }
            if (state.status == AuthStatus.failure &&
                state.errorMessage != null) {
              AppSnackBar.show(context, state.errorMessage!, isError: true);
            }
          },
          builder: (context, state) {
            return AuthScreenLayout(
              child: builder(
                context,
                state.status == AuthStatus.loading,
              ),
            );
          },
        ),
      ),
    );
  }
}
