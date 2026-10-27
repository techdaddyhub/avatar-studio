class ObsConnectionState {
  final bool isHttpServerRunning;
  final int serverPort;
  final String serverUrl;
  final int connectedClients;
  final bool transparentBackground;
  final String outputResolution; // '1920x1080', '1280x720'
  final int outputFps; // 30 or 60

  // OBS WebSocket v5 Client state
  final bool isObsWebSocketConnected;
  final String obsHost;
  final int obsPort;
  final String obsPassword;
  final bool isVirtualCamActive;
  final bool isStreaming;
  final List<String> scenes;
  final String? currentScene;
  final bool isObsInstalled;
  final String? lastError;

  const ObsConnectionState({
    this.isHttpServerRunning = false,
    this.serverPort = 8088,
    this.serverUrl = 'http://127.0.0.1:8088/avatar',
    this.connectedClients = 0,
    this.transparentBackground = true,
    this.outputResolution = '1920x1080',
    this.outputFps = 60,
    this.isObsWebSocketConnected = false,
    this.obsHost = '127.0.0.1',
    this.obsPort = 4455,
    this.obsPassword = '',
    this.isVirtualCamActive = false,
    this.isStreaming = false,
    this.scenes = const [],
    this.currentScene,
    this.isObsInstalled = false,
    this.lastError,
  });

  ObsConnectionState copyWith({
    bool? isHttpServerRunning,
    int? serverPort,
    String? serverUrl,
    int? connectedClients,
    bool? transparentBackground,
    String? outputResolution,
    int? outputFps,
    bool? isObsWebSocketConnected,
    String? obsHost,
    int? obsPort,
    String? obsPassword,
    bool? isVirtualCamActive,
    bool? isStreaming,
    List<String>? scenes,
    String? currentScene,
    bool? isObsInstalled,
    String? lastError,
  }) {
    return ObsConnectionState(
      isHttpServerRunning: isHttpServerRunning ?? this.isHttpServerRunning,
      serverPort: serverPort ?? this.serverPort,
      serverUrl: serverUrl ?? this.serverUrl,
      connectedClients: connectedClients ?? this.connectedClients,
      transparentBackground:
          transparentBackground ?? this.transparentBackground,
      outputResolution: outputResolution ?? this.outputResolution,
      outputFps: outputFps ?? this.outputFps,
      isObsWebSocketConnected:
          isObsWebSocketConnected ?? this.isObsWebSocketConnected,
      obsHost: obsHost ?? this.obsHost,
      obsPort: obsPort ?? this.obsPort,
      obsPassword: obsPassword ?? this.obsPassword,
      isVirtualCamActive: isVirtualCamActive ?? this.isVirtualCamActive,
      isStreaming: isStreaming ?? this.isStreaming,
      scenes: scenes ?? this.scenes,
      currentScene: currentScene ?? this.currentScene,
      isObsInstalled: isObsInstalled ?? this.isObsInstalled,
      lastError: lastError,
    );
  }
}
