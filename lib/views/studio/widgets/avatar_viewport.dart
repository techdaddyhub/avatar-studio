import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../providers/avatar_provider.dart';
import '../../../providers/tracking_provider.dart';
import '../../../providers/audio_sync_provider.dart';
import '../../../services/rendering/avatar_painter.dart';

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Optional Transparency checkerboard
          if (avatarProv.activeScene.isTransparent && widget.showCheckerboard)
            CustomPaint(painter: _CheckerboardPainter()),

          // Main Avatar Custom Painter
          CustomPaint(
            painter: AvatarPainter(
              avatar: avatarProv.activeAvatar,
              tracking: trackingProv.state,
              audio: audioProv.state,
              scene: avatarProv.activeScene,
              idleTimeSeconds: _elapsedSeconds,
              isTransparent: avatarProv.activeScene.isTransparent,
            ),
          ),
        ],
      ),
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
