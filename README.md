# Avatar Studio — Professional Desktop Avatar & Livestreaming System

[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![OBS Studio](https://img.shields.io/badge/OBS_Studio-Compatible-302E31?logo=obsstudio&logoColor=white)](https://obsproject.com)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-blue)](#cross-platform-build-instructions)
[![License](https://img.shields.io/badge/License-Community%20%2F%20Pro-00E5FF)](#account-and-offline-licensing)

**Avatar Studio** is a professional, lightweight, cross-platform desktop application designed to create, animate, preview, and stream expressive digital avatars into **OBS Studio**, **Zoom**, **Microsoft Teams**, **Discord**, and **Google Meet**.

---

## Table of Contents
1. [Core Features](#core-features)
2. [Architecture Overview](#architecture-overview)
3. [Sample Avatars](#sample-avatars)
4. [OBS Studio Integration](#obs-studio-integration)
5. [Hardware Adaptation (Core i3 and Above)](#hardware-adaptation-core-i3-and-above)
6. [Real-Time Face Tracking & Privacy](#real-time-face-tracking--privacy)
7. [Voice & Lip-Sync Engine](#voice--lip-sync-engine)
8. [Cross-Platform Build Instructions](#cross-platform-build-instructions)
9. [Account and Offline Licensing](#account-and-offline-licensing)
10. [Troubleshooting & Diagnostics](#troubleshooting--diagnostics)

---

## Core Features

- **High-Performance Canvas/Shader Avatar Engine**: Real-time rendering with natural skin contours, realistic eye blinking, pupil dilation, specular highlights, and natural breathing idle dynamics.
- **OBS Transparent Browser Source**: Delivers high-framerate (30/60 FPS) avatar frames with a true transparent alpha channel (`rgba(0,0,0,0)`) over a local embedded HTTP/WebSocket server.
- **Real-Time Face Tracking**: Local computer vision tracking estimating Head Pitch, Yaw, Roll, Eye Blinking, Brow Raise, and Smile with EMA / Kalman jitter suppression.
- **Acoustic Lip-Sync & Viseme Mapping**: Voice Activity Detection (VAD) coupled with spectral energy analysis mapping user speech to visemes (`sil`, `aa`, `ee`, `oh`, `ch`, `m`).
- **Core i3 Adaptive Optimization**: Runs smoothly on low-resource machines with 4 GB – 8 GB RAM via three adaptive profiles: *Economy*, *Balanced*, and *Quality*.
- **Offline & Privacy-First**: Zero cloud dependence. Camera frames, audio streams, and avatar models never leave your computer.
- **Profile Manager**: Create, duplicate, rename, customize, and import GLB/glTF/VRM 3D models or portrait assets with path-traversal protection.

---

## Architecture Overview

```
lib/
├── core/
│   ├── constants/       # Default avatars, ports, framerate limits
│   ├── services/        # Local JSON persistence & offline licensing
│   ├── theme/           # Premium dark creator design system
│   └── utils/           # Hardware detection & path traversal sanitizer
├── models/              # AvatarModel, TrackingState, AudioSyncState, ObsState
├── providers/           # ChangeNotifier state management for Flutter desktop
├── services/
│   ├── audio/           # Mic device discovery, RMS dBFS meter & visemes
│   ├── obs/             # Local Shelf HTTP/WebSocket server & OBS WS v5 client
│   ├── rendering/       # AvatarPainter, ExpressionController
│   └── tracking/        # Camera discovery, PoseFilter & face landmarks
├── views/               # 11 Dedicated views (Studio, Library, OBS, Tracking...)
└── widgets/             # TopStatusBar, SidebarNav, GlassCard, Viewport
```

---

## Sample Avatars

Avatar Studio ships with three built-in production avatars ready to animate immediately after launch:

1. **Nova — Intelligent Host**: Polished AI presenter featuring natural skin shading, dynamic eye gaze, and fluid facial gestures. Ideal for webinars and presentations.
2. **Aria — Executive Presenter**: Corporate executive avatar tailored for formal keynote livestreams and executive video calls.
3. **Zenith — Stylized Streamer**: Cyberpunk-inspired creator avatar with high-contrast ambient lighting, neon accents, and responsive facial gestures.

---

## OBS Studio Integration

### 1. Add Avatar Studio as a Transparent Browser Source
1. In Avatar Studio, click **START SOURCE SERVER** (or click the **OBS STREAM** toggle in the top bar).
2. The local server starts serving at:
   ```
   http://127.0.0.1:8088/avatar
   ```
3. Open **OBS Studio**, navigate to the **Sources** dock, and click **+ > Browser**.
4. Set the source properties:
   - **URL**: `http://127.0.0.1:8088/avatar`
   - **Width**: `1920` (or `1280`)
   - **Height**: `1080` (or `720`)
   - **Custom Frame Rate**: `60` (or `30`)
   - **Check**: `Shutdown source when not visible`
   - **Check**: `Refresh browser when scene becomes active`
5. The avatar will render with a transparent background directly on top of your slides, desktop screen, or gameplay!

### 2. Virtual Camera Workflow (Zoom / Teams / Meet / Discord)
1. Add the Avatar Browser Source to an OBS scene.
2. In the bottom-right **Controls** dock of OBS Studio, click **Start Virtual Camera**.
3. Open Zoom, Teams, Discord, or Google Meet, navigate to **Video Settings**, and select **OBS Virtual Camera** as your webcam device.

---

## Hardware Adaptation (Core i3 and Above)

Avatar Studio automatically detects your processor core count and RAM to set an optimal hardware profile:

| Profile | Target Hardware | Frame Rate | Features |
|---|---|---|---|
| **Economy Mode** | Intel Core i3 / 4 GB RAM | 30 FPS cap | Low memory footprint (<150 MB RSS), simplified shading, low-overhead tracking interpolation. |
| **Balanced Mode** | Core i5 / i7 / 8 GB RAM | 60 FPS target | Crisp 1080p, sub-pixel antialiasing, responsive lip-sync visemes. |
| **Quality Mode** | Discrete GPU / 16 GB+ RAM | 60 FPS ultra | High dynamic range lighting, sub-pixel antialiasing, uncompressed alpha streaming. |

---

## Real-Time Face Tracking & Privacy

- **Local Landmark Estimation**: Frames from your webcam are processed directly in local memory.
- **Jitter Suppression**: The built-in `HeadPoseFilter` uses Exponential Moving Averages (EMA) with velocity clamping to filter out jitter without adding input lag.
- **Manual Mode**: For computers lacking a webcam or when conserving CPU cycles, enable *Manual Mode* to adjust pitch, yaw, roll, eye blink, and smile using tactile sliders.
- **Calibration**: Hit **CALIBRATE CENTER POSE** at any time to re-zero your neutral forward-facing gaze.

---

## Voice & Lip-Sync Engine

- **dBFS RMS Volume Meter**: Real-time metering from -60 dBFS (silence) to 0 dBFS (peak).
- **Voice Activity Detection (VAD)**: Customizable threshold slider avoids mouth jitter caused by ambient background noise or room fans.
- **Viseme Spectrum Mapping**:
  - `SIL`: Closed mouth rest position.
  - `AA`: Wide vertical aperture ('father', 'start').
  - `EE`: Horizontal spread lips ('meet', 'see').
  - `OH`: Rounded circular lips ('go', 'home').
  - `CH`: Semi-open consonant teeth alignment.
  - `M`: Closed lip plosive consonant ('mom', 'pie').

---

## Cross-Platform Build Instructions

### Prerequisites
- [Flutter SDK 3.44+](https://flutter.dev/docs/get-started/install)
- [Dart SDK 3.12+](https://dart.dev)

### Linux (Ubuntu / Debian / Parrot / Fedora)
```bash
# Install GTK and CMake build tools
sudo apt update && sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev

# Get dependencies and run static analysis
flutter pub get
flutter analyze
flutter test

# Run or build native release binary
flutter run -d linux
flutter build linux --release
```
The compiled executable will be located in `build/linux/x64/release/bundle/avatar_studio`.

### Windows 10 & 11
```powershell
# Prerequisites: Visual Studio 2022 with "Desktop development with C++"
flutter pub get
flutter test
flutter run -d windows
flutter build windows --release
```
The compiled executable will be located in `build\windows\x64\runner\Release\avatar_studio.exe`.

### macOS (Intel & Apple Silicon)
```bash
# Prerequisites: Xcode and Command Line Tools
flutter pub get
flutter test
flutter run -d macos
flutter build macos --release
```
The output application bundle will be located in `build/macos/Build/Products/Release/avatar_studio.app`.

---

## Monthly Billing & Payment Gateway Integration

Avatar Studio integrates with **Paystack** and **NOWPayments** for subscription billing with automated monthly renewal cycles:

### Supported Monthly Plans
- **Creator Pro Monthly (\$19 / mo)**:
  - Commercial OBS livestreaming license.
  - Up to 50 saved avatar profiles.
  - Custom 3D model import (`.glb`, `.gltf`, `.vrm`).
  - Sub-pixel 60 FPS rendering and full acoustic viseme lip-sync.
- **Enterprise Studio Monthly (\$79 / mo)**:
  - Multi-seat studio organization license.
  - Unlimited saved avatar profiles.
  - Priority shader pipeline and custom blendshapes.
  - Monthly crypto tax receipts and dedicated OBS support.

### Payment Gateways Supported
1. **Paystack**:
   - Supports credit/debit cards (Visa, Mastercard, Verve), bank transfers, Apple Pay, and USSD.
   - Initialized via `https://api.paystack.co/transaction/initialize`.
   - On completion, redirects to Avatar Studio's local Shelf callback: `http://127.0.0.1:8088/billing/paystack-callback`.
   - Automatically verified via `https://api.paystack.co/transaction/verify/:reference`.
2. **NOWPayments**:
   - Supports major cryptocurrencies: USDT, Bitcoin (BTC), Ethereum (ETH), Solana (SOL), BNB, and more.
   - Generates crypto payment invoices with live blockchain confirmations.
   - Handled via `https://api.nowpayments.io/v1/invoice`.
   - On payment confirmation, redirects to `http://127.0.0.1:8088/billing/nowpayments-callback`.

### Subscription Lifecycle & Offline Independence
- Upon verified payment, Avatar Studio generates an active cryptographic license token and sets a **30-day renewal cycle**.
- The active subscription record is saved locally in sandboxed app data (`active_subscription.json`).
- If internet is temporarily lost, your active subscription remains valid on your desktop machine until its renewal date.
- Users can cancel their monthly subscription at any time with one click, gracefully reverting to the Free Community Edition.
- For air-gapped systems or enterprise bulk deployments, manual offline license keys (`PRO-XXXX` or `ENT-XXXX`) are fully supported without connecting to any payment gateway.

---

## Account and Offline Licensing

---

## Troubleshooting & Diagnostics

- **Webcam not detected**: Check device permissions. On Linux ensure user is part of the `video` group (`sudo usermod -aG video $USER`).
- **OBS Browser Source shows black background**: In OBS Browser Source properties, ensure custom CSS does not override the body background. The default URL `http://127.0.0.1:8088/avatar` includes transparent CSS by default.
- **Audio meter not moving**: Check if microphone is muted in system settings or click the **MIC** button in Avatar Studio's top toolbar.
- **Run Self-Test**: Navigate to **Help & Diagnostics** and click **RUN SELF-DIAGNOSTICS** to verify file system access, filter latency, and local server health.
