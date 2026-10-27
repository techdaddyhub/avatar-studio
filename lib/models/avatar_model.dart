import 'package:flutter/material.dart';

enum AvatarType { sample3D, sampleRigged2D, customModel, customPortrait }

class AvatarModel {
  final String id;
  final String name;
  final AvatarType type;
  final String styleId; // 'nova', 'aria', 'zenith', 'custom'
  final String description;
  final String? filePath;
  final Color skinTone;
  final Color eyeColor;
  final Color hairColor;
  final Color clothingColor;
  final double keyLightIntensity;
  final Color keyLightColor;
  final double ambientIntensity;
  final double scale;
  final double offsetY;
  final bool isCustom;
  final DateTime createdAt;

  const AvatarModel({
    required this.id,
    required this.name,
    required this.type,
    required this.styleId,
    required this.description,
    this.filePath,
    this.skinTone = const Color(0xFFF5D0B5),
    this.eyeColor = const Color(0xFF1E88E5),
    this.hairColor = const Color(0xFF263238),
    this.clothingColor = const Color(0xFF1E293B),
    this.keyLightIntensity = 1.0,
    this.keyLightColor = Colors.white,
    this.ambientIntensity = 0.5,
    this.scale = 1.0,
    this.offsetY = 0.0,
    this.isCustom = false,
    required this.createdAt,
  });

  AvatarModel copyWith({
    String? id,
    String? name,
    AvatarType? type,
    String? styleId,
    String? description,
    String? filePath,
    Color? skinTone,
    Color? eyeColor,
    Color? hairColor,
    Color? clothingColor,
    double? keyLightIntensity,
    Color? keyLightColor,
    double? ambientIntensity,
    double? scale,
    double? offsetY,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return AvatarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      styleId: styleId ?? this.styleId,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      skinTone: skinTone ?? this.skinTone,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
      clothingColor: clothingColor ?? this.clothingColor,
      keyLightIntensity: keyLightIntensity ?? this.keyLightIntensity,
      keyLightColor: keyLightColor ?? this.keyLightColor,
      ambientIntensity: ambientIntensity ?? this.ambientIntensity,
      scale: scale ?? this.scale,
      offsetY: offsetY ?? this.offsetY,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'styleId': styleId,
      'description': description,
      'filePath': filePath,
      'skinTone': skinTone.toARGB32(),
      'eyeColor': eyeColor.toARGB32(),
      'hairColor': hairColor.toARGB32(),
      'clothingColor': clothingColor.toARGB32(),
      'keyLightIntensity': keyLightIntensity,
      'keyLightColor': keyLightColor.toARGB32(),
      'ambientIntensity': ambientIntensity,
      'scale': scale,
      'offsetY': offsetY,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AvatarType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AvatarType.sampleRigged2D,
      ),
      styleId: json['styleId'] as String? ?? 'nova',
      description: json['description'] as String? ?? '',
      filePath: json['filePath'] as String?,
      skinTone: json['skinTone'] != null
          ? Color(json['skinTone'] as int)
          : const Color(0xFFF5D0B5),
      eyeColor: json['eyeColor'] != null
          ? Color(json['eyeColor'] as int)
          : const Color(0xFF1E88E5),
      hairColor: json['hairColor'] != null
          ? Color(json['hairColor'] as int)
          : const Color(0xFF263238),
      clothingColor: json['clothingColor'] != null
          ? Color(json['clothingColor'] as int)
          : const Color(0xFF1E293B),
      keyLightIntensity: (json['keyLightIntensity'] as num?)?.toDouble() ?? 1.0,
      keyLightColor: json['keyLightColor'] != null
          ? Color(json['keyLightColor'] as int)
          : Colors.white,
      ambientIntensity: (json['ambientIntensity'] as num?)?.toDouble() ?? 0.5,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0.0,
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
