const http = require('http');
const net = require('net');
const os = require('os');
const { spawn } = require('child_process');

const PORT = Number(process.env.PORT || 8787);
const MAX_SPEED_BYTES = 128 * 1024 * 1024;
const HOST_PATTERN = /^[a-zA-Z0-9.-]{1,253}$/;
const PING_MODE = process.env.PINGFLOW_PING_MODE || 'auto';

function json(res, status, payload) {
  if (res.headersSent) {
    if (!res.writableEnded) res.end();
    return;
  }
  const body = JSON.stringify(payload);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
    'Access-Control-Allow-Origin': '*',
  });
  res.end(body);
}

function ndjsonHeaders(res) {
  res.writeHead(200, {
    'Content-Type': 'application/x-ndjson; charset=utf-8',
    'Cache-Control': 'no-cache',
    Connection: 'keep-alive',
    'Access-Control-Allow-Origin': '*',
  });
}

function parseUrl(req) {
  return new URL(req.url, `http://${req.headers.host || 'localhost'}`);
}

function validateHost(host) {
  if (!host || typeof host !== 'string') {
    throw new Error('Host is required.');
  }
  if (!HOST_PATTERN.test(host) || host.includes('..') || host.startsWith('.') || host.endsWith('.')) {
    throw new Error('Host must be a valid domain or IPv4 address.');
  }
  return host;
}

function writeEvent(res, payload) {
  if (res.writableEnded) return;
  res.write(`${JSON.stringify(payload)}\n`);
}

function endResponse(res) {
  if (!res.writableEnded) res.end();
}

function spawnDiagnostic(command, args, onLine, onClose, onError) {
  let child;
  try {
    child = spawn(command, args, { windowsHide: true });
  } catch (error) {
    onError(error.message);
    setImmediate(onClose);
    return null;
  }
  let buffer = '';

  child.stdout.on('data', (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split(/\r?\n/);
    buffer = lines.pop() || '';
    for (const line of lines) onLine(line);
  });

  child.stderr.on('data', (chunk) => {
    const text = chunk.toString().trim();
    if (text) onError(text);
  });

  child.on('error', (error) => onError(error.message));
  child.on('close', () => {
    if (buffer.trim()) onLine(buffer);
    onClose();
  });

  return child;
}

function pingArgs(host, count) {
  if (process.platform === 'win32') {
    return { command: 'ping', args: ['-n', String(count), '-w', '3000', host] };
  }
  return { command: 'ping', args: ['-c', String(count), '-W', '3', host] };
}

function parsePingLine(line, sequence, host) {
  const lower = line.toLowerCase();
  if (lower.includes('timed out') || lower.includes('100% packet loss')) {
    return { sequence, host, latencyMs: 0, ttl: 0, success: false };
  }

  const timeMatch = line.match(/time[=<]\s*(\d+(?:\.\d+)?)\s*ms/i);
  if (!timeMatch) return null;

  const ttlMatch = line.match(/ttl[=\s](\d+)/i);
  const fromMatch = line.match(/from\s+([^\s:]+)/i) || line.match(/reply from\s+([^\s:]+)/i);
  return {
    sequence,
    host: fromMatch ? fromMatch[1] : host,
    latencyMs: Math.max(1, Math.round(Number(timeMatch[1]))),
    ttl: ttlMatch ? Number(ttlMatch[1]) : 0,
    success: true,
  };
}

function tcpProbe(host, port, timeoutMs = 3000) {
  return new Promise((resolve) => {
    const started = process.hrtime.bigint();
    const socket = net.createConnection({ host, port });
    let settled = false;

    function done(success) {
      if (settled) return;
      settled = true;
      socket.destroy();
      const elapsedMs = Number(process.hrtime.bigint() - started) / 1e6;
      resolve(success ? Math.max(1, Math.round(elapsedMs)) : 0);
    }

    socket.setTimeout(timeoutMs);
    socket.once('connect', () => done(true));
    socket.once('timeout', () => done(false));
    socket.once('error', () => done(false));
  });
}

