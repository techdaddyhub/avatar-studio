import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ObsWebSocketClient {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  int _requestIdCounter = 1;
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};

  bool get isConnected => _isConnected;

  Future<bool> connect({
    required String host,
    required int port,
    String? password,
  }) async {
    await disconnect();

    try {
      final uri = Uri.parse('ws://$host:$port');
      _channel = WebSocketChannel.connect(uri);

      // Listen for OBS WebSocket v5 hello/identified frames
      final completer = Completer<bool>();

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final op = json['op'] as int?;

            if (op == 0) {
              // OpCode 0: Hello from OBS Studio
              // Send OpCode 1: Identify
              _channel?.sink.add(
                jsonEncode({
                  'op': 1,
                  'd': {'rpcVersion': 1},
                }),
              );
            } else if (op == 2) {
              // OpCode 2: Identified! Successfully connected to OBS
              _isConnected = true;
              if (!completer.isCompleted) completer.complete(true);
            } else if (op == 7) {
              // OpCode 7: RequestResponse
              final d = json['d'] as Map<String, dynamic>?;
              final reqId = d?['requestId'] as String?;
              if (reqId != null && _pendingRequests.containsKey(reqId)) {
                _pendingRequests.remove(reqId)!.complete(d ?? {});
              }
            }
          } catch (_) {}
        },
        onDone: () {
          _isConnected = false;
          if (!completer.isCompleted) completer.complete(false);
        },
        onError: (_) {
          _isConnected = false;
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      // Wait up to 3 seconds for OBS handshake
      return await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
    } catch (_) {
      _isConnected = false;
      return false;
    }
  }

  Future<Map<String, dynamic>?> sendRequest(
    String requestType, [
    Map<String, dynamic>? requestData,
  ]) async {
    if (!_isConnected || _channel == null) return null;

    final reqId = 'req_${_requestIdCounter++}';
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[reqId] = completer;

    final message = jsonEncode({
      'op': 6, // Request
      'd': {
        'requestType': requestType,
        'requestId': reqId,
        'requestData': ?requestData,
      },
    });

    _channel!.sink.add(message);

    try {
      return await completer.future.timeout(const Duration(seconds: 4));
    } catch (_) {
      _pendingRequests.remove(reqId);
      return null;
    }
  }

  Future<List<String>> getSceneList() async {
    final response = await sendRequest('GetSceneList');
    if (response != null && response['responseData'] != null) {
      final data = response['responseData'] as Map<String, dynamic>;
      final scenes = data['scenes'] as List<dynamic>?;
      if (scenes != null) {
        return scenes
            .map((s) => (s as Map<String, dynamic>)['sceneName'] as String)
            .toList();
      }
    }
    return [];
  }

  Future<bool> toggleVirtualCam() async {
    final response = await sendRequest('ToggleVirtualCam');
    return response != null;
  }

  Future<void> disconnect() async {
    _isConnected = false;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _pendingRequests.clear();
  }
}
