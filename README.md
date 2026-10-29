# TD-avatar-studio — Professional Desktop Avatar & Livestreaming System

```
  ████████╗██████╗        █████╗ ██╗   ██╗ █████╗ ████████╗ █████╗ ██████╗ 
  ╚══██╔══╝██╔══██╗      ██╔══██╗██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗
     ██║   ██║  ██║█████╗███████║██║   ██║███████║   ██║   ███████║██████╔╝
     ██║   ██║  ██║╚════╝██╔══██║╚██╗ ██╔╝██╔══██║   ██║   ██╔══██║██╔══██╗
     ██║   ██████╔╝      ██║  ██║ ╚████╔╝ ██║  ██║   ██║   ██║  ██║██║  ██║
     ╚═╝   ╚═════╝       ╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝
```

[![Release](https://img.shields.io/github/v/release/techdaddyhub/avatar-studio?logo=github&color=00E5FF)](https://github.com/techdaddyhub/avatar-studio/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![OBS Studio](https://img.shields.io/badge/OBS_Studio-Compatible-302E31?logo=obsstudio&logoColor=white)](https://obsproject.com)
[![Paystack](https://img.shields.io/badge/Paystack-₦200%2C000_1--Time-00C3F7?logo=paystack&logoColor=white)](https://paystack.com)
[![NOWPayments](https://img.shields.io/badge/NOWPayments-$135_Crypto_Live-2775CA)](https://nowpayments.io)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-blue)](#quick-download--releases)
[![License](https://img.shields.io/badge/License-1--Time%20Lifetime%20Studio-00E5FF)](#commercial-studio-licensing)

**TD-avatar-studio** is a production-ready, lightweight, cross-platform desktop application designed to create, animate, preview, and stream expressive 2D and 3D digital avatars into **OBS Studio**, **Zoom**, **Microsoft Teams**, **Discord**, and **Google Meet**. Features instant 1-time lifetime commercial licensing via **Paystack (₦200,000 NGN)** and **NOWPayments Crypto ($135 USD)**.

---

## Quick Download & Releases

Download production-ready precompiled release bundles directly from GitHub:

| Platform | Download Link | Notes |
|---|---|---|
| **Linux (x64)** | [TD-Avatar-Studio-Linux-x64.tar.gz](https://github.com/techdaddyhub/avatar-studio/releases/latest) | Standalone portable bundle. Extract and run `./avatar_studio`. |
| **Windows (x64)** | [TD-Avatar-Studio-Windows-x64.zip](https://github.com/techdaddyhub/avatar-studio/releases/latest) | Standalone release folder. Extract and run `avatar_studio.exe`. |
| **macOS (Universal)** | [TD-Avatar-Studio-macOS.zip](https://github.com/techdaddyhub/avatar-studio/releases/latest) | Standalone `avatar_studio.app` for Intel & Apple Silicon. |

---

## Table of Contents
1. [Core Features](#core-features)
2. [Commercial Studio Licensing (₦200,000 1-Time Payment)](#commercial-studio-licensing)
3. [Architecture Overview](#architecture-overview)
4. [Sample Avatars](#sample-avatars)
5. [OBS Studio Integration](#obs-studio-integration)
6. [Real-Time Deepfake & Face-Swap Camera Bridging](#real-time-deepfake--face-swap-camera-bridging)
7. [Hardware Adaptation (Core i3 and Above)](#hardware-adaptation-core-i3-and-above)
8. [Real-Time Face Tracking & Privacy](#real-time-face-tracking--privacy)
9. [Voice & Lip-Sync Engine](#voice--lip-sync-engine)
10. [Cross-Platform Build Instructions](#cross-platform-build-instructions)
11. [Troubleshooting & Diagnostics](#troubleshooting--diagnostics)

---

## Core Features

- **High-Performance Canvas/Shader Avatar Engine**: Real-time rendering with natural skin contours, realistic eye blinking, pupil dilation, specular highlights, and natural breathing idle dynamics.
- **OBS Transparent Browser Source**: Delivers high-framerate (30/60 FPS) avatar frames with a true transparent alpha channel (`rgba(0,0,0,0)`) over a local embedded HTTP/WebSocket server.
- **Real-Time Face Tracking**: Local computer vision tracking estimating Head Pitch, Yaw, Roll, Eye Blinking, Brow Raise, and Smile with EMA / Kalman jitter suppression.
- **Acoustic Lip-Sync & Viseme Mapping**: Voice Activity Detection (VAD) coupled with spectral energy analysis mapping user speech to visemes (`sil`, `aa`, `ee`, `oh`, `ch`, `m`).
- **Core i3 Adaptive Optimization**: Runs smoothly on low-resource machines with 4 GB – 8 GB RAM via three adaptive profiles: *Economy*, *Balanced*, and *Quality*.
- **Offline & Privacy-First**: Zero cloud dependence. Camera frames, audio streams, and avatar models never leave your computer.
- **Profile & Asset Manager**: Create, duplicate, rename, customize, and import GLB/glTF/VRM 3D models or portrait assets with path-traversal protection.
- **TD Vector Logo Branding**: Integrated crisp vector logo and sleek dark cybernetic UI styling.

---

## Commercial Studio Licensing

TD-Avatar-Studio features a simple, transparent commercial licensing model:

### 1-Time Lifetime Studio License
- **Price**: **₦200,000 NGN** (or **$135 USD** crypto equivalent via NOWPayments).
- **Payment Model**: **1-Time payment** — pay once, own forever. **No recurring monthly subscriptions.**
- **Access Code Format**: Cryptographically signed permanent license key `TD-LIFE-XXXX-YYYY`.
- **Features Unlocked**:
  - Unrestricted commercial OBS Studio livestreaming without watermarks.
  - Unlimited custom avatar uploads (`.glb`, `.gltf`, `.vrm`, `.png`, `.jpg`).
  - Sub-pixel 60 FPS canvas rendering and transparent alpha channel streaming.
  - Multi-platform compatibility across Linux, Windows, and macOS installations.
  - Offline perpetual validation (valid even when completely air-gapped).

### Payment Gateway Integrations
1. **Paystack (₦200,000 NGN)**:
   - Debit/Credit Cards (Mastercard, Visa, Verve), Bank Transfers, and USSD.
   - Automatically initializes transactions with currency `NGN` and amount in kobo (`20000000 kobo`).
   - Generates instant `TD-LIFE-` access code upon confirmation.
2. **NOWPayments Crypto ($135 USD)**:
   - Multi-cryptocurrency support: **USDT (TRC20/ERC20/BEP20)**, **Bitcoin (BTC)**, **Ethereum (ETH)**, **Solana (SOL)**, and **BNB**.
   - Production Live API Key: `316FMKQ-AAE45WB-M480GSF-4M620E7`
   - Public Key: `6cffbee0-1ae6-406a-8399-0db59addc5c8`
   - Real-time blockchain confirmation and instant lifetime code unlocking.

---

## Architecture Overview

```
lib/
├── core/
│   ├── constants/       # Default avatars, ports, framerate limits
│   ├── services/        # Local JSON persistence & offline licensing
│   ├── theme/           # Premium dark creator design system
│   └── utils/           # Hardware detection & path traversal sanitizer
├── models/              # AvatarModel, TrackingState, AudioSyncState, ObsState, BillingPlan
├── providers/           # ChangeNotifier state management for Flutter desktop
├── services/
│   ├── audio/           # Mic device discovery, RMS dBFS meter & visemes
│   ├── billing/         # Paystack & NOWPayments crypto gateways
│   ├── obs/             # Local Shelf HTTP/WebSocket server & OBS WS v5 client
│   ├── rendering/       # AvatarPainter, ExpressionController
│   └── tracking/        # Camera discovery, PoseFilter & face landmarks
├── views/               # 11 Dedicated views (Studio, Library, OBS, Tracking...)
└── widgets/             # TopStatusBar, SidebarNav, GlassCard, Viewport, TdLogo
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

## Real-Time Deepfake & Face-Swap Camera Bridging

TD-Avatar-Studio seamlessly bridges with open-source real-time face-swap engines (**DeepFaceLive** and **Deep-Live-Cam**) to replace or animate your face live during PC video calls, conferences, and livestreams:

### Compatible Face-Swap Software:
1. **[DeepFaceLive](https://github.com/iperov/DeepFaceLive)**:
   - Free, open-source real-time face-swapping software utilizing InsightFace / DFM models.
   - Routes real-time swapped output via virtual camera into OBS Studio or TD-Avatar-Studio.
2. **[Deep-Live-Cam](https://github.com/hacksider/Deep-Live-Cam)**:
   - Real-time live face swap from a single reference image on CPU, NVIDIA CUDA, and Apple Silicon.
3. **OBS Virtual Camera**:
   - Stream either the raw avatar, the swapped face, or an avatar overlay with transparent background directly into Zoom, Teams, Meet, or Discord.

### Setup Workflow:
```
[Webcam / DeepFaceLive / Deep-Live-Cam]
            │
            ▼
[OBS Studio / Virtual Camera] ──► [TD-Avatar-Studio (Face Tracking + Viseme Lip-Sync)]
            │
            ▼
[Zoom / Microsoft Teams / Google Meet / Discord / Twitch / YouTube]
```

1. **Start Face-Swap**: Run DeepFaceLive or Deep-Live-Cam with your target reference avatar or face photo.
2. **Select Camera in TD-Avatar-Studio**: Navigate to **Face Tracking** view, and select the virtual camera source from the dropdown.
3. **Add Avatar to OBS**: In OBS Studio, add a Browser Source pointing to `http://127.0.0.1:8088/avatar`.
4. **Start Virtual Camera in OBS**: Broadcast the finished stream directly into your meeting or livestreaming platform.

---

## 1-Time Commercial Studio Licensing (₦200,000 NGN)

TD-Avatar-Studio uses a single, permanent commercial license for creators, agencies, and studios:

### Studio Lifetime License (₦200,000 NGN / $135 USD)
- **Permanent Commercial Ownership**: One-time payment with **no recurring monthly charges**.
- **Instant Activation**: Upon payment confirmation, a unique, signed Access Code (`TD-LIFE-XXXX-YYYY`) is generated and locked to your installation.
- **Permanent Full Studio Features**:
  - Uncapped 60 FPS transparent alpha streaming to OBS Studio.
  - Unlimited custom avatar uploads (2D portraits & 3D GLB/glTF/VRM).
  - Real-time acoustic viseme lip-sync and landmark facial tracking.
  - Transferable license key across installations.
  - Offline perpetual validation (runs air-gapped without needing internet).

### Payment Gateway Integrations
1. **Paystack (₦200,000 NGN)**:
   - Direct debit/credit card processing, bank transfer, and USSD.
   - Initialized via `https://api.paystack.co/transaction/initialize` with amount `20,000,000` kobo.
   - Local redirection callback: `http://127.0.0.1:8088/billing/paystack-callback`.
   - Verified via `https://api.paystack.co/transaction/verify/:reference`.
2. **NOWPayments Crypto ($135 USD)**:
   - Supports USDT (TRC20/ERC20/BEP20), BTC, ETH, SOL, BNB.
   - Pre-configured with live API key and public key.
   - Blockchain confirmations update status in real time and deliver your `TD-LIFE-` access code.

---

## Account and Offline Licensing

For corporate bulk deployments or machines that operate in air-gapped broadcast environments, manual lifetime access codes (`TD-LIFE-XXXX-YYYY`) can be entered directly under **Account & Commercial Licensing** -> **Activate Access Code** to unlock all pro features without an active internet connection.

---

## Troubleshooting & Diagnostics

- **GTK 3.0 error on Linux**: Ensure development libraries are installed: `sudo apt install -y libgtk-3-dev`.
- **Webcam not detected**: Check device permissions. On Linux ensure user is part of the `video` group (`sudo usermod -aG video $USER`).
- **OBS Browser Source shows black background**: In OBS Browser Source properties, ensure custom CSS does not override the body background. The default URL `http://127.0.0.1:8088/avatar` includes transparent CSS by default.
- **Audio meter not moving**: Check if microphone is muted in system settings or click the **MIC** button in Avatar Studio's top toolbar.
- **Run Self-Test**: Navigate to **Help & Diagnostics** and click **RUN SELF-DIAGNOSTICS** to verify file system access, filter latency, and local server health.
