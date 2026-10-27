import 'package:flutter/material.dart';

enum SceneType {
  transparent,
  studioDark,
  cyberpunk,
  chromaGreen,
  executiveBoardroom,
  customImage,
}

class ScenePreset {
  final String id;
  final String name;
  final SceneType type;
  final Color primaryColor;
  final Color secondaryColor;
  final String? customImagePath;
  final bool isTransparent;

  const ScenePreset({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    this.customImagePath,
    this.isTransparent = false,
  });

  static const ScenePreset transparent = ScenePreset(
    id: 'scene_transparent',
    name: 'OBS Transparent Alpha',
    type: SceneType.transparent,
    primaryColor: Colors.transparent,
    secondaryColor: Colors.transparent,
    isTransparent: true,
  );

  static const ScenePreset studioDark = ScenePreset(
    id: 'scene_studio_dark',
    name: 'Studio Midnight',
    type: SceneType.studioDark,
    primaryColor: Color(0xFF0F172A),
    secondaryColor: Color(0xFF020617),
  );

  static const ScenePreset cyberpunk = ScenePreset(
    id: 'scene_cyberpunk',
    name: 'Neon Cyberpunk',
    type: SceneType.cyberpunk,
    primaryColor: Color(0xFF1E1035),
    secondaryColor: Color(0xFF0D0221),
  );

  static const ScenePreset chromaGreen = ScenePreset(
    id: 'scene_chroma',
    name: 'Chroma Key Green',
    type: SceneType.chromaGreen,
    primaryColor: Color(0xFF00FF00),
    secondaryColor: Color(0xFF00FF00),
  );

  static const ScenePreset executive = ScenePreset(
    id: 'scene_executive',
    name: 'Executive Boardroom',
    type: SceneType.executiveBoardroom,
    primaryColor: Color(0xFF1C1917),
    secondaryColor: Color(0xFF292524),
  );

  static List<ScenePreset> get defaults => [
    transparent,
    studioDark,
    cyberpunk,
    chromaGreen,
    executive,
  ];
}
