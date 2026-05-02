import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/pingflow_app.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/diagnostic_models.dart';
import '../../shared/widgets/primary_button.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  bool _running = false;
  SpeedProgress _progress = const SpeedProgress(phase: SpeedTestPhase.idle);
  SpeedResult? _result;
  String? _error;
  StreamSubscription<SpeedProgress>? _subscription;
  final List<double> _downloadSamples = [];
  final List<double> _uploadSamples = [];

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final dependencies = AppDependencies.of(context);
    final strings = AppStrings.of(context);
    await _subscription?.cancel();
    setState(() {
      _running = true;
      _error = null;
      _result = null;
      _progress = const SpeedProgress(phase: SpeedTestPhase.ping);
      _downloadSamples.clear();
      _uploadSamples.clear();
    });
    _subscription = dependencies.diagnosticService.speedTestStream().listen(
          (progress) {
            setState(() {
              _progress = progress;
              if (progress.phase == SpeedTestPhase.download) {
                _pushSample(_downloadSamples, progress.downloadMbps);
              }
              if (progress.phase == SpeedTestPhase.upload) {
                _pushSample(_uploadSamples, progress.uploadMbps);
              }
              if (progress.phase == SpeedTestPhase.complete) {
                _result = progress.toResult();
              }
            });
          },
          onError: (_) => setState(() {
            _running = false;
            _error = strings.speedTestFailed;
          }),
          onDone: () {
            final result = _result ?? _progress.toResult();
            dependencies.historyRepository.add(
              HistoryItem(
                type: DiagnosticType.speed,
                title: strings.speedTest,
                subtitle: strings.justNow,
                result: '${result.downloadMbps.toStringAsFixed(1)} Mbps',
                createdAt: DateTime.now(),
              ),
            );
            if (mounted) setState(() => _running = false);
          },
        );
  }

  Future<void> _stop() async {
    await _subscription?.cancel();
    if (mounted) {
      setState(() {
        _running = false;
        _error = AppStrings.of(context).speedTestStopped;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final result = _result;
    final showValues = _running || result != null;
    final activeSpeed = _progress.phase == SpeedTestPhase.upload
        ? _progress.uploadMbps
        : _progress.downloadMbps;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(strings.speedTest),
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
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
          final isShort = constraints.maxHeight < 760;
          final gaugeHeight = isWide ? 320.0 : (isShort ? 230.0 : 252.0);
          final contentWidth = isWide ? 680.0 : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 22 : 12,
                  0,
                  isWide ? 22 : 12,
                  18,
                ),
                children: [
                  SizedBox(
                    height: gaugeHeight,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: activeSpeed),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedSpeed, _) {
                        return CustomPaint(
                          painter: _GaugePainter(animatedSpeed),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: isShort ? 42 : 54),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    showValues
                                        ? animatedSpeed.toStringAsFixed(1)
                                        : '--',
                                    style: TextStyle(
                                      fontSize: isShort ? 32 : 36,
                                      height: 1,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Mbps',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _phaseLabel(_progress.phase),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    height: 94,
                    child: GridView(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: 94,
                      ),
                      children: [
                        _SpeedMetricCard(
                          icon: Icons.arrow_downward_rounded,
                          label: strings.download,
                          value: showValues
                              ? '${_progress.downloadMbps.toStringAsFixed(1)} Mbps'
                              : '--',
                          color: AppColors.purple,
                          samples: _downloadSamples,
                        ),
                        _SpeedMetricCard(
                          icon: Icons.arrow_upward_rounded,
                          label: strings.upload,
                          value: showValues
                              ? '${_progress.uploadMbps.toStringAsFixed(1)} Mbps'
                              : '--',
                          color: AppColors.accent,
                          samples: _uploadSamples,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: GridView(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: 64,
                      ),
                      children: [
                        _CompactMetricCard(
                          label: strings.ping,
                          value: showValues ? '${_progress.pingMs} ms' : '--',
                        ),
                        _CompactMetricCard(
                          label: strings.jitter,
                          value: showValues ? '${_progress.jitterMs} ms' : '--',
                        ),
                        _CompactMetricCard(
                          label: strings.loss,
                          value: showValues ? '0%' : '--',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: PrimaryButton(
              label: _running ? strings.stopTest : strings.startTest,
              icon: _running ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: _running ? AppColors.danger : AppColors.primary,
              onPressed: _running ? _stop : _start,
            ),
          ),
        ),
      ),
    );
  }

  String _phaseLabel(SpeedTestPhase phase) {
    final strings = AppStrings.of(context);
    return switch (phase) {
      SpeedTestPhase.idle => strings.ready,
      SpeedTestPhase.ping => strings.measuringPingJitter,
      SpeedTestPhase.download => strings.measuringDownload,
      SpeedTestPhase.upload => strings.measuringUpload,
      SpeedTestPhase.complete => strings.completed,
    };
  }

  void _pushSample(List<double> samples, double value) {
    samples.add(value);
    if (samples.length > 18) samples.removeAt(0);
  }
}

class _SpeedMetricCard extends StatelessWidget {
  const _SpeedMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.samples,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final List<double> samples;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 22,
            child: CustomPaint(
              painter: _SparklinePainter(samples, color),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  const _CompactMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.value);

  final double value;

  static const _start = math.pi * 0.84;
  static const _sweep = math.pi * 1.32;
  static const _maxSpeed = 500.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.60);
    final radius = math.min(size.width * 0.38, size.height * 0.48);
    final rect = Rect.fromCircle(center: center, radius: radius);
    const strokeWidth = 18.0;

    final trackPaint = Paint()
      ..color = AppColors.stroke.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, trackPaint);

    final gradientPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: _start,
        endAngle: _start + _sweep,
        colors: [
          AppColors.purple,
          AppColors.primary,
          AppColors.accent,
          AppColors.warning,
        ],
        stops: [0, 0.36, 0.72, 1],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, gradientPaint);

    _drawTicks(canvas, center, radius);

    final progress = (value / _maxSpeed).clamp(0.0, 1.0).toDouble();
    final angle = _start + _sweep * progress;
    final needleEnd = Offset(
      center.dx + radius * 0.58 * math.cos(angle),
      center.dy + radius * 0.58 * math.sin(angle),
    );
    final needleStart = Offset(
      center.dx - radius * 0.09 * math.cos(angle),
      center.dy - radius * 0.09 * math.sin(angle),
    );

    canvas.drawLine(
      needleStart,
      needleEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 9, Paint()..color = Colors.white);
    canvas.drawCircle(center, 4.5, Paint()..color = AppColors.card);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 10; i++) {
      final progress = i / 10;
      final angle = _start + _sweep * progress;
      final outer = Offset(
        center.dx + radius * 0.88 * math.cos(angle),
        center.dy + radius * 0.88 * math.sin(angle),
      );
      final inner = Offset(
        center.dx + radius * (i.isEven ? 0.79 : 0.83) * math.cos(angle),
        center.dy + radius * (i.isEven ? 0.79 : 0.83) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);

      if (i.isEven) {
        textPainter.text = TextSpan(
          text: (i * 50).toString(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        );
        textPainter.layout();
        final labelOffset = Offset(
          center.dx + radius * 0.66 * math.cos(angle) - textPainter.width / 2,
          center.dy + radius * 0.66 * math.sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return value != oldDelegate.value;
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.samples, this.color);

  final List<double> samples;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final values = samples.length < 2
        ? const [8, 16, 10, 24, 18, 30, 20, 26, 14, 22, 19, 28]
        : samples;
    final maxValue = values.reduce(math.max).clamp(1.0, double.infinity);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = values[i] / maxValue;
      final y = size.height - normalized * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = color.withValues(alpha: samples.length < 2 ? 0.08 : 0.16),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: samples.length < 2 ? 0.55 : 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.samples != samples || oldDelegate.color != color;
  }
}
