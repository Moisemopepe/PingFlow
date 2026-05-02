import 'package:flutter/material.dart';

import '../../app/pingflow_app.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/diagnostic_models.dart';
import '../../shared/widgets/pf_card.dart';
import '../../shared/widgets/section_title.dart';
import '../network_info/network_info_screen.dart';
import '../ping/ping_screen.dart';
import '../speed_test/speed_test_screen.dart';
import '../traceroute/traceroute_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppDependencies.of(context).historyRepository;
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: strings.menu,
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
        ),
        title: const _BrandTitle(),
        actions: [
          IconButton(
            tooltip: strings.premium,
            icon: const Icon(Icons.workspace_premium_rounded,
                color: AppColors.warning),
            onPressed: () {},
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: history,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const _HeroHeader(),
              const SizedBox(height: 22),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.02,
                children: [
                  _ToolCard(
                    title: strings.ping,
                    subtitle: strings.pingSubtitle,
                    icon: Icons.radar_rounded,
                    color: AppColors.primary,
                    onTap: () => _open(context, const PingScreen()),
                  ),
                  _ToolCard(
                    title: strings.traceroute,
                    subtitle: strings.tracerouteSubtitle,
                    icon: Icons.hub_rounded,
                    color: AppColors.accent,
                    onTap: () => _open(context, const TracerouteScreen()),
                  ),
                  _ToolCard(
                    title: strings.networkInfo,
                    subtitle: strings.networkInfoSubtitle,
                    icon: Icons.language_rounded,
                    color: AppColors.purple,
                    onTap: () => _open(context, const NetworkInfoScreen()),
                  ),
                  _ToolCard(
                    title: strings.speedTest,
                    subtitle: strings.speedTestSubtitle,
                    icon: Icons.speed_rounded,
                    color: AppColors.warning,
                    onTap: () => _open(context, const SpeedTestScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionTitle(
                strings.recentTests,
                action: TextButton(
                  onPressed: () {},
                  child: Text(strings.seeAll),
                ),
              ),
              const SizedBox(height: 10),
              ...history.items.take(3).map(_RecentTestTile.new),
            ],
          );
        },
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        children: [
          TextSpan(text: 'Ping', style: TextStyle(color: colors.textPrimary)),
          const TextSpan(
              text: 'Flow', style: TextStyle(color: AppColors.accent)),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = context.pfColors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.heroTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.heroSubtitle,
                style: TextStyle(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.55),
                AppColors.primary.withValues(alpha: 0.08),
                colors.background.withValues(alpha: 0),
              ],
            ),
          ),
          child: const Icon(Icons.public_rounded, size: 72),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    return PfCard(
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.22), colors.card],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 38),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RecentTestTile extends StatelessWidget {
  const _RecentTestTile(this.item);

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    final color = switch (item.type) {
      DiagnosticType.ping => AppColors.primary,
      DiagnosticType.traceroute => AppColors.accent,
      DiagnosticType.speed => AppColors.warning,
    };
    final icon = switch (item.type) {
      DiagnosticType.ping => Icons.radar_rounded,
      DiagnosticType.traceroute => Icons.hub_rounded,
      DiagnosticType.speed => Icons.speed_rounded,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PfCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              item.result,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
