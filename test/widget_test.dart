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

    test(
      'LicensingService offline validation produces correct entitlements',
      () {
        final free = LicensingService.validateKey('');
        expect(free.tier, SubscriptionTier.freeStarter);
        expect(free.canUseCommercialOBS, isTrue);

        final proKey = 'PRO-TEST-C0A1';
        final res = LicensingService.validateKey(proKey);
        expect(res, isNotNull);
      },
    );

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
      'BillingProvider manages monthly plans, gateways, and activation lifecycle',
      () async {
        final storage = StorageService();
        await storage.init();
        final licenseProvider = LicenseProvider();
        final billingProvider = BillingProvider(storageService: storage);

        expect(billingProvider.selectedPlan.id, 'creator_pro_monthly');
        expect(billingProvider.selectedPlan.priceUsd, 19.0);
        expect(billingProvider.selectedGateway, PaymentGateway.paystack);

        // Select Enterprise Plan
        billingProvider.selectPlan(BillingPlan.enterpriseStudioMonthly);
        expect(billingProvider.selectedPlan.priceUsd, 79.0);

        // Select NOWPayments Gateway
        billingProvider.selectGateway(PaymentGateway.nowpayments);
        expect(billingProvider.selectedGateway, PaymentGateway.nowpayments);

        // Initiate checkout
        await billingProvider.initiateMonthlyCheckout(
          customerEmail: 'creator@avatarstudio.io',
          licenseProvider: licenseProvider,
        );
        expect(billingProvider.currentReference, isNotNull);
        expect(billingProvider.currentCheckoutUrl, isNotNull);

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

        // Cancel subscription
        await billingProvider.cancelSubscription(
          licenseProvider: licenseProvider,
        );
        expect(billingProvider.hasActiveSubscription, isFalse);
        expect(licenseProvider.tier, SubscriptionTier.freeStarter);
      },
    );

    test('PaystackService initializes checkout and verifies transactions', () async {
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
    });

    test('NowPaymentsService creates crypto invoice and verifies payment', () async {
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
    });

    test('BillingProvider manages monthly plans, gateways, and activation lifecycle', () async {
      final storage = StorageService();
      await storage.init();
      final licenseProvider = LicenseProvider();
      final billingProvider = BillingProvider(storageService: storage);

      expect(billingProvider.selectedPlan.id, 'creator_pro_monthly');
      expect(billingProvider.selectedPlan.priceUsd, 19.0);
      expect(billingProvider.selectedGateway, PaymentGateway.paystack);

      // Select Enterprise Plan
      billingProvider.selectPlan(BillingPlan.enterpriseStudioMonthly);
      expect(billingProvider.selectedPlan.priceUsd, 79.0);

      // Select NOWPayments Gateway
      billingProvider.selectGateway(PaymentGateway.nowpayments);
      expect(billingProvider.selectedGateway, PaymentGateway.nowpayments);

      // Initiate checkout
      await billingProvider.initiateMonthlyCheckout(
        customerEmail: 'creator@avatarstudio.io',
        licenseProvider: licenseProvider,
      );
      expect(billingProvider.currentReference, isNotNull);
      expect(billingProvider.currentCheckoutUrl, isNotNull);

      // Verify and activate
      final activated = await billingProvider.verifyAndActivatePayment(
        licenseProvider: licenseProvider,
      );
      expect(activated, isTrue);
      expect(billingProvider.hasActiveSubscription, isTrue);
      expect(billingProvider.activeSubscription?.daysRemaining, greaterThanOrEqualTo(29));
      expect(licenseProvider.isPro, isTrue);

      // Cancel subscription
      await billingProvider.cancelSubscription(licenseProvider: licenseProvider);
      expect(billingProvider.hasActiveSubscription, isFalse);
      expect(licenseProvider.tier, SubscriptionTier.freeStarter);
    });
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
