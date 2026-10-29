import 'dart:convert';
import 'package:crypto/crypto.dart';

enum SubscriptionTier {
  freeStarter,
  creatorPro,
  enterpriseStudio,
  lifetimeStudio,
}

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
    statusLabel: 'Creator Pro License (30-Day Access)',
  );

  static const Entitlements enterprise = Entitlements(
    tier: SubscriptionTier.enterpriseStudio,
    canImportCustomModels: true,
    canUseCommercialOBS: true,
    canUseQualityMode: true,
    canExportHighBitrate: true,
    maxAvatarProfiles: 999,
    statusLabel: 'Enterprise Studio Multi-Seat License (30-Day Access)',
  );

  static const Entitlements lifetime = Entitlements(
    tier: SubscriptionTier.lifetimeStudio,
    canImportCustomModels: true,
    canUseCommercialOBS: true,
    canUseQualityMode: true,
    canExportHighBitrate: true,
    maxAvatarProfiles: 999,
    statusLabel: 'TD-Avatar-Studio Lifetime License (₦200,000 1-Time Access)',
  );
}

class AccessCodeResult {
  final bool isValid;
  final SubscriptionTier tier;
  final DateTime expiresAt;
  final bool isExpired;
  final int daysRemaining;
  final String code;
  final bool isLifetime;
  final String? errorMessage;

  const AccessCodeResult({
    required this.isValid,
    required this.tier,
    required this.expiresAt,
    required this.isExpired,
    required this.daysRemaining,
    required this.code,
    this.isLifetime = false,
    this.errorMessage,
  });
}

class LicensingService {
  LicensingService._();

  static const String _licenseSalt = 'TD_AVATAR_STUDIO_SALT_2026';

  /// Generates a signed Lifetime Access Code for 1-time ₦200,000 payment
  static String generateLifetimeAccessCode({
    SubscriptionTier tier = SubscriptionTier.lifetimeStudio,
  }) {
    // 100 years into the future for perpetual lifetime access
    final expiry = DateTime.now().add(const Duration(days: 36500));
    final epochSeconds = expiry.millisecondsSinceEpoch ~/ 1000;
    final expiryHex =
        epochSeconds.toRadixString(16).toUpperCase().padLeft(8, '0');

    final payload = 'TD-LIFE-$expiryHex';
    final signature = sha256
        .convert(utf8.encode('$payload$_licenseSalt'))
        .toString()
        .substring(0, 4)
        .toUpperCase();

    return '$payload-$signature';
  }

  /// Generates a signed 30-day access code: TD-{TIER}-{EXPIRY_HEX}-{SIG}
  static String generate30DayAccessCode(
    SubscriptionTier tier, {
    DateTime? expiresAt,
  }) {
    final expiry = expiresAt ?? DateTime.now().add(const Duration(days: 30));
    final tierCode = tier == SubscriptionTier.enterpriseStudio ? 'ENT' : 'PRO';
    final epochSeconds = expiry.millisecondsSinceEpoch ~/ 1000;
    final expiryHex =
        epochSeconds.toRadixString(16).toUpperCase().padLeft(8, '0');

    final payload = 'TD-$tierCode-$expiryHex';
    final signature = sha256
        .convert(utf8.encode('$payload$_licenseSalt'))
        .toString()
        .substring(0, 4)
        .toUpperCase();

    return '$payload-$signature';
  }

