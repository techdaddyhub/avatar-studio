import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import '../../../core/theme/app_colors.dart';
import '../../../models/avatar_model.dart';
import '../../../providers/avatar_provider.dart';
import '../../../providers/tracking_provider.dart';
import '../../../providers/audio_sync_provider.dart';
import '../../../services/rendering/avatar_painter.dart';
import '../../../services/rendering/upper_body_kinematics.dart';

class AvatarViewport extends StatefulWidget {
  final bool showCheckerboard;

  const AvatarViewport({super.key, this.showCheckerboard = false});

  @override
  State<AvatarViewport> createState() => _AvatarViewportState();
}

class _AvatarViewportState extends State<AvatarViewport>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsedSeconds = elapsed.inMilliseconds / 1000.0;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarProv = context.watch<AvatarProvider>();
    final trackingProv = context.watch<TrackingProvider>();
    final audioProv = context.watch<AudioSyncProvider>();

    final avatar = avatarProv.activeAvatar;
    final scene = avatarProv.activeScene;

    final hasCustomFile = avatar.filePath != null &&
        File(avatar.filePath!).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background (Scene or Checkerboard for Transparency)
          if (!scene.isTransparent)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scene.primaryColor, scene.secondaryColor],
                ),
              ),
            )
          else if (widget.showCheckerboard)
            CustomPaint(painter: _CheckerboardPainter()),

          // 2. Avatar Presentation
          if (hasCustomFile && avatar.type == AvatarType.customPortrait)
            _buildCustomPortraitAvatar(
              avatar: avatar,
              tracking: trackingProv,
              audio: audioProv,
            )
          else if (hasCustomFile && avatar.type == AvatarType.customModel)
            _buildCustomModelAvatar(
              avatar: avatar,
              tracking: trackingProv,
              audio: audioProv,
            )
          else
            // Fallback / Procedural Avatar Painter
            CustomPaint(
              painter: AvatarPainter(
                avatar: avatar,
                tracking: trackingProv.state,
                audio: audioProv.state,
                scene: scene,
                idleTimeSeconds: _elapsedSeconds,
                isTransparent: scene.isTransparent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomPortraitAvatar({
    required AvatarModel avatar,
    required TrackingProvider tracking,
    required AudioSyncProvider audio,
  }) {
    final file = File(avatar.filePath!);
    final pitch = tracking.state.pitch;
    final yaw = tracking.state.yaw;
    final roll = tracking.state.roll;

    final naturalBlink = (math.sin(_elapsedSeconds * 0.8) > 0.96) ? 1.0 : 0.0;
    final isBlinking = tracking.state.leftEyeBlink > 0.6 ||
        tracking.state.rightEyeBlink > 0.6 ||
        naturalBlink > 0.5;

    final breathOffset = math.sin(_elapsedSeconds * 1.6) * 4.0;
    final mouthOpen = math.max(
      tracking.state.mouthOpen,
      audio.state.isVoiceActive
          ? (audio.state.mouthOpenAmount * audio.state.sensitivity).clamp(0.0, 1.0)
          : 0.0,
    );

    final isSpeaking = audio.state.isVoiceActive || mouthOpen > 0.08;

    // Biomechanical Upper Body & Hands Kinematics
    final upperBody = UpperBodyKinematicsSolver.solve(
      size: const Size(360, 480),
      pitch: pitch,
      yaw: yaw,
      roll: roll,
      idleTime: _elapsedSeconds,
      isVoiceActive: isSpeaking,
      speechEnergy: (mouthOpen * 1.5).clamp(0.0, 1.0),
    );

    return Center(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 3D Perspective Depth
          ..translateByVector3(vmath.Vector3(
            (yaw * 16.0),
            (avatar.offsetY * 120.0) + breathOffset,
            0.0,
          ))
          ..rotateX(-pitch * 0.32)
          ..rotateY(yaw * 0.38)
          ..rotateZ(roll * 0.35)
          ..scaleByVector3(vmath.Vector3(avatar.scale, avatar.scale, 1.0)),
        child: Container(
          width: 330,
          height: 440,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              // Dynamic Voice Activity Audio Glow
              if (isSpeaking)
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(
                    alpha: 0.35 + (mouthOpen * 0.35),
                  ),
                  blurRadius: 32 + (mouthOpen * 16),
                  spreadRadius: 4 + (mouthOpen * 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main User Uploaded Image with dynamic jaw stretch & shoulder counter-sway
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..scaleByVector3(vmath.Vector3(1.0, 1.0 + (mouthOpen * 0.04), 1.0))
                    ..rotateZ(-upperBody.torsoAngle * 0.15),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.bgDarkest,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Conversational Expressive Hands (Animated in foreground during speech)
              Positioned(
                bottom: -15,
                left: 0,
                right: 0,
                height: 220,
                child: CustomPaint(
                  painter: _PortraitHandsOverlayPainter(
                    pose: upperBody,
                    skinTone: avatar.skinTone,
                  ),
                ),
              ),

              // Studio Key Light Overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          -0.3 + (yaw * 0.3),
                          -0.4 + (pitch * 0.2),
                        ),
                        radius: 1.1,
                        colors: [
                          avatar.keyLightColor.withValues(
                            alpha: (avatar.keyLightIntensity * 0.2).clamp(0.0, 0.45),
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Dynamic Blink Simulation Overlay
              if (isBlinking)
                Positioned(
                  top: 130 + (pitch * 15),
                  left: 45 + (yaw * 15),
                  right: 45 - (yaw * 15),
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ),

              // Speech Viseme / Audio Ring Indicator
              if (isSpeaking)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgDarkest.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryCyan.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.graphic_eq,
                          size: 14,
                          color: AppColors.primaryCyan,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'VISEME: ${audio.state.currentViseme.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.primaryCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Cyber Corner Accent
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bgDarkest.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tracking.isTracking
                              ? AppColors.statusOnline
                              : AppColors.primaryCyan,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        avatar.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomModelAvatar({
    required AvatarModel avatar,
    required TrackingProvider tracking,
    required AudioSyncProvider audio,
  }) {
    final pitch = tracking.state.pitch;
    final yaw = tracking.state.yaw;
    final roll = tracking.state.roll;

    return Center(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translateByVector3(vmath.Vector3(0.0, avatar.offsetY * 120.0, 0.0))
          ..rotateX(-pitch * 0.4)
          ..rotateY(yaw * 0.5)
          ..rotateZ(roll * 0.4)
          ..scaleByVector3(vmath.Vector3(avatar.scale, avatar.scale, 1.0)),
        child: Container(
          width: 320,
          height: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryCyan, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withValues(alpha: 0.25),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.primaryCyan, width: 2),
                ),
                child: const Icon(
                  Icons.view_in_ar,
                  size: 48,
                  color: AppColors.primaryCyan,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                avatar.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '3D GLB/VRM MODEL RIGGED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryCyan,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgDarkest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildTrackingTelemetryRow(
                      'Yaw / Pitch / Roll',
                      '${(yaw * 45).toStringAsFixed(1)}° / ${(pitch * 45).toStringAsFixed(1)}° / ${(roll * 45).toStringAsFixed(1)}°',
                    ),
                    const SizedBox(height: 6),
                    _buildTrackingTelemetryRow(
                      'Mouth Aperture',
                      '${((tracking.state.mouthOpen) * 100).toInt()}%',
                    ),
                    const SizedBox(height: 6),
                    _buildTrackingTelemetryRow(
                      'Viseme Blendshape',
                      audio.state.currentViseme.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingTelemetryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            color: AppColors.primaryCyan,
          ),
        ),
      ],
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 20.0;
    final paint1 = Paint()..color = const Color(0xFF161E30);
    final paint2 = Paint()..color = const Color(0xFF1E2840);

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        final isEven =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isEven ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PortraitHandsOverlayPainter extends CustomPainter {
  final UpperBodyPose pose;
  final Color skinTone;

  const _PortraitHandsOverlayPainter({
    required this.pose,
    required this.skinTone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose.leftHandElevation < 0.04 && pose.rightHandElevation < 0.04) return;

    final leftWristLocal = Offset(
      size.width * 0.24 + (math.sin(pose.leftHandGesturePhase) * (pose.leftHandElevation * 24.0)),
      size.height - 25.0 - (pose.leftHandElevation * 135.0),
    );
    final rightWristLocal = Offset(
      size.width * 0.76 + (math.sin(pose.rightHandGesturePhase) * (pose.rightHandElevation * 26.0)),
      size.height - 25.0 - (pose.rightHandElevation * 130.0),
    );

    // Left articulated conversational hand
    UpperBodyKinematicsSolver.paintArticulatedHand(
      canvas: canvas,
      wrist: leftWristLocal,
      skinTone: skinTone,
      isLeft: true,
      gesturePhase: pose.leftHandGesturePhase,
      elevation: pose.leftHandElevation,
      fingerCurl: pose.fingerCurl,
      scale: 1.05,
    );

    // Right articulated conversational hand
    UpperBodyKinematicsSolver.paintArticulatedHand(
      canvas: canvas,
      wrist: rightWristLocal,
      skinTone: skinTone,
      isLeft: false,
      gesturePhase: pose.rightHandGesturePhase,
      elevation: pose.rightHandElevation,
      fingerCurl: pose.fingerCurl,
      scale: 1.05,
    );
  }

  @override
  bool shouldRepaint(covariant _PortraitHandsOverlayPainter oldDelegate) => true;
}
