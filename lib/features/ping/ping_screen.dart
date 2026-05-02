import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/pingflow_app.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/diagnostic_models.dart';
import '../../shared/widgets/host_input.dart';
import '../../shared/widgets/pf_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_title.dart';

class PingScreen extends StatefulWidget {
  const PingScreen({super.key});

  @override
  State<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends State<PingScreen> {
  final _hostController = TextEditingController(text: '8.8.8.8');
  final List<PingReply> _replies = [];
  StreamSubscription<PingReply>? _subscription;
  bool _running = false;
  bool _historySaved = false;
  int _packetCount = 4;
  String? _error;

  PingStats get _stats {
    final successful = _replies.where((reply) => reply.success).toList();
    final sent = _replies.length;
    if (successful.isEmpty) {
      return PingStats(
        sent: sent,
        received: 0,
        min: 0,
        max: 0,
        avg: 0,
        packetLoss: sent == 0 ? 0 : 100,
      );
    }
    final latencies = successful.map((reply) => reply.latencyMs).toList();
    final total = latencies.reduce((value, item) => value + item);
    return PingStats(
      sent: sent,
      received: successful.length,
      min: latencies.reduce((value, item) => value < item ? value : item),
      max: latencies.reduce((value, item) => value > item ? value : item),
      avg: total / successful.length,
      packetLoss: sent == 0 ? 0 : ((sent - successful.length) / sent) * 100,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _startPing() async {
    FocusScope.of(context).unfocus();
    final dependencies = AppDependencies.of(context);
    setState(() {
      _running = true;
      _historySaved = false;
      _error = null;
      _replies.clear();
    });
    await _subscription?.cancel();
    _subscription = dependencies.diagnosticService
        .ping(_hostController.text.trim(), count: _packetCount)
        .listen(
          (reply) => setState(() => _replies.insert(0, reply)),
          onError: (Object error) => setState(() {
            _error = _message(error);
            _running = false;
          }),
          onDone: () {
            _saveHistory();
            setState(() => _running = false);
          },
        );
  }

  Future<void> _stopPing() async {
    await _subscription?.cancel();
    _saveHistory();
    if (mounted) {
      setState(() {
        _running = false;
        _error = _replies.isEmpty ? AppStrings.of(context).pingStopped : null;
      });
    }
  }

  void _saveHistory() {
    if (_historySaved || _replies.isEmpty) return;
    _historySaved = true;
    final stats = _stats;
    final strings = AppStrings.of(context);
    AppDependencies.of(context).historyRepository.add(
          HistoryItem(
            type: DiagnosticType.ping,
            title: 'Ping ${_hostController.text.trim()}',
            subtitle: strings.justNow,
            result: '${stats.avg.toStringAsFixed(0)} ms',
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.ping),
        actions: [
          IconButton(
            tooltip: strings.history,
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
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
                  HostInput(controller: _hostController),
                  const SizedBox(height: 10),
                  PfCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.packets,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _packetCount,
                            items: const [4, 8, 12, 20]
                                .map(
                                  (count) => DropdownMenuItem<int>(
                                    value: count,
                                    child: Text('$count'),
                                  ),
                                )
                                .toList(),
                            onChanged: _running
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _packetCount = value);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: _running ? strings.stopPing : strings.startPing,
                    icon: _running
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    color: _running ? AppColors.danger : AppColors.primary,
                    onPressed: _running ? _stopPing : _startPing,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                            label: strings.sent, value: '${stats.sent}'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: strings.received,
                          value: '${stats.received}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: strings.loss,
                          value: '${stats.packetLoss.toStringAsFixed(0)}%',
                          color: stats.packetLoss > 0
                              ? AppColors.warning
                              : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PfCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LatencyStat(label: strings.min, value: stats.min),
                        _LatencyStat(
                            label: strings.avg, value: stats.avg.round()),
                        _LatencyStat(label: strings.max, value: stats.max),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SectionTitle(strings.responseTime),
                  const SizedBox(height: 8),
                  PfCard(
                    child: SizedBox(
                      height: 104,
                      child: CustomPaint(
                        painter: _PingGraphPainter(
                          _replies.reversed.toList(),
                          context.pfColors.stroke,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SectionTitle(strings.pingResults),
                  const SizedBox(height: 8),
                  if (_replies.isEmpty)
                    PfCard(
                      child: Text(
                        strings.emptyPing,
                        style: TextStyle(color: context.pfColors.textSecondary),
                      ),
                    )
                  else
                    ..._replies.map(_ReplyTile.new),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _message(Object error) {
    if (error is ArgumentError) return error.message.toString();
    return AppStrings.of(context).networkTimeout;
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    return PfCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color ?? colors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LatencyStat extends StatelessWidget {
  const _LatencyStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.pfColors;
    return Column(
      children: [
        Text(label, style: TextStyle(color: colors.textMuted)),
        const SizedBox(height: 4),
        Text('$value ms', style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile(this.reply);

  final PingReply reply;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = context.pfColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PfCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              reply.success ? Icons.circle : Icons.error_rounded,
              color: reply.success ? AppColors.accent : AppColors.danger,
              size: 12,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reply.success
                    ? reply.ttl == 0
                        ? '${reply.host} - ${reply.latencyMs} ms - TTL N/A'
                        : strings.replyFrom(
                            reply.host,
                            reply.latencyMs,
                            reply.ttl,
                          )
                    : strings.requestTimedOut(reply.host),
                style: TextStyle(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PingGraphPainter extends CustomPainter {
  const _PingGraphPainter(this.replies, this.gridColor);

  final List<PingReply> replies;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final points = replies.where((reply) => reply.success).toList();
    if (points.length < 2) return;
    final maxLatency =
        points.map((reply) => reply.latencyMs).reduce(max).toDouble();
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - (points[i].latencyMs / maxLatency) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PingGraphPainter oldDelegate) {
    return oldDelegate.replies != replies;
  }
}
