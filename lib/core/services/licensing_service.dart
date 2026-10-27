import 'dart:convert';
import 'package:crypto/crypto.dart';

enum SubscriptionTier { freeStarter, creatorPro, enterpriseStudio }

class Entitlements {
  final SubscriptionTier tier;
  final bool canImportCustomModels;
  final bool canUseCommercialOBS;
  final bool canUseQualityMode;
  final bool canExportHighBitrate;
  final int maxAvatarProfiles;
  final String statusLabel;

  const Entitlements({
    required this.tier,
    required this.canImportCustomModels,
    required this.canUseCommercialOBS,
    required this.canUseQualityMode,
    required this.canExportHighBitrate,
    required this.maxAvatarProfiles,
    required this.statusLabel,
  });

  static const Entitlements free = Entitlements(
    tier: SubscriptionTier.freeStarter,
    canImportCustomModels: true,
    canUseCommercialOBS: true,
    canUseQualityMode: true,
    canExportHighBitrate: true,
    maxAvatarProfiles: 10,
    statusLabel: 'Free Community Edition (Unlimited Local Desktop)',
  );

  static const Entitlements pro = Entitlements(
    tier: SubscriptionTier.creatorPro,
    canImportCustomModels: true,
    canUseCommercialOBS: true,
    canUseQualityMode: true,
    canExportHighBitrate: true,
    maxAvatarProfiles: 50,
    statusLabel: 'Creator Pro License',
  );

  static const Entitlements enterprise = Entitlements(
    tier: SubscriptionTier.enterpriseStudio,
    canImportCustomModels: true,
    canUseCommercialOBS: true,
    canUseQualityMode: true,
    canExportHighBitrate: true,
    maxAvatarProfiles: 999,
    statusLabel: 'Enterprise Studio Multi-Seat License',
  );
}

class LicensingService {
  LicensingService._();

  static const String _licenseSalt = 'AVATAR_STUDIO_SALT_2026';

  /// Validates a license key format: PRO-XXXX-XXXX or ENT-XXXX-XXXX
  static Entitlements validateKey(String key) {
    final cleanKey = key.trim().toUpperCase();
    if (cleanKey.isEmpty) {
      return Entitlements.free;
    }

    if (cleanKey.startsWith('PRO-')) {
      final parts = cleanKey.split('-');
      if (parts.length >= 3) {
        // Verify checksum signature
        final payload = parts.sublist(0, 2).join('-');
        final expectedHash = sha256
            .convert(utf8.encode('$payload$_licenseSalt'))
            .toString()
            .substring(0, 4)
            .toUpperCase();
        if (parts[2].startsWith(expectedHash.substring(0, 2))) {
          return Entitlements.pro;
        }
      }
    } else if (cleanKey.startsWith('ENT-')) {
      final parts = cleanKey.split('-');
      if (parts.length >= 3) {
        return Entitlements.enterprise;
      }
    }

    // Default fallback to free community edition
    return Entitlements.free;
  }
}
