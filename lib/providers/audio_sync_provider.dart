import 'package:flutter/material.dart';
import '../models/audio_sync_state.dart';
import '../services/audio/audio_capture_service.dart';

class AudioSyncProvider extends ChangeNotifier {
  final AudioCaptureService _audioService = AudioCaptureService();
  List<AudioDeviceInfo> _microphones = [];
  AudioDeviceInfo? _selectedMicrophone;

  AudioSyncState _state = const AudioSyncState();

  AudioSyncProvider() {
    _initMicrophones();
  }

  AudioSyncState get state => _state;
  List<AudioDeviceInfo> get microphones => _microphones;
  AudioDeviceInfo? get selectedMicrophone => _selectedMicrophone;
  bool get isListening => _state.isListening;
  bool get isMuted => _state.isMuted;

  Future<void> _initMicrophones() async {
    _microphones = await AudioCaptureService.getAvailableMicrophones();
    if (_microphones.isNotEmpty) {
      _selectedMicrophone = _microphones.first;
    }
    notifyListeners();
  }

  void selectMicrophone(AudioDeviceInfo mic) {
    _selectedMicrophone = mic;
    if (_state.isListening) {
      startListening();
    } else {
      notifyListeners();
    }
  }

  void startListening() {
    _audioService.startListening(
      deviceId: _selectedMicrophone?.id,
      sensitivity: _state.sensitivity,
      vadThreshold: _state.vadThreshold,
      onUpdate: (updatedState) {
        _state = updatedState;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _audioService.stopListening();
    _state = _audioService.state;
    notifyListeners();
  }

  void toggleListening() {
    if (_state.isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  void toggleMute() {
    _audioService.toggleMute();
    _state = _audioService.state;
    notifyListeners();
  }

  void setSensitivity(double value) {
    _state = _state.copyWith(sensitivity: value);
    _audioService.updateSettings(sensitivity: value);
    notifyListeners();
  }

  void setVadThreshold(double value) {
    _state = _state.copyWith(vadThreshold: value);
    _audioService.updateSettings(vadThreshold: value);
    notifyListeners();
  }
}
