import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../config/app_config.dart';
import '../models/diagnostic_models.dart';

abstract class DiagnosticService {
  Stream<PingReply> ping(String host, {int count = 10});
  Stream<TraceHop> traceroute(String host);
  Future<NetworkInfo> networkInfo();
  Future<SpeedResult> speedTest();
  Stream<SpeedProgress> speedTestStream();
}

class RealDiagnosticService implements DiagnosticService {
  RealDiagnosticService({
    String baseUrl = AppConfig.backendBaseUrl,
    HttpClient? httpClient,
  })  : _baseUri = Uri.parse(baseUrl),
        _client = httpClient ?? HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 8);
  }

  final Uri _baseUri;
  final HttpClient _client;

  @override
  Stream<PingReply> ping(String host, {int count = 10}) async* {
    _validateHost(host);
    await for (final event in _readNdjson(
      _uri('/api/ping/stream', {'host': host, 'count': '$count'}),
    )) {
      yield PingReply(
        sequence: _asInt(event['sequence']),
        host: (event['host'] as String?) ?? host,
        latencyMs: _asInt(event['latencyMs']),
        ttl: _asInt(event['ttl'], fallback: 0),
        success: event['success'] == true,
      );
    }
  }

  @override
  Stream<TraceHop> traceroute(String host) async* {
    _validateHost(host);
    await for (final event in _readNdjson(
      _uri('/api/traceroute/stream', {'host': host}),
    )) {
      yield TraceHop(
        number: _asInt(event['number']),
        ip: (event['ip'] as String?) ?? '*',
        latencyMs: _asInt(event['latencyMs']),
      );
    }
  }

  @override
  Future<SpeedResult> speedTest() async {
    SpeedProgress? latest;
    await for (final progress in speedTestStream()) {
      latest = progress;
    }
    if (latest == null) {
      throw const HttpException('Speed test did not return a result.');
    }
    return latest.toResult();
  }

  @override
  Stream<SpeedProgress> speedTestStream() async* {
    final pings = <int>[];
    for (var i = 0; i < 3; i++) {
      final latency = await _measureBackendLatencySafe();
      if (latency != null) pings.add(latency);
      if (pings.isEmpty) {
        yield const SpeedProgress(phase: SpeedTestPhase.ping);
        continue;
      }
      final avgPing = pings.reduce((a, b) => a + b) / pings.length;
      final jitter = _jitter(pings, avgPing);
      yield SpeedProgress(
        phase: SpeedTestPhase.ping,
        pingMs: avgPing.round(),
        jitterMs: jitter.round(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    final avgPing =
        pings.isEmpty ? 0.0 : pings.reduce((a, b) => a + b) / pings.length;
    final jitter = pings.isEmpty ? 0.0 : _jitter(pings, avgPing);
    var download = 0.0;
    var upload = 0.0;

    await for (final value in _measureDownloadStream(bytes: 8 * 1024 * 1024)) {
      download = value;
      yield SpeedProgress(
        phase: SpeedTestPhase.download,
        downloadMbps: download,
        pingMs: avgPing.round(),
        jitterMs: jitter.round(),
      );
    }

    await for (final value in _measureUploadStream(bytes: 4 * 1024 * 1024)) {
      upload = value;
      yield SpeedProgress(
        phase: SpeedTestPhase.upload,
        downloadMbps: download,
        uploadMbps: upload,
        pingMs: avgPing.round(),
        jitterMs: jitter.round(),
      );
    }

    yield SpeedProgress(
      phase: SpeedTestPhase.complete,
      downloadMbps: download,
      uploadMbps: upload,
      pingMs: avgPing.round(),
      jitterMs: jitter.round(),
    );
  }

  @override
  Future<NetworkInfo> networkInfo() async {
    final connectivity = await Connectivity().checkConnectivity();
    final interfaces = await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );
    final localIp = interfaces
        .expand((interface) => interface.addresses)
        .map((address) => address.address)
        .firstWhere((address) => !address.startsWith('127.'),
            orElse: () => '-');
    final publicIp = await _getText(Uri.parse('https://api.ipify.org'))
        .timeout(const Duration(seconds: 6), onTimeout: () => '-');
    final backendStatus = await _getJson(_uri('/health'))
        .then((_) => 'Connected')
        .timeout(const Duration(seconds: 4), onTimeout: () => 'Unreachable')
        .catchError((Object _) => 'Unreachable');

    return NetworkInfo(
      localIp: localIp,
      publicIp: publicIp.trim().isEmpty ? '-' : publicIp.trim(),
      dns: 'System resolver',
      gateway: 'Provided by OS',
      networkType: _networkType(connectivity),
      signal: 'OS managed',
      subnetMask: 'Provided by OS',
      backendStatus: backendStatus,
    );
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return _baseUri.replace(
      path: path,
      queryParameters: query,
    );
  }

  Stream<Map<String, dynamic>> _readNdjson(Uri uri) async* {
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/x-ndjson');
    final response = await request.close().timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.transform(utf8.decoder).join();
      throw HttpException(_extractError(body), uri: uri);
    }

    var buffer = '';
    await for (final chunk in response.transform(utf8.decoder)) {
      buffer += chunk;
      while (buffer.contains('\n')) {
        final index = buffer.indexOf('\n');
        final line = buffer.substring(0, index).trim();
        buffer = buffer.substring(index + 1);
        if (line.isEmpty) continue;
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          if (decoded['error'] != null) {
            throw HttpException(decoded['error'].toString(), uri: uri);
          }
          yield decoded;
        }
      }
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final request = await _client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(_extractError(body), uri: uri);
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Unexpected JSON response');
  }

  Future<String> _getText(Uri uri) async {
    final request = await _client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Request failed', uri: uri);
    }
    return response.transform(utf8.decoder).join();
  }

  Future<int> _measureBackendLatency() async {
    final started = DateTime.now();
    await _getJson(_uri('/health')).timeout(const Duration(seconds: 8));
    return DateTime.now().difference(started).inMilliseconds;
  }

  Future<int?> _measureBackendLatencySafe() async {
    try {
      return await _measureBackendLatency();
    } catch (_) {
      return null;
    }
  }

  Stream<double> _measureDownloadStream({required int bytes}) async* {
    final request = await _client.getUrl(_uri('/api/speed/download', {
      'bytes': '$bytes',
    }));
    final started = DateTime.now();
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const HttpException('Download speed test failed');
    }
    var received = 0;
    await for (final chunk in response) {
      received += chunk.length;
      yield _mbps(received, DateTime.now().difference(started));
    }
  }

  Stream<double> _measureUploadStream({required int bytes}) async* {
    final payload = Uint8List(bytes);
    for (var i = 0; i < payload.length; i++) {
      payload[i] = i % 251;
    }
    final request = await _client.postUrl(_uri('/api/speed/upload'));
    request.headers.contentType = ContentType.binary;
    request.headers.contentLength = payload.length;
    final started = DateTime.now();
    const chunkSize = 64 * 1024;
    var sent = 0;
    while (sent < payload.length) {
      var end = sent + chunkSize;
      if (end > payload.length) end = payload.length;
      request.add(payload.sublist(sent, end));
      sent = end;
      yield _mbps(sent, DateTime.now().difference(started));
      await Future<void>.delayed(Duration.zero);
    }
    final response = await request.close().timeout(const Duration(seconds: 20));
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(_extractError(body));
    }
    yield _mbps(bytes, DateTime.now().difference(started));
  }

  double _mbps(int bytes, Duration elapsed) {
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) return 0;
    return (bytes * 8) / seconds / 1000000;
  }

  double _jitter(List<int> pings, double avgPing) {
    if (pings.isEmpty) return 0;
    return pings.map((ping) => (ping - avgPing).abs()).reduce((a, b) => a + b) /
        pings.length;
  }

  void _validateHost(String host) {
    if (host.trim().isEmpty) {
      throw ArgumentError('Enter an IP address or domain.');
    }
    if (host.contains(' ')) {
      throw ArgumentError('Host cannot contain spaces.');
    }
  }

  int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] != null) {
        return decoded['error'].toString();
      }
    } catch (_) {
      return body.isEmpty ? 'Network request failed.' : body;
    }
    return 'Network request failed.';
  }

  String _networkType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
    if (results.contains(ConnectivityResult.mobile)) return 'Mobile';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    return 'Unknown';
  }
}
