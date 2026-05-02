enum DiagnosticType { ping, traceroute, speed }

class PingReply {
  const PingReply({
    required this.sequence,
    required this.host,
    required this.latencyMs,
    required this.ttl,
    required this.success,
  });

  final int sequence;
  final String host;
  final int latencyMs;
  final int ttl;
  final bool success;
}

class PingStats {
  const PingStats({
    required this.sent,
    required this.received,
    required this.min,
    required this.max,
    required this.avg,
    required this.packetLoss,
  });

  final int sent;
  final int received;
  final int min;
  final int max;
  final double avg;
  final double packetLoss;
}

class TraceHop {
  const TraceHop({
    required this.number,
    required this.ip,
    required this.latencyMs,
  });

  final int number;
  final String ip;
  final int latencyMs;
}

class NetworkInfo {
  const NetworkInfo({
    required this.localIp,
    required this.publicIp,
    required this.dns,
    required this.gateway,
    required this.networkType,
    required this.signal,
    required this.subnetMask,
    required this.backendStatus,
  });

  final String localIp;
  final String publicIp;
  final String dns;
  final String gateway;
  final String networkType;
  final String signal;
  final String subnetMask;
  final String backendStatus;
}

class SpeedResult {
  const SpeedResult({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.pingMs,
    required this.jitterMs,
  });

  final double downloadMbps;
  final double uploadMbps;
  final int pingMs;
  final int jitterMs;
}

enum SpeedTestPhase { idle, ping, download, upload, complete }

class SpeedProgress {
  const SpeedProgress({
    required this.phase,
    this.downloadMbps = 0,
    this.uploadMbps = 0,
    this.pingMs = 0,
    this.jitterMs = 0,
  });

  final SpeedTestPhase phase;
  final double downloadMbps;
  final double uploadMbps;
  final int pingMs;
  final int jitterMs;

  SpeedResult toResult() {
    return SpeedResult(
      downloadMbps: downloadMbps,
      uploadMbps: uploadMbps,
      pingMs: pingMs,
      jitterMs: jitterMs,
    );
  }
}

class HistoryItem {
  const HistoryItem({
    this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.result,
    required this.createdAt,
  });

  final int? id;
  final DiagnosticType type;
  final String title;
  final String subtitle;
  final String result;
  final DateTime createdAt;
}
