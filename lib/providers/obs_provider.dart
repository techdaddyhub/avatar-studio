import 'package:flutter/material.dart';
import '../models/obs_connection_state.dart';
import '../services/obs/obs_detector.dart';
import '../services/obs/obs_http_server.dart';
import '../services/obs/obs_websocket_client.dart';
import 'avatar_provider.dart';
import 'tracking_provider.dart';
import 'audio_sync_provider.dart';

class ObsProvider extends ChangeNotifier {
  final ObsHttpServer _httpServer = ObsHttpServer();
  final ObsWebSocketClient _wsClient = ObsWebSocketClient();

  ObsConnectionState _state = const ObsConnectionState();

  ObsProvider() {
    _checkObsInstallation();
  }

  ObsConnectionState get state => _state;
  bool get isServerRunning => _state.isHttpServerRunning;
  bool get isObsConnected => _state.isObsWebSocketConnected;

  Future<void> _checkObsInstallation() async {
    final installed = await ObsDetector.isObsInstalled();
    _state = _state.copyWith(isObsInstalled: installed);
    notifyListeners();
  }

  Future<bool> startServer({
    required AvatarProvider avatarProvider,
    required TrackingProvider trackingProvider,
    required AudioSyncProvider audioProvider,
  }) async {
    final success = await _httpServer.start(
      port: _state.serverPort,
      getAvatar: () => avatarProvider.activeAvatar,
      getTracking: () => trackingProvider.state,
      getAudio: () => audioProvider.state,
      getIsTransparent: () => _state.transparentBackground,
      onClientCountChanged: (count) {
        _state = _state.copyWith(connectedClients: count);
        notifyListeners();
      },
    );

    _state = _state.copyWith(
      isHttpServerRunning: success,
      serverUrl: 'http://127.0.0.1:${_state.serverPort}/avatar',
    );
    notifyListeners();
    return success;
  }

  Future<void> stopServer() async {
    await _httpServer.stop();
    _state = _state.copyWith(isHttpServerRunning: false, connectedClients: 0);
    notifyListeners();
  }

  void toggleServer({
    required AvatarProvider avatarProvider,
    required TrackingProvider trackingProvider,
    required AudioSyncProvider audioProvider,
  }) {
    if (_state.isHttpServerRunning) {
      stopServer();
    } else {
      startServer(
        avatarProvider: avatarProvider,
        trackingProvider: trackingProvider,
        audioProvider: audioProvider,
      );
    }
  }

  void setPort(int port) {
    _state = _state.copyWith(
      serverPort: port,
      serverUrl: 'http://127.0.0.1:$port/avatar',
    );
    notifyListeners();
  }

  void setTransparentBackground(bool value) {
    _state = _state.copyWith(transparentBackground: value);
    notifyListeners();
  }

  void setOutputResolution(String resolution) {
    _state = _state.copyWith(outputResolution: resolution);
    notifyListeners();
  }

  void setOutputFps(int fps) {
    _state = _state.copyWith(outputFps: fps);
    notifyListeners();
  }

  Future<bool> connectToObsWebSocket({
    String host = '127.0.0.1',
    int port = 4455,
    String? password,
  }) async {
    _state = _state.copyWith(obsHost: host, obsPort: port, lastError: null);
    notifyListeners();

    final connected = await _wsClient.connect(
      host: host,
      port: port,
      password: password,
    );
    if (connected) {
      final scenes = await _wsClient.getSceneList();
      _state = _state.copyWith(isObsWebSocketConnected: true, scenes: scenes);
    } else {
      _state = _state.copyWith(
        isObsWebSocketConnected: false,
        lastError:
            'Could not connect to OBS WebSocket v5 on ws://$host:$port. Ensure OBS is running and "Enable WebSocket Server" is checked in Tools > WebSocket Server Settings.',
      );
    }
    notifyListeners();
    return connected;
  }

  Future<void> disconnectObsWebSocket() async {
    await _wsClient.disconnect();
    _state = _state.copyWith(isObsWebSocketConnected: false);
    notifyListeners();
  }

  Future<void> toggleVirtualCam() async {
    if (!_state.isObsWebSocketConnected) return;
    final toggled = await _wsClient.toggleVirtualCam();
    if (toggled) {
      _state = _state.copyWith(isVirtualCamActive: !_state.isVirtualCamActive);
      notifyListeners();
    }
  }
}
