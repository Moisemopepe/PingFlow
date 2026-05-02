import 'package:flutter/material.dart';

import '../../app/pingflow_app.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/diagnostic_models.dart';
import '../../shared/widgets/pf_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _HistoryFilter { all, ping, traceroute, speed }

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final history = AppDependencies.of(context).historyRepository;
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.history),
        actions: [
          IconButton(
            tooltip: strings.clearHistory,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: history.items.isEmpty
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(strings.deleteAllHistory),
                        content: Text(strings.clearHistoryMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(strings.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(strings.clear),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await history.clear();
                    }
                  },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: history,
        builder: (context, _) {
          final items =
              history.items.where((item) => _matchesFilter(item.type)).toList();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SegmentedButton<_HistoryFilter>(
                segments: [
                  ButtonSegment(
                    value: _HistoryFilter.all,
                    label: Text(strings.all),
                  ),
                  ButtonSegment(
                    value: _HistoryFilter.ping,
                    label: Text(strings.ping),
                  ),
                  ButtonSegment(
                    value: _HistoryFilter.traceroute,
                    label: Text(strings.traceroute),
                  ),
                  ButtonSegment(
                    value: _HistoryFilter.speed,
                    label: Text(strings.speed),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (selection) {
                  setState(() => _filter = selection.first);
                },
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                PfCard(
                  child: Text(
                    strings.noTestsMatch,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...items.map(_HistoryTile.new),
            ],
          );
        },
      ),
    );
  }

  bool _matchesFilter(DiagnosticType type) {
    return switch (_filter) {
      _HistoryFilter.all => true,
      _HistoryFilter.ping => type == DiagnosticType.ping,
      _HistoryFilter.traceroute => type == DiagnosticType.traceroute,
      _HistoryFilter.speed => type == DiagnosticType.speed,
    };
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.item);

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(item.subtitle,
                      style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
            Text(
              item.result,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
