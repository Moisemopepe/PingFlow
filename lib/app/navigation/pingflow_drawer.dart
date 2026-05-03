import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/pingflow_app.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/diagnostic_models.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/pf_card.dart';

class PingFlowDrawer extends StatelessWidget {
  const PingFlowDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    return Drawer(
      width: MediaQuery.sizeOf(context).width.clamp(300.0, 380.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      backgroundColor: colors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          children: const [
            _DrawerHeader(),
            SizedBox(height: 22),
            _DrawerSectionLabel(),
            SizedBox(height: 10),
            _DrawerActions(),
            SizedBox(height: 26),
            Divider(),
            SizedBox(height: 18),
            _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.28),
                ),
              ),
              child: const Icon(
                Icons.network_check_rounded,
                color: AppColors.accent,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall,
                      children: [
                        TextSpan(
                          text: 'Ping',
                          style: TextStyle(
                            color: context.pfColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const TextSpan(
                          text: 'Flow',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.networkDiagnosticTool,
                    style: TextStyle(
                      color: context.pfColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _NetworkStatusCard(),
      ],
    );
  }
}

class _NetworkStatusCard extends StatelessWidget {
  const _NetworkStatusCard();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = context.pfColors;
    return FutureBuilder<NetworkInfo>(
      future: AppDependencies.of(context).diagnosticService.networkInfo(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final connected = info?.backendStatus == 'Connected';
        final status = info == null
            ? strings.checkingNetwork
            : connected
                ? strings.connected
                : strings.disconnected;
        final networkType = info?.networkType ?? '-';

        return PfCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (connected || info == null
                          ? AppColors.accent
                          : AppColors.danger)
                      .withValues(alpha: 0.14),
                ),
                child: Icon(
                  connected || info == null
                      ? Icons.circle_rounded
                      : Icons.wifi_off_rounded,
                  size: connected || info == null ? 12 : 20,
                  color: connected || info == null
                      ? AppColors.accent
                      : AppColors.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt_rounded,
                          color: colors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            networkType,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '18 ms',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.of(context).menu,
      style: TextStyle(
        color: context.pfColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _DrawerActions extends StatelessWidget {
  const _DrawerActions();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Column(
      children: [
        _DrawerItem(
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.warning,
          title: strings.feedbackBugReport,
          subtitle: strings.feedbackBugReportSubtitle,
          onTap: () => _open(context, const FeedbackScreen()),
        ),
        const SizedBox(height: 10),
        _DrawerItem(
          icon: Icons.shield_rounded,
          color: AppColors.primary,
          title: strings.privacyPolicy,
          subtitle: strings.privacyDrawerSubtitle,
          onTap: () => _open(context, const PrivacyPolicyScreen()),
        ),
        const SizedBox(height: 10),
        _DrawerItem(
          icon: Icons.info_rounded,
          color: AppColors.primary,
          title: strings.about,
          subtitle: strings.aboutDrawerSubtitle,
          onTap: () => _open(context, const AboutPingFlowScreen()),
        ),
      ],
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: screen,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return SlideTransition(position: offset, child: child);
        },
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.stroke,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: color.withValues(alpha: 0.14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '-';
        return Column(
          children: [
            Text(
              '${strings.version} $version',
              style: TextStyle(
                color: context.pfColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.madeWithLove,
              style: TextStyle(
                color: context.pfColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _topic = 'feedback';

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.feedbackBugReport)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.feedbackBugReport,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _topic,
                    decoration: InputDecoration(labelText: strings.topic),
                    items: [
                      DropdownMenuItem(
                        value: 'feedback',
                        child: Text(strings.feedback),
                      ),
                      DropdownMenuItem(
                        value: 'feature',
                        child: Text(strings.featureRequest),
                      ),
                      DropdownMenuItem(
                        value: 'bug',
                        child: Text(strings.bugReport),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _topic = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        InputDecoration(labelText: strings.emailOptional),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 6,
                    decoration: InputDecoration(labelText: strings.message),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? strings.messageRequired
                        : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(strings.submit),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _messageController.clear();
    _emailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.of(context).feedbackSent),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
