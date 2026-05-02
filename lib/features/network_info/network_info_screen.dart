import 'package:flutter/material.dart';

import '../../app/pingflow_app.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/diagnostic_models.dart';
import '../../shared/widgets/pf_card.dart';
import '../../shared/widgets/section_title.dart';

class NetworkInfoScreen extends StatefulWidget {
  const NetworkInfoScreen({super.key});

  @override
  State<NetworkInfoScreen> createState() => _NetworkInfoScreenState();
}

class _NetworkInfoScreenState extends State<NetworkInfoScreen> {
  late Future<NetworkInfo> _future;
  bool _advancedMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = AppDependencies.of(context).diagnosticService.networkInfo();
  }

  void _refresh() {
    setState(() {
      _future = AppDependencies.of(context).diagnosticService.networkInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.networkInfo),
        actions: [
          IconButton(
            tooltip: strings.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<NetworkInfo>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(strings.unableNetworkDetails));
          }
          final info = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 680 : double.infinity,
                  ),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 22 : 16,
                      12,
                      isWide ? 22 : 16,
                      MediaQuery.paddingOf(context).bottom + 18,
                    ),
                    children: [
                      SectionTitle(strings.connection),
                      const SizedBox(height: 8),
                      PfCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wifi_rounded,
                              color: AppColors.accent,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(info.networkType,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 3),
                                  Text(
                                    strings.connected,
                                    style: const TextStyle(
                                        color: AppColors.accent),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SectionTitle(strings.ipAddresses),
                      const SizedBox(height: 8),
                      _InfoGroup(rows: [
                        _InfoRow(strings.localIp, info.localIp),
                        _InfoRow(strings.publicIp, info.publicIp),
                      ]),
                      const SizedBox(height: 14),
                      PfCard(
                        padding: EdgeInsets.zero,
                        child: SwitchListTile(
                          value: _advancedMode,
                          onChanged: (value) {
                            setState(() => _advancedMode = value);
                          },
                          secondary: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            strings.advancedMode,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(strings.advancedModeSubtitle),
                        ),
                      ),
                      if (_advancedMode) ...[
                        const SizedBox(height: 14),
                        SectionTitle(strings.technicalDetails),
                        const SizedBox(height: 8),
                        _InfoGroup(rows: [
                          _InfoRow(strings.connectionType, info.networkType),
                          _InfoRow(strings.signal, strings.managedBySystem),
                          _InfoRow(strings.dnsResolver, info.dns),
                          _InfoRow(strings.gateway, strings.providedBySystem),
                          _InfoRow(
                            strings.subnetMask,
                            strings.providedBySystem,
                          ),
                          _InfoRow(strings.backendStatus, info.backendStatus),
                        ]),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return PfCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final row in rows)
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(row.label,
                  style: const TextStyle(color: AppColors.textSecondary)),
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 210),
                child: Text(
                  row.value,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
