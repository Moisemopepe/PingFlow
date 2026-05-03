import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/pingflow_app.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../shared/widgets/pf_card.dart';
import '../../shared/widgets/section_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final settings = dependencies.settingsRepository;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionTitle(strings.general),
              const SizedBox(height: 10),
              PfCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_rounded,
                          color: AppColors.primary),
                      title: Text(strings.theme,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(settings.themeMode == ThemeMode.dark
                          ? strings.dark
                          : strings.light),
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (enabled) => settings.setThemeMode(
                        enabled ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.translate_rounded,
                          color: AppColors.primary),
                      title: Text(strings.language,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: settings.languageCode,
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(strings.english),
                            ),
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text(strings.french),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) settings.setLanguageCode(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SectionTitle(strings.about),
              const SizedBox(height: 10),
              PfCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingRow(
                      icon: Icons.info_outline_rounded,
                      title: strings.aboutPingFlow,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutPingFlowScreen(),
                        ),
                      ),
                    ),
                    _SettingRow(
                      icon: Icons.privacy_tip_outlined,
                      title: strings.privacyPolicy,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _SettingRow(
                      icon: Icons.share_rounded,
                      title: strings.shareApp,
                      onTap: () => Share.share(strings.shareAppText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: _VersionText(prefix: strings.version),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AboutPingFlowScreen extends StatelessWidget {
  const AboutPingFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.aboutPingFlow)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PingFlow',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.aboutDescription,
                  style: TextStyle(
                    color: context.pfColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                _AboutVersionRow(label: strings.version),
                const SizedBox(height: 18),
                Text(
                  strings.features,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...strings.featureItems.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '- $feature',
                      style: TextStyle(color: context.pfColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.copyright,
                  style: TextStyle(color: context.pfColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static final Uri _privacyPolicyUri =
      Uri.parse('https://pingflow-api.onrender.com/privacy-policy');

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primary,
                  size: 34,
                ),
                const SizedBox(height: 14),
                Text(
                  strings.privacyPolicy,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.privacyDescription,
                  style: TextStyle(
                    color: context.pfColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      _privacyPolicyUri,
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(strings.onlinePrivacyPolicy),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionText extends StatelessWidget {
  const _VersionText({required this.prefix});

  final String prefix;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = _formatVersion(snapshot.data);

        return Text(
          version == null ? prefix : '$prefix $version',
          style: TextStyle(color: context.pfColors.textMuted),
        );
      },
    );
  }
}

class _AboutVersionRow extends StatelessWidget {
  const _AboutVersionRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        return _AboutRow(
            label: label, value: _formatVersion(snapshot.data) ?? '-');
      },
    );
  }
}

String? _formatVersion(PackageInfo? info) {
  if (info == null) return null;
  return info.version;
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(color: context.pfColors.textMuted)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.pfColors.textMuted,
      ),
    );
  }
}