async function tcpPingFallback(host, count, writeResult, shouldStop) {
  for (let sequence = 1; sequence <= count; sequence += 1) {
    if (shouldStop()) return;
    let latencyMs = await tcpProbe(host, 443);
    if (!latencyMs) latencyMs = await tcpProbe(host, 80);
    writeResult({
      sequence,
      host,
      latencyMs,
      ttl: 0,
      success: latencyMs > 0,
      mode: 'tcp',
    });
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
}

function handlePingStream(req, res, url) {
  let host;
  try {
    host = validateHost(url.searchParams.get('host'));
  } catch (error) {
    return json(res, 400, { error: error.message });
  }

  const count = Math.min(Math.max(Number(url.searchParams.get('count') || 10), 1), 30);
  const diagnostic = pingArgs(host, count);
  ndjsonHeaders(res);

  let sequence = 0;
  let reported = 0;
  let closed = false;
  let diagnosticError = '';

  function attachCloseHandler(child) {
    res.on('close', () => {
      if (res.writableEnded) return;
      closed = true;
      if (child) child.kill();
    });
  }

  if (PING_MODE === 'tcp') {
    tcpPingFallback(
      host,
      count,
      (event) => {
        reported += 1;
        writeEvent(res, event);
      },
      () => closed,
    )
      .catch((error) => writeEvent(res, { error: error.message }))
      .finally(() => endResponse(res));
    attachCloseHandler(null);
    return;
  }

  const child = spawnDiagnostic(
    diagnostic.command,
    diagnostic.args,
    (line) => {
      const maybeNext = /time[=<]|\btimed out\b|100% packet loss/i.test(line);
      if (maybeNext) sequence += 1;
      const event = parsePingLine(line, sequence, host);
      if (event && reported < count) {
        reported += 1;
        writeEvent(res, event);
      }
    },
    async () => {
      if (closed) return;
      if (reported === 0) {
        await tcpPingFallback(
          host,
          count,
          (event) => {
            reported += 1;
            writeEvent(res, event);
          },
          () => closed,
        );
      }
      if (reported === 0 && diagnosticError) {
        writeEvent(res, { error: diagnosticError });
      }
      endResponse(res);
    },
    (error) => {
      diagnosticError = error;
    },
  );

  attachCloseHandler(child);
}

function tracerouteArgs(host) {
  if (process.platform === 'win32') {
    return { command: 'tracert', args: ['-d', '-h', '30', '-w', '3000', host] };
  }
  return { command: 'traceroute', args: ['-n', '-m', '30', '-w', '3', host] };
}

function parseTraceLine(line) {
  const trimmed = line.trim();
  const numberMatch = trimmed.match(/^(\d+)\s+/);
  if (!numberMatch) return null;

  const number = Number(numberMatch[1]);
  const latencies = [...trimmed.matchAll(/(<\s*1|\d+(?:\.\d+)?)\s*ms/gi)]
    .map((match) => (match[1].includes('<') ? 1 : Number(match[1])));
  const latencyMs = latencies.length
    ? Math.round(latencies.reduce((sum, item) => sum + item, 0) / latencies.length)
    : 0;
  const ipMatches = [...trimmed.matchAll(/\b(?:\d{1,3}\.){3}\d{1,3}\b/g)];
  const ip = ipMatches.length ? ipMatches[ipMatches.length - 1][0] : '*';

  return { number, ip, latencyMs };
}

function handleTracerouteStream(req, res, url) {
  let host;
  try {
    host = validateHost(url.searchParams.get('host'));
  } catch (error) {
    return json(res, 400, { error: error.message });
  }

  const diagnostic = tracerouteArgs(host);
  ndjsonHeaders(res);
  let closed = false;

  const child = spawnDiagnostic(
    diagnostic.command,
    diagnostic.args,
    (line) => {
      const event = parseTraceLine(line);
      if (event) writeEvent(res, event);
    },
    () => {
      if (!closed) endResponse(res);
    },
    (error) => {
      writeEvent(res, { error });
    },
  );

  res.on('close', () => {
    if (res.writableEnded) return;
    closed = true;
    if (child) child.kill();
  });
}

function handleDownload(res, url) {
  const requested = Number(url.searchParams.get('bytes') || 8 * 1024 * 1024);
  const total = Math.min(Math.max(requested, 1024), MAX_SPEED_BYTES);
  const chunk = Buffer.alloc(64 * 1024, 7);
  let sent = 0;

  res.writeHead(200, {
    'Content-Type': 'application/octet-stream',
    'Content-Length': total,
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*',
  });

  function writeMore() {
    while (sent < total) {
      const remaining = total - sent;
      const slice = remaining >= chunk.length ? chunk : chunk.subarray(0, remaining);
      sent += slice.length;
      if (!res.write(slice)) {
        res.once('drain', writeMore);
        return;
      }
    }
    res.end();
  }

  writeMore();
}

function handleUpload(req, res) {
  let received = 0;
  let rejected = false;
  const started = process.hrtime.bigint();

  req.on('data', (chunk) => {
    if (rejected) return;
    received += chunk.length;
    if (received > MAX_SPEED_BYTES) {
      rejected = true;
      json(res, 413, { error: 'Upload payload is too large.' });
      req.destroy();
    }
  });

  req.on('end', () => {
    if (rejected || res.headersSent) return;
    const elapsedSeconds = Number(process.hrtime.bigint() - started) / 1e9;
    const mbps = elapsedSeconds > 0 ? (received * 8) / elapsedSeconds / 1000000 : 0;
    json(res, 200, { receivedBytes: received, mbps });
  });
}

function networkInterfaces() {
  return Object.entries(os.networkInterfaces())
    .flatMap(([name, entries]) => (entries || []).map((entry) => ({ name, ...entry })))
    .filter((entry) => entry.family === 'IPv4' && !entry.internal)
    .map((entry) => ({ name: entry.name, address: entry.address, mac: entry.mac }));
}

const server = http.createServer((req, res) => {
  const url = parseUrl(req);

  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
    return res.end();
  }

  try {
    if (req.method === 'GET' && url.pathname === '/health') {
      return json(res, 200, { status: 'ok', platform: process.platform });
    }
    if (req.method === 'GET' && url.pathname === '/api/network-info') {
      return json(res, 200, { interfaces: networkInterfaces() });
    }
    if (req.method === 'GET' && url.pathname === '/api/ping/stream') {
      return handlePingStream(req, res, url);
    }
    if (req.method === 'GET' && url.pathname === '/api/traceroute/stream') {
      return handleTracerouteStream(req, res, url);
    }
    if (req.method === 'GET' && url.pathname === '/api/speed/download') {
      return handleDownload(res, url);
    }
    if (req.method === 'POST' && url.pathname === '/api/speed/upload') {
      return handleUpload(req, res);
    }
    return json(res, 404, { error: 'Endpoint not found.' });
  } catch (error) {
    if (res.headersSent) {
      return endResponse(res);
    }
    return json(res, 500, { error: error.message || 'Internal server error.' });
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`PingFlow backend listening on http://0.0.0.0:${PORT}`);
});
