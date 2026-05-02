import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../shared/widgets/pf_card.dart';
import '../network_info/network_info_screen.dart';
import '../ping/ping_screen.dart';
import '../speed_test/speed_test_screen.dart';
import '../traceroute/traceroute_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.tools)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ToolRow(
            title: strings.ping,
            subtitle: strings.toolsPingSubtitle,
            icon: Icons.radar_rounded,
            color: AppColors.primary,
            screen: const PingScreen(),
          ),
          _ToolRow(
            title: strings.traceroute,
            subtitle: strings.toolsTracerouteSubtitle,
            icon: Icons.hub_rounded,
            color: AppColors.accent,
            screen: const TracerouteScreen(),
          ),
          _ToolRow(
            title: strings.networkInfo,
            subtitle: strings.toolsNetworkInfoSubtitle,
            icon: Icons.language_rounded,
            color: AppColors.purple,
            screen: const NetworkInfoScreen(),
          ),
          _ToolRow(
            title: strings.speedTest,
            subtitle: strings.toolsSpeedTestSubtitle,
            icon: Icons.speed_rounded,
            color: AppColors.warning,
            screen: const SpeedTestScreen(),
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PfCard(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: TextStyle(color: colors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
