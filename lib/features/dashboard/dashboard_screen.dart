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
  const DashboardScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    final history = AppDependencies.of(context).historyRepository;
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: strings.menu,
          icon: const Icon(Icons.menu_rounded),
          onPressed: onOpenDrawer,
        ),
        title: const _BrandTitle(),
      ),
      body: ListenableBuilder(
        listenable: history,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const _NetworkStatusPill(),
              const SizedBox(height: 18),
              const _HeroHeader(),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.12,
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
              const SizedBox(height: 28),
              SectionTitle(
                strings.recentTests,
                action: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: Text(strings.seeAll),
                ),
              ),
              const SizedBox(height: 14),
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

class _NetworkStatusPill extends StatelessWidget {
  const _NetworkStatusPill();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = context.pfColors;
    return FutureBuilder(
      future: AppDependencies.of(context).diagnosticService.networkInfo(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final connected = info?.backendStatus == 'Connected';
        final status = info == null
            ? strings.checkingNetwork
            : '${strings.networkOnline} • ${info.networkType} • ${connected ? strings.serverReady : info.backendStatus}';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.stroke),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                connected || info == null
                    ? Icons.wifi_tethering_rounded
                    : Icons.wifi_off_rounded,
                color: connected || info == null
                    ? AppColors.accent
                    : AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  status,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    return Column(
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
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
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
          Icon(icon, color: color, size: 34),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
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
                  Text(
                    item.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
