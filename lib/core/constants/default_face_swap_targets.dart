import '../../models/face_swap_model.dart';

class DefaultFaceSwapTargets {
  DefaultFaceSwapTargets._();

  static final FaceSwapTarget marcusExecutive = FaceSwapTarget(
    id: 'target_marcus_exec',
    name: 'Marcus Vance',
    category: 'Executive & Keynote',
    description:
        'Confident corporate executive presenter with warm studio lighting and sharp formal attire.',
    skinToneHex: '#E0AC89',
    createdAt: DateTime(2026, 1, 1),
  );

  static final FaceSwapTarget elenaBroadcast = FaceSwapTarget(
    id: 'target_elena_anchor',
    name: 'Elena Rostova',
    category: 'Broadcast & News',
    description:
        'Studio-lit television news anchor face with expressive gaze and professional broadcast articulation.',
    skinToneHex: '#F6D2BD',
    createdAt: DateTime(2026, 1, 2),
  );

  static final FaceSwapTarget kaiTech = FaceSwapTarget(
    id: 'target_kai_streamer',
    name: 'Kai Chen',
    category: 'Tech & Gaming Host',
    description:
        'Modern tech keynote speaker and livestream host with dynamic lighting and responsive expressions.',
    skinToneHex: '#EFCDB2',
    createdAt: DateTime(2026, 1, 3),
  );

  static final FaceSwapTarget sarahMedia = FaceSwapTarget(
    id: 'target_sarah_media',
    name: 'Sarah Jenkins',
    category: 'Creative Media',
    description:
        'Approachable, engaging creative director face ideal for collaborative team meetings and podcasting.',
    skinToneHex: '#E8B998',
    createdAt: DateTime(2026, 1, 4),
  );

  static List<FaceSwapTarget> get presets => [
    marcusExecutive,
    elenaBroadcast,
    kaiTech,
    sarahMedia,
  ];
}

