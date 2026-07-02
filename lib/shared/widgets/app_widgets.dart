import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_track/core/theme/app_colors.dart';
import 'package:field_track/core/theme/app_radius.dart';
import 'package:field_track/core/theme/app_spacing.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';
import 'package:field_track/core/theme/app_typography.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text(label),
                    ],
                  )
                : Text(label),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor ?? context.appTheme.borderColor),
        ),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(label),
                ],
              )
            : Text(label),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final secondary = context.appTheme.textSecondary;
    final iconColor = secondary.withValues(alpha: 0.85);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.bodyMedium(secondary)),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          validator: widget.validator,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppTypography.bodyLarge(onSurface),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyLarge(
              secondary.withValues(alpha: 0.65),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: iconColor, size: 20.sp)
                : null,
            prefixIconConstraints: BoxConstraints(
              minWidth: 48.w,
              minHeight: 48.h,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: iconColor,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            suffixIconConstraints: BoxConstraints(
              minWidth: 48.w,
              minHeight: 48.h,
            ),
            constraints: BoxConstraints(minHeight: 48.h),
          ),
        ),
      ],
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          Icons.search,
          color: context.appTheme.textSecondary,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.appTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.appTheme.borderColor),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: card,
      );
    }
    return card;
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall(textColor).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Try again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: context.appTheme.textSecondary),
          SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTypography.bodyLarge(context.appTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    required this.leading,
    this.onTap,
    this.trailing = const Icon(Icons.chevron_right),
    this.subtitle,
  });

  final String title;
  final Widget leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          leading,
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall(
                      context.appTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    context.appTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.label,
    required this.value,
    required this.displayValue,
    required this.onChanged,
    this.min = 50,
    this.max = 500,
  });

  final String label;
  final double value;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.titleMedium(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              displayValue,
              style: AppTypography.titleMedium(AppColors.primary),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 10).round(),
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class AppProgressCard extends StatelessWidget {
  const AppProgressCard({
    super.key,
    required this.title,
    required this.progressText,
    required this.progress,
  });

  final String title;
  final String progressText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium(
                  Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                progressText,
                style: AppTypography.bodyMedium(AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.appTheme.borderColor,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class AppSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge(
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(context.appTheme.textSecondary),
          ),
          SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDestructive ? AppColors.error : AppColors.primary,
              ),
              child: Text(confirmLabel),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
