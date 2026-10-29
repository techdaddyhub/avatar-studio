import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/avatar_model.dart';
import '../../models/tracking_state.dart';
import '../../models/audio_sync_state.dart';

class ObsHttpServer {
  HttpServer? _server;
  final Set<WebSocketChannel> _connectedSockets = {};
  Timer? _broadcastTimer;

  bool get isRunning => _server != null;
  int get port => _server?.port ?? 8088;
  int get clientCount => _connectedSockets.length;

  Future<bool> start({
    int port = 8088,
    required AvatarModel Function() getAvatar,
    required TrackingState Function() getTracking,
    required AudioSyncState Function() getAudio,
    required bool Function() getIsTransparent,
    required Function(int) onClientCountChanged,
  }) async {
    await stop();

    try {
      final router = Router();

      // WebSocket Handler
      final wsHandler = webSocketHandler((
        WebSocketChannel channel,
        String? protocol,
      ) {
        _connectedSockets.add(channel);
        onClientCountChanged(_connectedSockets.length);

        channel.stream.listen(
          (message) {},
          onDone: () {
            _connectedSockets.remove(channel);
            onClientCountChanged(_connectedSockets.length);
          },
          onError: (_) {
            _connectedSockets.remove(channel);
            onClientCountChanged(_connectedSockets.length);
          },
        );
      });

      router.get('/ws', wsHandler);

      // Main OBS Browser Source page
      router.get('/avatar', (Request request) {
        return Response.ok(
          _generateObsHtmlPage(),
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      });

      router.get('/obs-source', (Request request) {
        return Response.ok(
          _generateObsHtmlPage(),
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      });

      // Test Pattern generator
      router.get('/test-pattern', (Request request) {
        return Response.ok(
          _generateTestPatternHtmlPage(),
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      });

      // Paystack billing redirect callback
      router.get('/billing/paystack-callback', (Request request) {
        final ref = request.url.queryParameters['reference'] ?? '';
        return Response.ok(
          _generateBillingSuccessHtmlPage('Paystack', ref),
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      });

      // NOWPayments crypto redirect callback
      router.get('/billing/nowpayments-callback', (Request request) {
        final paymentId = request.url.queryParameters['payment_id'] ?? '';
        return Response.ok(
          _generateBillingSuccessHtmlPage('NOWPayments Crypto', paymentId),
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      });

      // Serve active custom avatar asset file (portrait image or 3D asset)
      router.get('/avatar-asset', (Request request) async {
        final avatar = getAvatar();
        if (avatar.filePath != null) {
          final file = File(avatar.filePath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final ext = p.extension(avatar.filePath!).toLowerCase();
            String mime = 'application/octet-stream';
            if (ext == '.png') mime = 'image/png';
            if (ext == '.jpg' || ext == '.jpeg') mime = 'image/jpeg';
            if (ext == '.webp') mime = 'image/webp';
            if (ext == '.glb') mime = 'model/gltf-binary';
            return Response.ok(
              bytes,
              headers: {
                'content-type': mime,
                'access-control-allow-origin': '*',
                'cache-control': 'no-cache',
              },
            );
          }
        }
        return Response.notFound('No custom asset found');
      });

      // Health status API
      router.get('/status', (Request request) {
        final data = {
          'status': 'healthy',
          'server': 'Avatar Studio OBS Engine',
          'clients': _connectedSockets.length,
          'uptimeSeconds': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };
        return Response.ok(
          jsonEncode(data),
          headers: {'content-type': 'application/json'},
        );
      });

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

      // Start high-frequency 60 FPS broadcast timer to connected OBS Browser Sources
      _broadcastTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (_connectedSockets.isEmpty) return;

        final avatar = getAvatar();
        final tracking = getTracking();
        final audio = getAudio();
        final isTransparent = getIsTransparent();

        final frameData = jsonEncode({
          'type': 'frame',
          'isTransparent': isTransparent,
          'avatar': {
            'name': avatar.name,
            'type': avatar.type.name,
            'isCustom': avatar.isCustom,
            'hasAsset': avatar.filePath != null,
            'assetUrl': '/avatar-asset',
            'styleId': avatar.styleId,
            'skinTone':
                '#${avatar.skinTone.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
            'eyeColor':
                '#${avatar.eyeColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
            'hairColor':
                '#${avatar.hairColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
            'clothingColor':
                '#${avatar.clothingColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
            'scale': avatar.scale,
            'offsetY': avatar.offsetY,
          },
          'tracking': tracking.toJson(),
          'audio': audio.toJson(),
        });

        for (final socket in _connectedSockets.toList()) {
          try {
            socket.sink.add(frameData);
          } catch (_) {
            _connectedSockets.remove(socket);
            onClientCountChanged(_connectedSockets.length);
          }
        }
      });

      return true;
    } catch (e) {
      _server = null;
      return false;
    }
  }

  Future<void> stop() async {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;

    for (final socket in _connectedSockets) {
      try {
        await socket.sink.close();
      } catch (_) {}
    }
    _connectedSockets.clear();

    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
  }

  static String _generateObsHtmlPage() {
    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>TD-Avatar-Studio — OBS Transparent Source</title>
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: transparent !important;
    }
    canvas {
      display: block;
      width: 100%;
      height: 100%;
      background-color: transparent !important;
    }
    #statusOverlay {
      position: absolute;
      top: 10px;
      left: 10px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      font-size: 11px;
      color: rgba(255, 255, 255, 0.4);
      pointer-events: none;
    }
  </style>
</head>
<body>
  <div id="statusOverlay">OBS Source: Connected (Alpha Transparent)</div>
  <canvas id="c"></canvas>

  <script>
    const canvas = document.getElementById('c');
    const ctx = canvas.getContext('2d', { alpha: true });
    let frame = null;
    let customImg = null;
    let customImgUrl = '';

    function resize() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }
    window.addEventListener('resize', resize);
    resize();

    let ws;
    function connect() {
      const loc = window.location;
      const wsUrl = (loc.protocol === 'https:' ? 'wss://' : 'ws://') + loc.host + '/ws';
      ws = new WebSocket(wsUrl);

      ws.onmessage = (e) => {
        try {
          frame = JSON.parse(e.data);
          draw();
        } catch (_) {}
      };

      ws.onclose = () => {
        document.getElementById('statusOverlay').innerText = 'OBS Source: Reconnecting...';
        setTimeout(connect, 1000);
      };

      ws.onopen = () => {
        document.getElementById('statusOverlay').innerText = '';
      };
    }
    connect();

    function draw() {
      if (!frame) return;
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const cx = canvas.width / 2;
      const cy = (canvas.height / 2) + ((frame.avatar.offsetY || 0) * 100);
      const scale = frame.avatar.scale || 1.0;

      const tracking = frame.tracking || {};
      const audio = frame.audio || {};
      const pitch = tracking.pitch || 0;
      const yaw = tracking.yaw || 0;
      const roll = tracking.roll || 0;

      const mouthOpen = Math.max(tracking.mouthOpen || 0, audio.isVoiceActive ? (audio.mouthOpenAmount || 0) : 0);
      const smile = tracking.smile || 0;

      function drawHand(ctx, x, y, skin, isLeft, phase, elev) {
        if (elev < 0.05) return;
        ctx.save();
        ctx.translate(x, y);
        ctx.rotate(isLeft ? 0.25 + Math.sin(phase)*0.15 : -0.25 - Math.sin(phase)*0.15);
        ctx.fillStyle = skin;
        // Palm
        ctx.beginPath();
        ctx.roundRect(-22, -16, 44, 56, 14);
        ctx.fill();
        // Fingers
        const fConfigs = [
          { x: isLeft ? 11 : -11, len: 34, w: 9.5 },
          { x: isLeft ? 3.5 : -3.5, len: 40, w: 10 },
          { x: isLeft ? -4.5 : 4.5, len: 36, w: 9.5 },
          { x: isLeft ? -12 : 12, len: 28, w: 8.5 },
        ];
        for (const cfg of fConfigs) {
          ctx.beginPath();
          ctx.roundRect(cfg.x - cfg.w/2, -16 - cfg.len, cfg.w, cfg.len + 5, cfg.w/2);
          ctx.fill();
        }
        // Thumb
        ctx.save();
        ctx.translate(isLeft ? 18 : -18, 6);
        ctx.rotate(isLeft ? 0.65 : -0.65);
        ctx.beginPath();
        ctx.roundRect(-7, -24, 14, 26, 7);
        ctx.fill();
        ctx.restore();
        ctx.restore();
      }

      // If user uploaded a custom portrait image, render it live with transparency
      if (frame.avatar.hasAsset && frame.avatar.type === 'customPortrait') {
        if (customImgUrl !== frame.avatar.assetUrl) {
          customImgUrl = frame.avatar.assetUrl;
          customImg = new Image();
          customImg.src = frame.avatar.assetUrl;
        }
        if (customImg && customImg.complete && customImg.naturalWidth > 0) {
          ctx.save();
          ctx.translate(cx, cy);
          ctx.scale(scale, scale);
          ctx.rotate(roll * 0.35);

          const w = 310;
          const h = 420;
          const jawScale = 1.0 + (mouthOpen * 0.04);

          ctx.save();
          ctx.scale(1.0, jawScale);
          ctx.drawImage(customImg, -w/2 + (yaw * 15), -h/2 + (pitch * 15), w, h);
          ctx.restore();

          // Conversational Hands for Custom Portrait in OBS
          const isSpeaking = audio.isVoiceActive || mouthOpen > 0.08;
          const elev = isSpeaking ? Math.min(1.0, 0.6 + mouthOpen * 0.5) : 0.0;
          const timeSec = Date.now() / 1000;
          const leftPhase = timeSec * 2.8;
          const rightPhase = timeSec * 2.5 + 1.2;
          const skin = frame.avatar.skinTone || '#C68662';

          const leftHandX = -w * 0.28 + Math.sin(leftPhase) * (elev * 25);
          const leftHandY = h / 2 - 30 - (elev * 140);
          drawHand(ctx, leftHandX, leftHandY, skin, true, leftPhase, elev);

          const rightHandX = w * 0.28 + Math.sin(rightPhase) * (elev * 27);
          const rightHandY = h / 2 - 30 - (elev * 135);
          drawHand(ctx, rightHandX, rightHandY, skin, false, rightPhase, elev);

          ctx.restore();
          return;
        }
      }

      ctx.save();
      ctx.translate(cx, cy);
      ctx.scale(scale, scale);
      ctx.rotate(roll * 0.4);

      // Torso
      ctx.fillStyle = frame.avatar.clothingColor || '#1E293B';
      ctx.beginPath();
      const torsoW = 260;
      const torsoTop = 130 + (pitch * 8);
      const torsoBottom = 340;
      ctx.moveTo(-torsoW/2 + (yaw * 15), torsoBottom);
      ctx.quadraticCurveTo(-torsoW * 0.45, torsoTop + 20, -70 + (yaw * 20), torsoTop);
      ctx.lineTo(70 + (yaw * 20), torsoTop);
      ctx.quadraticCurveTo(torsoW * 0.45, torsoTop + 20, torsoW/2 + (yaw * 15), torsoBottom);
      ctx.closePath();
      ctx.fill();

      // Neck
      ctx.fillStyle = frame.avatar.skinTone || '#F5D0B5';
      ctx.beginPath();
      ctx.roundRect((yaw * 15) - 32, 45 + (pitch * 10), 65, 90, 20);
      ctx.fill();

      // Head
      const hx = yaw * 25;
      const hy = -15 + (pitch * 20);

      // Hair Back
      ctx.fillStyle = frame.avatar.hairColor || '#263238';
      ctx.beginPath();
      ctx.ellipse(hx, hy - 15, 105, 125, 0, 0, Math.PI * 2);
      ctx.fill();

      // Face
      ctx.fillStyle = frame.avatar.skinTone || '#F5D0B5';
      ctx.beginPath();
      ctx.ellipse(hx, hy, 82, 105, 0, 0, Math.PI * 2);
      ctx.fill();

      // Eyes
      const eyeSpacing = 42;
      const eyeY = hy - 10;
      const leftBlink = tracking.leftEyeBlink || 0;
      const rightBlink = tracking.rightEyeBlink || 0;

      // Draw eyes
      [ { x: hx - eyeSpacing, blink: leftBlink }, { x: hx + eyeSpacing, blink: rightBlink } ].forEach(e => {
        const eyeH = Math.max(2, (1 - e.blink) * 18);
        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        ctx.ellipse(e.x, eyeY, 17, eyeH / 2, 0, 0, Math.PI * 2);
        ctx.fill();

        if (eyeH > 4) {
          ctx.save();
          ctx.beginPath();
          ctx.ellipse(e.x, eyeY, 17, eyeH / 2, 0, 0, Math.PI * 2);
          ctx.clip();

          // Iris
          ctx.fillStyle = frame.avatar.eyeColor || '#0091EA';
          ctx.beginPath();
          ctx.arc(e.x + (yaw * 6), eyeY + (pitch * 4), 9, 0, Math.PI * 2);
          ctx.fill();

          // Pupil
          ctx.fillStyle = '#111827';
          ctx.beginPath();
          ctx.arc(e.x + (yaw * 6), eyeY + (pitch * 4), 4.5, 0, Math.PI * 2);
          ctx.fill();

          // Specular
          ctx.fillStyle = '#FFFFFF';
          ctx.beginPath();
          ctx.arc(e.x + (yaw * 6) - 2.5, eyeY + (pitch * 4) - 2.5, 2, 0, Math.PI * 2);
          ctx.fill();

          ctx.restore();
        }
      });

      // Eyebrows
      ctx.strokeStyle = frame.avatar.hairColor || '#263238';
      ctx.lineWidth = 3.5;
      ctx.lineCap = 'round';
      const browY = hy - 25 - ((tracking.browRaise || 0) * 8);

      ctx.beginPath();
      ctx.moveTo(hx - 58, browY + 2);
      ctx.quadraticCurveTo(hx - 40, browY - 3, hx - 22, browY + 3);
      ctx.stroke();

      ctx.beginPath();
      ctx.moveTo(hx + 22, browY + 3);
      ctx.quadraticCurveTo(hx + 40, browY - 3, hx + 58, browY + 2);
      ctx.stroke();

      // Nose
      ctx.strokeStyle = 'rgba(0, 0, 0, 0.2)';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(hx + (yaw * 5) - 2, hy + 12);
      ctx.lineTo(hx + (yaw * 5) + 3, hy + 22);
      ctx.lineTo(hx + (yaw * 5) - 4, hy + 24);
      ctx.stroke();

      // Mouth
      const mouthX = hx + (yaw * 5);
      const mouthY = hy + 54 + (pitch * 4);
      const mouthW = 42 + (smile * 12);
      const mouthH = Math.max(3, mouthOpen * 30);

      if (mouthH > 6) {
        ctx.fillStyle = '#4A121A';
        ctx.beginPath();
        ctx.roundRect(mouthX - (mouthW / 2), mouthY - (mouthH / 2), mouthW, mouthH, mouthH / 2);
        ctx.fill();

        // Teeth
        ctx.fillStyle = '#F8FAFC';
        ctx.beginPath();
        ctx.roundRect(mouthX - (mouthW * 0.35), mouthY - (mouthH / 2), mouthW * 0.7, Math.min(5, mouthH * 0.35), 2);
        ctx.fill();
      }

      // Lips
      ctx.strokeStyle = 'rgba(0, 0, 0, 0.35)';
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(mouthX - (mouthW / 2), mouthY);
      ctx.quadraticCurveTo(mouthX, mouthY + (smile * 8) - (mouthH * 0.2), mouthX + (mouthW / 2), mouthY);
      ctx.stroke();

      // Hair Front Bangs
      ctx.fillStyle = frame.avatar.hairColor || '#263238';
      ctx.beginPath();
      ctx.moveTo(hx - 80, hy - 65);
      ctx.quadraticCurveTo(hx - 20, hy - 40, hx + 10, hy - 50);
      ctx.quadraticCurveTo(hx + 50, hy - 60, hx + 85, hy - 45);
      ctx.quadraticCurveTo(hx + 95, hy - 95, hx, hy - 110);
      ctx.quadraticCurveTo(hx - 95, hy - 95, hx - 80, hy - 65);
      ctx.fill();

      // Conversational Hands for Procedural Avatar in OBS
      const isSpeakingP = audio.isVoiceActive || mouthOpen > 0.08;
      const elevP = isSpeakingP ? Math.min(1.0, 0.6 + mouthOpen * 0.5) : 0.0;
      const timeSecP = Date.now() / 1000;
      const leftPhaseP = timeSecP * 2.8;
      const rightPhaseP = timeSecP * 2.5 + 1.2;
      const skinP = frame.avatar.skinTone || '#F5D0B5';

      const leftHandXP = -85 + Math.sin(leftPhaseP) * (elevP * 25);
      const leftHandYP = 220 - (elevP * 140);
      drawHand(ctx, leftHandXP, leftHandYP, skinP, true, leftPhaseP, elevP);

      const rightHandXP = 85 + Math.sin(rightPhaseP) * (elevP * 27);
      const rightHandYP = 220 - (elevP * 135);
      drawHand(ctx, rightHandXP, rightHandYP, skinP, false, rightPhaseP, elevP);

      ctx.restore();
    }
  </script>
</body>
</html>''';
  }

  static String _generateTestPatternHtmlPage() {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Avatar Studio — OBS Test Pattern</title>
  <style>
    body { margin: 0; overflow: hidden; background: #000; font-family: monospace; }
    canvas { display: block; width: 100vw; height: 100vh; }
  </style>
</head>
<body>
  <canvas id="c"></canvas>
  <script>
    const canvas = document.getElementById('c');
    const ctx = canvas.getContext('2d');
    canvas.width = 1920; canvas.height = 1080;

    const colors = ['#FFFFFF', '#FFFF00', '#00FFFF', '#00FF00', '#FF00FF', '#FF0000', '#0000FF'];
    const barW = canvas.width / colors.length;

    colors.forEach((c, i) => {
      ctx.fillStyle = c;
      ctx.fillRect(i * barW, 0, barW, canvas.height * 0.7);
    });

    // Transparency Check Grid
    const gridTop = canvas.height * 0.7;
    const gridH = canvas.height * 0.3;
    const sz = 40;
    for (let x = 0; x < canvas.width; x += sz) {
      for (let y = gridTop; y < canvas.height; y += sz) {
        ctx.fillStyle = ((Math.floor(x / sz) + Math.floor(y / sz)) % 2 === 0) ? '#333' : '#666';
        ctx.fillRect(x, y, sz, sz);
      }
    }

    ctx.fillStyle = '#00E5FF';
    ctx.font = 'bold 36px monospace';
    ctx.fillText('AVATAR STUDIO — OBS CALIBRATION PATTERN 1080p 60FPS', 80, canvas.height - 60);
  </script>
</body>
</html>''';
  }

  static String _generateBillingSuccessHtmlPage(String gateway, String ref) {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Payment Successful — Avatar Studio</title>
  <style>
    body {
      background: #090D16;
      color: #F0F4FC;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .box {
      background: #151C30;
      border: 1px solid #2C395B;
      border-radius: 16px;
      padding: 40px;
      text-align: center;
      max-width: 450px;
      box-shadow: 0 10px 30px rgba(0, 229, 255, 0.1);
    }
    .icon {
      font-size: 56px;
      color: #00E676;
      margin-bottom: 16px;
    }
    h2 { margin: 0 0 12px 0; color: #00E5FF; }
    p { color: #A0AEC0; font-size: 14px; line-height: 1.5; margin: 0 0 20px 0; }
    .ref { font-family: monospace; font-size: 12px; color: #7928CA; background: #0E1322; padding: 6px 12px; border-radius: 6px; display: inline-block; }
  </style>
</head>
<body>
  <div class="box">
    <div class="icon">✓</div>
    <h2>Payment Authorized!</h2>
    <p>Your monthly subscription has been processed via \$gateway. You can now return to the Avatar Studio desktop app.</p>
    <div class="ref">Ref: \$ref</div>
  </div>
</body>
</html>''';
  }
}
