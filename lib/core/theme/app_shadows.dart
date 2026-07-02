import 'package:flutter/material.dart';

abstract final class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
