import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class PfCard extends StatelessWidget {
  const PfCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.gradient,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.stroke),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? colors.background.withValues(alpha: 0.40)
                : colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: isDark ? 20 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: card,
    );
  }
}