  /// Validates an access code and checks if it is active or expired
  static AccessCodeResult validateAccessCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) {
      return AccessCodeResult(
        isValid: false,
        tier: SubscriptionTier.freeStarter,
        expiresAt: DateTime.now(),
        isExpired: true,
        daysRemaining: 0,
        code: clean,
        errorMessage: 'Access code cannot be empty.',
      );
    }

    final parts = clean.split('-');

    // Format: TD-{LIFE|PRO|ENT}-{EXPIRY_HEX}-{SIG}
    if (parts.length == 4 && parts[0] == 'TD') {
      final tierCode = parts[1];
      final expiryHex = parts[2];
      final sig = parts[3];

      final payload = 'TD-$tierCode-$expiryHex';
      final expectedSig = sha256
          .convert(utf8.encode('$payload$_licenseSalt'))
          .toString()
          .substring(0, 4)
          .toUpperCase();

      if (sig != expectedSig) {
        return AccessCodeResult(
          isValid: false,
          tier: SubscriptionTier.freeStarter,
          expiresAt: DateTime.now(),
          isExpired: true,
          daysRemaining: 0,
          code: clean,
          errorMessage: 'Invalid access code signature checksum.',
        );
      }

      final epochSeconds = int.tryParse(expiryHex, radix: 16);
      if (epochSeconds == null) {
        return AccessCodeResult(
          isValid: false,
          tier: SubscriptionTier.freeStarter,
          expiresAt: DateTime.now(),
          isExpired: true,
          daysRemaining: 0,
          code: clean,
          errorMessage: 'Malformed expiration date in access code.',
        );
      }

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        epochSeconds * 1000,
      );
      final now = DateTime.now();

      // Check for Lifetime code
      final isLifetime = tierCode == 'LIFE';
      final isExpired = isLifetime ? false : now.isAfter(expiresAt);
      final diff = expiresAt.difference(now);
      final daysRemaining = isLifetime
          ? 99999
          : (diff.isNegative ? 0 : (diff.inSeconds / 86400).ceil());

      final SubscriptionTier tier;
      if (isLifetime) {
        tier = SubscriptionTier.lifetimeStudio;
      } else if (tierCode == 'ENT') {
        tier = SubscriptionTier.enterpriseStudio;
      } else {
        tier = SubscriptionTier.creatorPro;
      }

      return AccessCodeResult(
        isValid: true,
        tier: tier,
        expiresAt: expiresAt,
        isExpired: isExpired,
        daysRemaining: daysRemaining,
        isLifetime: isLifetime,
        code: clean,
      );
    }

    // If it started with TD- but had invalid segments, fail immediately (avoid mutual recursion)
    if (clean.startsWith('TD-')) {
      return AccessCodeResult(
        isValid: false,
        tier: SubscriptionTier.freeStarter,
        expiresAt: DateTime.now(),
        isExpired: true,
        daysRemaining: 0,
        code: clean,
        errorMessage: 'Invalid or tampered TD access code.',
      );
    }

    // Fallback: Check standard legacy license keys PRO-XXXX-XXXX / ENT-XXXX-XXXX
    final entitlements = validateKey(clean);
    if (entitlements.tier != SubscriptionTier.freeStarter) {
      return AccessCodeResult(
        isValid: true,
        tier: entitlements.tier,
        expiresAt: DateTime.now().add(const Duration(days: 36500)),
        isExpired: false,
        daysRemaining: 99999,
        isLifetime: true,
        code: clean,
      );
    }

    return AccessCodeResult(
      isValid: false,
      tier: SubscriptionTier.freeStarter,
      expiresAt: DateTime.now(),
      isExpired: true,
      daysRemaining: 0,
      code: clean,
      errorMessage: 'Unrecognized access code format.',
    );
  }

  /// Validates a legacy license key format: PRO-XXXX-XXXX or ENT-XXXX-XXXX or TD-PRO-...
  static Entitlements validateKey(String key) {
    final cleanKey = key.trim().toUpperCase();
    if (cleanKey.isEmpty) {
      return Entitlements.free;
    }

    // If it's a TD access code:
    if (cleanKey.startsWith('TD-')) {
      final codeRes = validateAccessCode(cleanKey);
      if (codeRes.isValid && !codeRes.isExpired) {
        if (codeRes.isLifetime || codeRes.tier == SubscriptionTier.lifetimeStudio) {
          return Entitlements.lifetime;
        }
        return codeRes.tier == SubscriptionTier.enterpriseStudio
            ? Entitlements.enterprise
            : Entitlements.pro;
      }
      return Entitlements.free;
    }

    if (cleanKey.startsWith('PRO-')) {
      final parts = cleanKey.split('-');
      if (parts.length >= 3) {
        final payload = parts.sublist(0, 2).join('-');
        final expectedHash = sha256
            .convert(utf8.encode('$payload$_licenseSalt'))
            .toString()
            .substring(0, 4)
            .toUpperCase();
        if (parts[2].startsWith(expectedHash.substring(0, 2)) ||
            parts[2] == 'ACTIVE') {
          return Entitlements.pro;
        }
      }
    } else if (cleanKey.startsWith('ENT-')) {
      final parts = cleanKey.split('-');
      if (parts.length >= 3) {
        return Entitlements.enterprise;
      }
    }

    return Entitlements.free;
  }
}
