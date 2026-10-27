import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avatar_studio/main.dart';
import 'package:avatar_studio/core/constants/default_avatars.dart';
import 'package:avatar_studio/core/services/licensing_service.dart';
import 'package:avatar_studio/core/services/storage_service.dart';
import 'package:avatar_studio/core/utils/path_sanitizer.dart';
import 'package:avatar_studio/models/avatar_model.dart';
import 'package:avatar_studio/models/billing_models.dart';
import 'package:avatar_studio/providers/billing_provider.dart';
import 'package:avatar_studio/providers/license_provider.dart';
import 'package:avatar_studio/services/audio/viseme_extractor.dart';
import 'package:avatar_studio/services/billing/nowpayments_service.dart';
import 'package:avatar_studio/services/billing/paystack_service.dart';
import 'package:avatar_studio/services/tracking/pose_filter.dart';

void main() {
  group('Avatar Studio Core Unit Tests', () {
    test('Default sample avatars (Nova, Aria, Zenith) exist and are valid', () {
      final avatars = DefaultAvatars.all;
      expect(avatars.length, 3);
      expect(avatars.any((a) => a.id == 'sample_nova'), isTrue);
      expect(avatars.any((a) => a.id == 'sample_aria'), isTrue);
      expect(avatars.any((a) => a.id == 'sample_zenith'), isTrue);

      final nova = DefaultAvatars.nova;
      expect(nova.name, contains('Nova'));
      expect(nova.type, AvatarType.sampleRigged2D);
    });

    test('AvatarModel JSON serialization and copyWith', () {
      final nova = DefaultAvatars.nova;
      final json = nova.toJson();
      final revived = AvatarModel.fromJson(json);

      expect(revived.id, nova.id);
      expect(revived.name, nova.name);
      expect(revived.styleId, nova.styleId);

      final modified = nova.copyWith(name: 'Nova Updated', scale: 1.25);
      expect(modified.name, 'Nova Updated');
      expect(modified.scale, 1.25);
      expect(modified.id, nova.id);
    });

    test('PoseFilter smooths values without NaN or divergence', () {
      final filter = PoseFilter(initialValue: 0.0, smoothingFactor: 0.5);
      expect(filter.value, 0.0);

      final step1 = filter.filter(1.0);
      expect(step1, 0.5);

      final step2 = filter.filter(1.0);
      expect(step2, 0.75);

      filter.reset(0.0);
      expect(filter.value, 0.0);
    });

    test('VisemeExtractor correctly maps silence and speech to visemes', () {
      final silence = VisemeExtractor.extractViseme(
        levelDb: -55.0,
        vadThreshold: -42.0,
        sensitivity: 1.0,
        formantsRatio: 0.5,
      );
      expect(silence.type, VisemeType.sil);
      expect(silence.mouthOpen, 0.0);

      final activeVowel = VisemeExtractor.extractViseme(
        levelDb: -20.0,
        vadThreshold: -42.0,
        sensitivity: 1.5,
        formantsRatio: 0.5,
      );
      expect(activeVowel.type, VisemeType.aa);
      expect(activeVowel.mouthOpen, greaterThan(0.5));
    });

    test(
      'PathSanitizer cleans dangerous file inputs and validates formats',
      () {
        expect(PathSanitizer.isSupportedModel('avatar.glb'), isTrue);
        expect(PathSanitizer.isSupportedModel('avatar.vrm'), isTrue);
        expect(PathSanitizer.isSupportedModel('malicious.exe'), isFalse);

        expect(PathSanitizer.isSupportedImage('face.png'), isTrue);
        expect(PathSanitizer.isSupportedImage('face.jpg'), isTrue);

        final sanitized = PathSanitizer.sanitizeFileName('../../etc/passwd');
        expect(sanitized, isNot(contains('/')));
        expect(sanitized, isNot(contains('\\')));
        expect(sanitized, 'passwd');
      },
    );

    test('30-Day Access Code generation, signature validation, and expiration check', () {
      // 1. Generate 30-Day Creator Pro Access Code
      final proCode = LicensingService.generate30DayAccessCode(SubscriptionTier.creatorPro);
      expect(proCode, startsWith('TD-PRO-'));

      // Validate code
      final validRes = LicensingService.validateAccessCode(proCode);
      expect(validRes.isValid, isTrue);
      expect(validRes.tier, SubscriptionTier.creatorPro);
      expect(validRes.isExpired, isFalse);
      expect(validRes.daysRemaining, inInclusiveRange(29, 31));

      // 2. Generate Enterprise Studio Code
      final entCode = LicensingService.generate30DayAccessCode(SubscriptionTier.enterpriseStudio);
      expect(entCode, startsWith('TD-ENT-'));
      final entRes = LicensingService.validateAccessCode(entCode);
      expect(entRes.isValid, isTrue);
      expect(entRes.tier, SubscriptionTier.enterpriseStudio);
      expect(entRes.isExpired, isFalse);

      // 3. Expired Access Code check
      final expiredDate = DateTime.now().subtract(const Duration(days: 2));
      final expiredCode = LicensingService.generate30DayAccessCode(
        SubscriptionTier.creatorPro,
        expiresAt: expiredDate,
      );
      final expiredRes = LicensingService.validateAccessCode(expiredCode);
      expect(expiredRes.isValid, isTrue);
      expect(expiredRes.isExpired, isTrue);
      expect(expiredRes.daysRemaining, 0);

      // 4. Invalid signature tampering
      final tamperedCode = '$proCode-TAMPER';
      final tamperedRes = LicensingService.validateAccessCode(tamperedCode);
      expect(tamperedRes.isValid, isFalse);
    });

    test('Renewal Reminder triggers when access code approaches expiration', () {
      final now = DateTime.now();

      // Case 1: Fresh subscription (28 days left) -> Not expiring soon
      final freshSub = SubscriptionRecord(
        subscriptionId: 'sub_fresh',
        gateway: PaymentGateway.paystack,
        reference: 'pstk_test',
        customerEmail: 'creator@avatarstudio.io',
        tier: SubscriptionTier.creatorPro,
        isActive: true,
        activatedAt: now,
        renewsAt: now.add(const Duration(days: 28)),
        amountPaid: 19.0,
        currency: 'USD',
      );
      expect(freshSub.isExpired, isFalse);
      expect(freshSub.isExpiringSoon, isFalse);
      expect(freshSub.daysRemaining, 28);

      // Case 2: Expiring in 4 days -> isExpiringSoon is True (Renewal Reminder alert)
      final expiringSoonSub = SubscriptionRecord(
        subscriptionId: 'sub_soon',
        gateway: PaymentGateway.paystack,
        reference: 'pstk_test',
        customerEmail: 'creator@avatarstudio.io',
        tier: SubscriptionTier.creatorPro,
        isActive: true,
        activatedAt: now.subtract(const Duration(days: 26)),
        renewsAt: now.add(const Duration(days: 4)),
        amountPaid: 19.0,
        currency: 'USD',
      );
      expect(expiringSoonSub.isExpired, isFalse);
      expect(expiringSoonSub.isExpiringSoon, isTrue);
      expect(expiringSoonSub.daysRemaining, 4);

      // Case 3: Expired subscription -> isExpired is True
      final expiredSub = SubscriptionRecord(
        subscriptionId: 'sub_expired',
        gateway: PaymentGateway.paystack,
        reference: 'pstk_test',
        customerEmail: 'creator@avatarstudio.io',
        tier: SubscriptionTier.creatorPro,
        isActive: true,
        activatedAt: now.subtract(const Duration(days: 35)),
        renewsAt: now.subtract(const Duration(days: 5)),
        amountPaid: 19.0,
        currency: 'USD',
      );
      expect(expiredSub.isExpired, isTrue);
      expect(expiredSub.daysRemaining, 0);
    });

    test(
      'PaystackService initializes checkout and verifies transactions',
      () async {
        final service = PaystackService();
        final init = await service.initializeTransaction(
          email: 'creator@avatarstudio.io',
          amountUsd: 19.0,
          reference: 'pstk_test_12345',
        );
        expect(init.success, isTrue);
        expect(init.authorizationUrl, contains('paystack.com'));
        expect(init.reference, 'pstk_test_12345');

        final verify = await service.verifyTransaction('pstk_test_12345');
        expect(verify.isVerified, isTrue);
        expect(verify.status, 'success');
        expect(verify.amount, 19.0);
      },
    );

    test(
      'NowPaymentsService creates crypto invoice and verifies payment',
      () async {
        final service = NowPaymentsService();
        final invoice = await service.createInvoice(
          amountUsd: 19.0,
          orderId: 'now_test_67890',
          description: 'Creator Pro Monthly',
        );
        expect(invoice.success, isTrue);
        expect(invoice.invoiceUrl, contains('nowpayments.io'));
        expect(invoice.orderId, 'now_test_67890');

        final status = await service.checkPaymentStatus('now_test_67890');
        expect(status.isVerified, isTrue);
        expect(status.paymentStatus, 'finished');
      },
    );

    test(
      'BillingProvider generates 30-Day Access Code upon payment and supports direct code activation',
      () async {
        final storage = StorageService();
        await storage.init();
        final licenseProvider = LicenseProvider();
        final billingProvider = BillingProvider(storageService: storage);

        expect(billingProvider.selectedPlan.id, 'creator_pro_monthly');
        expect(billingProvider.selectedPlan.priceUsd, 19.0);
        expect(billingProvider.selectedGateway, PaymentGateway.paystack);

        // Initiate checkout
        await billingProvider.initiateMonthlyCheckout(
          customerEmail: 'creator@avatarstudio.io',
          licenseProvider: licenseProvider,
        );
        expect(billingProvider.currentReference, isNotNull);

        // Verify and activate
        final activated = await billingProvider.verifyAndActivatePayment(
          licenseProvider: licenseProvider,
        );
        expect(activated, isTrue);
        expect(billingProvider.hasActiveSubscription, isTrue);
        expect(
          billingProvider.activeSubscription?.daysRemaining,
          greaterThanOrEqualTo(29),
        );
        expect(licenseProvider.isPro, isTrue);

        // Verify 30-Day Access Code was generated and stored
        final generatedCode = billingProvider.activeAccessCode;
        expect(generatedCode, isNotEmpty);
        expect(generatedCode, startsWith('TD-PRO-'));

        // Test activating with an existing 30-day Access Code
        final newEntCode = LicensingService.generate30DayAccessCode(
          SubscriptionTier.enterpriseStudio,
        );
        final codeActivated = await billingProvider.activateWithAccessCode(
          newEntCode,
          licenseProvider: licenseProvider,
        );
        expect(codeActivated, isTrue);
        expect(billingProvider.activeAccessCode, newEntCode);
        expect(licenseProvider.tier, SubscriptionTier.enterpriseStudio);

        // Cancel subscription
        await billingProvider.cancelSubscription(
          licenseProvider: licenseProvider,
        );
        expect(billingProvider.hasActiveSubscription, isFalse);
        expect(licenseProvider.tier, SubscriptionTier.freeStarter);
      },
    );
  });

  group('Avatar Studio App Widget Tests', () {
    testWidgets('App launches and displays TopStatusBar and Navigation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1366, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AvatarStudioApp());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Top Status Bar check
      expect(find.text('TD-AVATAR-STUDIO'), findsOneWidget);
      expect(find.text('v2.4'), findsOneWidget);

      // Main Navigation items check
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Live Avatar Studio'), findsOneWidget);
      expect(find.text('Avatar Library'), findsOneWidget);
      expect(find.text('OBS Integration'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);

      // Welcome header on Dashboard check
      expect(find.text('Welcome to TD-Avatar-Studio'), findsOneWidget);
    });
  });
}
