import '../core/services/licensing_service.dart';

enum BillingInterval { monthly, yearly }

enum PaymentGateway { paystack, nowpayments }

enum PaymentStatus { idle, pending, verifying, completed, failed }

class BillingPlan {
  final String id;
  final String title;
  final SubscriptionTier tier;
  final double priceUsd;
  final BillingInterval interval;
  final List<String> features;
  final String? paystackPlanCode;

  const BillingPlan({
    required this.id,
    required this.title,
    required this.tier,
    required this.priceUsd,
    this.interval = BillingInterval.monthly,
    required this.features,
    this.paystackPlanCode,
  });

  String get formattedPrice => '\$${priceUsd.toStringAsFixed(0)} / mo';

  static const BillingPlan creatorProMonthly = BillingPlan(
    id: 'creator_pro_monthly',
    title: 'Creator Pro',
    tier: SubscriptionTier.creatorPro,
    priceUsd: 19.0,
    interval: BillingInterval.monthly,
    features: [
      'Commercial OBS Livestreaming License',
      'Up to 50 Saved Avatar Profiles',
      'Custom 3D Model Import (GLB, glTF, VRM)',
      'Sub-pixel 60 FPS Canvas Rendering',
      'Full Viseme Acoustic Lip-Sync (AA, EE, OH, CH)',
      'Direct Paystack & Crypto NOWPayments Billing',
    ],
  );

  static const BillingPlan enterpriseStudioMonthly = BillingPlan(
    id: 'enterprise_studio_monthly',
    title: 'Enterprise Studio',
    tier: SubscriptionTier.enterpriseStudio,
    priceUsd: 79.0,
    interval: BillingInterval.monthly,
    features: [
      'Multi-seat Studio Organization License',
      'Unlimited Saved Avatar Profiles',
      'Priority Shader Pipeline & Custom Shaders',
      'Custom Blendshapes & Pose Mapping',
      'Dedicated OBS Studio Integration Support',
      'Monthly Invoicing & Crypto Tax Receipts',
    ],
  );

  static List<BillingPlan> get all => [
    creatorProMonthly,
    enterpriseStudioMonthly,
  ];
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
  });

  bool get isExpired => DateTime.now().isAfter(renewsAt);

  int get daysRemaining {
    final diff = renewsAt.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inSeconds / 86400).ceil();
  }

  int get hoursRemaining {
    final diff = renewsAt.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inSeconds / 3600).ceil();
  }

  bool get isExpiringSoon => !isExpired && daysRemaining <= 5;

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
    };
  }

  factory SubscriptionRecord.fromJson(Map<String, dynamic> json) {
    final tier = SubscriptionTier.values.firstWhere(
      (t) => t.name == json['tier'],
      orElse: () => SubscriptionTier.creatorPro,
    );
    final renewsAt = json['renewsAt'] != null
        ? DateTime.tryParse(json['renewsAt'] as String) ??
              DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));

    final rawAccessCode = json['accessCode'] as String? ?? '';
    final accessCode = rawAccessCode.isNotEmpty
        ? rawAccessCode
        : LicensingService.generate30DayAccessCode(tier, expiresAt: renewsAt);

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
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 19.0,
      currency: json['currency'] as String? ?? 'USD',
      accessCode: accessCode,
    );
  }
}
