import 'package:flutter/material.dart';
import 'package:field_track/core/theme/app_colors.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.cardBackground,
    required this.borderColor,
    required this.textSecondary,
    required this.badgePendingBg,
    required this.badgePendingText,
    required this.badgeCompletedBg,
    required this.badgeCompletedText,
    required this.offlineBannerBg,
    required this.offlineBannerText,
    required this.inputFill,
  });

  final Color cardBackground;
  final Color borderColor;
  final Color textSecondary;
  final Color badgePendingBg;
  final Color badgePendingText;
  final Color badgeCompletedBg;
  final Color badgeCompletedText;
  final Color offlineBannerBg;
  final Color offlineBannerText;
  final Color inputFill;

  static const light = AppThemeExtension(
    cardBackground: AppColors.lightSurface,
    borderColor: AppColors.lightBorder,
    textSecondary: AppColors.lightTextSecondary,
    badgePendingBg: AppColors.badgePendingBg,
    badgePendingText: AppColors.badgePendingText,
    badgeCompletedBg: AppColors.badgeCompletedBg,
    badgeCompletedText: AppColors.badgeCompletedText,
    offlineBannerBg: AppColors.offlineBannerBg,
    offlineBannerText: AppColors.offlineBannerText,
    inputFill: AppColors.lightSurface,
  );

  static const dark = AppThemeExtension(
    cardBackground: AppColors.darkSurfaceVariant,
    borderColor: AppColors.darkBorder,
    textSecondary: AppColors.darkTextSecondary,
    badgePendingBg: Color(0xFF431407),
    badgePendingText: Color(0xFFFDBA74),
    badgeCompletedBg: Color(0xFF14532D),
    badgeCompletedText: Color(0xFF86EFAC),
    offlineBannerBg: AppColors.darkOfflineBannerBg,
    offlineBannerText: AppColors.darkOfflineBannerText,
    inputFill: AppColors.darkSurfaceVariant,
  );

  @override
  AppThemeExtension copyWith({
    Color? cardBackground,
    Color? borderColor,
    Color? textSecondary,
    Color? badgePendingBg,
    Color? badgePendingText,
    Color? badgeCompletedBg,
    Color? badgeCompletedText,
    Color? offlineBannerBg,
    Color? offlineBannerText,
    Color? inputFill,
  }) {
    return AppThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      borderColor: borderColor ?? this.borderColor,
      textSecondary: textSecondary ?? this.textSecondary,
      badgePendingBg: badgePendingBg ?? this.badgePendingBg,
      badgePendingText: badgePendingText ?? this.badgePendingText,
      badgeCompletedBg: badgeCompletedBg ?? this.badgeCompletedBg,
      badgeCompletedText: badgeCompletedText ?? this.badgeCompletedText,
      offlineBannerBg: offlineBannerBg ?? this.offlineBannerBg,
      offlineBannerText: offlineBannerText ?? this.offlineBannerText,
      inputFill: inputFill ?? this.inputFill,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      badgePendingBg: Color.lerp(badgePendingBg, other.badgePendingBg, t)!,
      badgePendingText:
          Color.lerp(badgePendingText, other.badgePendingText, t)!,
      badgeCompletedBg:
          Color.lerp(badgeCompletedBg, other.badgeCompletedBg, t)!,
      badgeCompletedText:
          Color.lerp(badgeCompletedText, other.badgeCompletedText, t)!,
      offlineBannerBg: Color.lerp(offlineBannerBg, other.offlineBannerBg, t)!,
      offlineBannerText:
          Color.lerp(offlineBannerText, other.offlineBannerText, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light;
}
