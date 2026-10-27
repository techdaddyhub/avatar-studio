import 'package:flutter/material.dart';
import '../core/services/licensing_service.dart';

class LicenseProvider extends ChangeNotifier {
  Entitlements _entitlements = Entitlements.free;
  String _activeKey = '';
  String? _statusMessage;

  Entitlements get entitlements => _entitlements;
  SubscriptionTier get tier => _entitlements.tier;
  String get activeKey => _activeKey;
  String? get statusMessage => _statusMessage;

  bool get isPro =>
      _entitlements.tier == SubscriptionTier.creatorPro ||
      _entitlements.tier == SubscriptionTier.enterpriseStudio;

  void applyLicenseKey(String key) {
    _activeKey = key.trim();
    if (_activeKey.isEmpty) {
      _entitlements = Entitlements.free;
      _statusMessage = 'Community Edition active. No key applied.';
      notifyListeners();
      return;
    }

    final result = LicensingService.validateKey(_activeKey);
    _entitlements = result;

    if (result.tier == SubscriptionTier.freeStarter) {
      _statusMessage =
          'Unrecognized license key format. Community edition remains active.';
    } else {
      _statusMessage =
          'License verified successfully! Activated ${_entitlements.statusLabel}.';
    }
    notifyListeners();
  }
}
