import '../core/services/licensing_service.dart';

enum BillingInterval { oneTime, monthly, yearly }

enum PaymentGateway { paystack, nowpayments }

enum PaymentStatus { idle, pending, verifying, completed, failed }

class BillingPlan {
  final String id;
  final String title;
  final SubscriptionTier tier;
  final double priceNgn;
  final double priceUsd;
  final String currency;
  final BillingInterval interval;
  final List<String> features;
  final String? paystackPlanCode;

  const BillingPlan({
    required this.id,
    required this.title,
    required this.tier,
    required this.priceNgn,
    required this.priceUsd,
    this.currency = 'NGN',
    this.interval = BillingInterval.oneTime,
    required this.features,
    this.paystackPlanCode,
  });

  String get formattedPrice =>
      currency == 'NGN'
          ? '₦${priceNgn.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} (1-Time)'
          : '\$${priceUsd.toStringAsFixed(0)} (1-Time)';

  /// Official 1-Time Lifetime Studio License: ₦200,000 NGN
  static const BillingPlan lifetimeStudio = BillingPlan(
    id: 'studio_lifetime_200k',
    title: 'TD-Avatar-Studio Lifetime License',
    tier: SubscriptionTier.lifetimeStudio,
    priceNgn: 200000.0,
    priceUsd: 135.0,
    currency: 'NGN',
    interval: BillingInterval.oneTime,
    features: [
      '1-Time Lifetime Commercial Studio License (₦200,000)',
      'Permanent Unrestricted OBS Studio Livestreaming',
      'Unlimited Custom Avatar Uploads (2D & 3D GLB/glTF/VRM)',
      'Sub-pixel 60 FPS Canvas Rendering & Transparent Output',
      'Real-Time Facial Landmark Tracking & Acoustic Lip-Sync',
      'Paystack (Cards, Bank Transfer) & Crypto NOWPayments (USDT/BTC)',
      'Cryptographically Signed Lifetime Access Code',
      'No Recurring Monthly Fees — Pay Once, Own Forever',
    ],
  );

  static List<BillingPlan> get all => [lifetimeStudio];
}

class SubscriptionRecord {
  final String subscriptionId;
  final PaymentGateway gateway;
  final String reference;
  final String customerEmail;
  final SubscriptionTier tier;
  final bool isActive;
  final DateTime activatedAt;
  final DateTime renewsAt;
  final double amountPaid;
  final String currency;
  final String accessCode;
  final bool isLifetime;

  const SubscriptionRecord({
    required this.subscriptionId,
    required this.gateway,
    required this.reference,
    required this.customerEmail,
    required this.tier,
    required this.isActive,
    required this.activatedAt,
    required this.renewsAt,
    required this.amountPaid,
    required this.currency,
    this.accessCode = '',
    this.isLifetime = true,
  });

  bool get isExpired => isLifetime ? false : DateTime.now().isAfter(renewsAt);

  int get daysRemaining {
    if (isLifetime) return 99999;
    final diff = renewsAt.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inSeconds / 86400).ceil();
  }

  int get hoursRemaining {
    if (isLifetime) return 99999;
    final diff = renewsAt.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inSeconds / 3600).ceil();
  }

  bool get isExpiringSoon => !isLifetime && !isExpired && daysRemaining <= 5;

  String get formattedAmountPaid =>
      currency == 'NGN'
          ? '₦${amountPaid.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
          : '\$${amountPaid.toStringAsFixed(0)}';

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'gateway': gateway.name,
      'reference': reference,
      'customerEmail': customerEmail,
      'tier': tier.name,
      'isActive': isActive,
      'activatedAt': activatedAt.toIso8601String(),
      'renewsAt': renewsAt.toIso8601String(),
      'amountPaid': amountPaid,
      'currency': currency,
      'accessCode': accessCode,
      'isLifetime': isLifetime,
    };
  }

  factory SubscriptionRecord.fromJson(Map<String, dynamic> json) {
    final tier = SubscriptionTier.values.firstWhere(
      (t) => t.name == json['tier'],
      orElse: () => SubscriptionTier.lifetimeStudio,
    );
    final isLifetime = json['isLifetime'] as bool? ?? true;
    final renewsAt = json['renewsAt'] != null
        ? DateTime.tryParse(json['renewsAt'] as String) ??
              DateTime.now().add(const Duration(days: 36500))
        : DateTime.now().add(const Duration(days: 36500));

    final rawAccessCode = json['accessCode'] as String? ?? '';
    final accessCode = rawAccessCode.isNotEmpty
        ? rawAccessCode
        : LicensingService.generateLifetimeAccessCode(tier: tier);

    return SubscriptionRecord(
      subscriptionId: json['subscriptionId'] as String,
      gateway: PaymentGateway.values.firstWhere(
        (g) => g.name == json['gateway'],
        orElse: () => PaymentGateway.paystack,
      ),
      reference: json['reference'] as String,
      customerEmail: json['customerEmail'] as String,
      tier: tier,
      isActive: json['isActive'] as bool? ?? false,
      activatedAt: json['activatedAt'] != null
          ? DateTime.tryParse(json['activatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      renewsAt: renewsAt,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 200000.0,
      currency: json['currency'] as String? ?? 'NGN',
      accessCode: accessCode,
      isLifetime: isLifetime,
    );
  }
}
