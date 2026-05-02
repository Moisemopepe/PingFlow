import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/pingflow_app.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/diagnostic_models.dart';
import '../../core/utils/latency_quality.dart';
import '../../shared/widgets/host_input.dart';
import '../../shared/widgets/pf_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_title.dart';

class TracerouteScreen extends StatefulWidget {
  const TracerouteScreen({super.key});

  @override
  State<TracerouteScreen> createState() => _TracerouteScreenState();
}

class _TracerouteScreenState extends State<TracerouteScreen> {
  final _hostController = TextEditingController(text: 'google.com');
  final List<TraceHop> _hops = [];
  StreamSubscription<TraceHop>? _subscription;
  bool _running = false;
  bool _historySaved = false;
  String? _error;

  @override
  void dispose() {
    _subscription?.cancel();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final dependencies = AppDependencies.of(context);
    final strings = AppStrings.of(context);
    setState(() {
      _hops.clear();
      _running = true;
      _historySaved = false;
      _error = null;
    });
    await _subscription?.cancel();
    _subscription =
        dependencies.diagnosticService.traceroute(_hostController.text).listen(
              (hop) => setState(() => _hops.add(hop)),
              onError: (Object error) => setState(() {
                _error = error is ArgumentError
                    ? error.message.toString()
                    : strings.tracerouteFailed;
                _running = false;
              }),
              onDone: () {
                _saveHistory();
                setState(() => _running = false);
              },
            );
  }

  Future<void> _stop() async {
    await _subscription?.cancel();
    _saveHistory();
    if (mounted) {
      setState(() {
        _running = false;
        _error =
            _hops.isEmpty ? AppStrings.of(context).tracerouteStopped : null;
      });
    }
  }

  void _saveHistory() {
    if (_historySaved || _hops.isEmpty) return;
    _historySaved = true;
    final strings = AppStrings.of(context);
    AppDependencies.of(context).historyRepository.add(
          HistoryItem(
            type: DiagnosticType.traceroute,
            title: 'Traceroute ${_hostController.text.trim()}',
            subtitle: strings.justNow,
            result: '${_hops.length} ${strings.hops.toLowerCase()}',
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final avg = _hops.isEmpty
        ? 0
        : _hops.map((hop) => hop.latencyMs).reduce((a, b) => a + b) ~/
            _hops.length;
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.traceroute)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          HostInput(controller: _hostController),
          const SizedBox(height: 14),
          PrimaryButton(
            label: _running ? strings.stopTraceroute : strings.startTraceroute,
            icon: _running ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: _running ? AppColors.danger : AppColors.accent,
            onPressed: _running ? _stop : _start,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 22),
          PfCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Summary(label: strings.hops, value: '${_hops.length}'),
                _Summary(label: strings.avgTime, value: '$avg ms'),
                _Summary(
                  label: strings.destination,
                  value: _hops.isEmpty ? '-' : _hops.last.ip,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle(strings.route),
          const SizedBox(height: 10),
          if (_hops.isEmpty)
            PfCard(
              child: Text(
                strings.emptyTraceroute,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ..._hops.map(_HopTile.new),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class _HopTile extends StatelessWidget {
  const _HopTile(this.hop);

  final TraceHop hop;

  @override
  Widget build(BuildContext context) {
    final color = latencyColor(hop.latencyMs);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PfCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: AppColors.surface,
              child:
                  Text('${hop.number}', style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Icon(Icons.circle, color: color, size: 10),
            const SizedBox(width: 10),
            Expanded(child: Text(hop.ip)),
            Text(
              '${hop.latencyMs} ms',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
