enum VisemeType {
  sil, // Silence / Neutral closed lips
  aa, // Wide open vowel ('father', 'ah')
  ee, // Wide spread lips ('see', 'meet')
  oh, // Rounded lips ('go', 'home')
  ch, // Semi-open teeth together ('cheese', 'shoe')
  m, // Closed lips consonant ('mom', 'pie')
}

class VisemeResult {
  final VisemeType type;
  final String label;
  final double mouthOpen;
  final double mouthSpread; // -1.0 (rounded) to +1.0 (spread)

  const VisemeResult({
    required this.type,
    required this.label,
    required this.mouthOpen,
    required this.mouthSpread,
  });

  static const VisemeResult silence = VisemeResult(
    type: VisemeType.sil,
    label: 'sil',
    mouthOpen: 0.0,
    mouthSpread: 0.0,
  );
}

class VisemeExtractor {
  VisemeExtractor._();

  /// Maps RMS audio level (in dBFS) and estimated frequency band to a real-time viseme
  static VisemeResult extractViseme({
    required double levelDb,
    required double vadThreshold,
    required double sensitivity,
    required double formantsRatio, // spectral balance 0.0 to 1.0
  }) {
    // If audio is below Voice Activity Detection threshold, return silence
    if (levelDb < vadThreshold) {
      return VisemeResult.silence;
    }

    // Normalized energy [0.0 to 1.0] above threshold
    final range = (0.0 - vadThreshold).abs();
    final normalized = ((levelDb - vadThreshold) / range * sensitivity).clamp(
      0.0,
      1.0,
    );

    // Phoneme / Viseme mapping:
    // Low formant ratio + High energy -> 'oh' (rounded)
    // High formant ratio + High energy -> 'ee' (spread)
    // Mid formant ratio + High energy -> 'aa' (wide open)
    // Low energy active speech -> 'ch' or 'm'
    if (normalized > 0.6) {
      if (formantsRatio < 0.35) {
        return VisemeResult(
          type: VisemeType.oh,
          label: 'oh',
          mouthOpen: normalized * 0.9,
          mouthSpread: -0.6,
        );
      } else if (formantsRatio > 0.65) {
        return VisemeResult(
          type: VisemeType.ee,
          label: 'ee',
          mouthOpen: normalized * 0.6,
          mouthSpread: 0.8,
        );
      } else {
        return VisemeResult(
          type: VisemeType.aa,
          label: 'aa',
          mouthOpen: normalized,
          mouthSpread: 0.2,
        );
      }
    } else if (normalized > 0.2) {
      return VisemeResult(
        type: VisemeType.ch,
        label: 'ch',
        mouthOpen: normalized * 0.45,
        mouthSpread: 0.1,
      );
    } else {
      return VisemeResult(
        type: VisemeType.m,
        label: 'm',
        mouthOpen: normalized * 0.1,
        mouthSpread: 0.0,
      );
    }
  }
}
