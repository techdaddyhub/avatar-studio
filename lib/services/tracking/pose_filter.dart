class PoseFilter {
  double _filteredValue;
  final double
  smoothingFactor; // 0.0 (no change) to 1.0 (instant, no smoothing)

  PoseFilter({double initialValue = 0.0, this.smoothingFactor = 0.45})
    : _filteredValue = initialValue;

  double filter(double rawValue) {
    // Exponential Moving Average: y[n] = alpha * x[n] + (1 - alpha) * y[n-1]
    _filteredValue =
        (smoothingFactor * rawValue) +
        ((1.0 - smoothingFactor) * _filteredValue);
    return _filteredValue;
  }

  void reset(double value) {
    _filteredValue = value;
  }

  double get value => _filteredValue;
}

class HeadPoseFilter {
  final PoseFilter pitchFilter;
  final PoseFilter yawFilter;
  final PoseFilter rollFilter;
  final PoseFilter leftBlinkFilter;
  final PoseFilter rightBlinkFilter;
  final PoseFilter mouthOpenFilter;
  final PoseFilter smileFilter;

  HeadPoseFilter({double smoothing = 0.45})
    : pitchFilter = PoseFilter(smoothingFactor: smoothing),
      yawFilter = PoseFilter(smoothingFactor: smoothing),
      rollFilter = PoseFilter(smoothingFactor: smoothing),
      leftBlinkFilter = PoseFilter(
        smoothingFactor: smoothing * 1.5,
      ), // Blinks should be fast
      rightBlinkFilter = PoseFilter(smoothingFactor: smoothing * 1.5),
      mouthOpenFilter = PoseFilter(smoothingFactor: smoothing * 1.2),
      smileFilter = PoseFilter(smoothingFactor: smoothing);

  void reset() {
    pitchFilter.reset(0.0);
    yawFilter.reset(0.0);
    rollFilter.reset(0.0);
    leftBlinkFilter.reset(0.0);
    rightBlinkFilter.reset(0.0);
    mouthOpenFilter.reset(0.0);
    smileFilter.reset(0.0);
  }
}
