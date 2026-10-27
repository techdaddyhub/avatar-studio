import 'package:flutter/material.dart';
import '../../models/avatar_model.dart';

class DefaultAvatars {
  DefaultAvatars._();

  static final AvatarModel nova = AvatarModel(
    id: 'sample_nova',
    name: 'Nova — Intelligent Host',
    type: AvatarType.sampleRigged2D,
    styleId: 'nova',
    description:
        'Polished digital presenter with natural skin shading, dynamic eye gaze, and fluid facial gestures.',
    skinTone: const Color(0xFFF7D5C4),
    eyeColor: const Color(0xFF0091EA),
    hairColor: const Color(0xFF263238),
    clothingColor: const Color(0xFF1E293B),
    keyLightColor: const Color(0xFFE1F5FE),
    keyLightIntensity: 1.2,
    ambientIntensity: 0.6,
    scale: 1.0,
    offsetY: 0.0,
    isCustom: false,
    createdAt: DateTime(2026, 1, 1),
  );

  static final AvatarModel aria = AvatarModel(
    id: 'sample_aria',
    name: 'Aria — Executive Presenter',
    type: AvatarType.sampleRigged2D,
    styleId: 'aria',
    description:
        'Corporate executive avatar designed for keynote webinars, business livestreams, and video calls.',
    skinTone: const Color(0xFFE8B998),
    eyeColor: const Color(0xFF2E7D32),
    hairColor: const Color(0xFF4E342E),
    clothingColor: const Color(0xFF0D47A1),
    keyLightColor: const Color(0xFFFFF8E1),
    keyLightIntensity: 1.1,
    ambientIntensity: 0.5,
    scale: 1.0,
    offsetY: 0.0,
    isCustom: false,
    createdAt: DateTime(2026, 1, 1),
  );

  static final AvatarModel zenith = AvatarModel(
    id: 'sample_zenith',
    name: 'Zenith — Stylized Streamer',
    type: AvatarType.sampleRigged2D,
    styleId: 'zenith',
    description:
        'Vibrant creator avatar with high-contrast ambient lighting, neon accents, and expressive gestures.',
    skinTone: const Color(0xFFFFDFC4),
    eyeColor: const Color(0xFFD500F9),
    hairColor: const Color(0xFF212121),
    clothingColor: const Color(0xFF2979FF),
    keyLightColor: const Color(0xFF00E5FF),
    keyLightIntensity: 1.4,
    ambientIntensity: 0.7,
    scale: 1.0,
    offsetY: 0.0,
    isCustom: false,
    createdAt: DateTime(2026, 1, 1),
  );

  static List<AvatarModel> get all => [nova, aria, zenith];
}
