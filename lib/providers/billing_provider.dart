import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/licensing_service.dart';
import '../core/services/storage_service.dart';
import '../models/billing_models.dart';
import '../services/billing/nowpayments_service.dart';
import '../services/billing/paystack_service.dart';
import 'license_provider.dart';

class BillingProvider extends ChangeNotifier {
  final StorageService storageService;
  final PaystackService _paystackService;
  final NowPaymentsService _nowPaymentsService;

  BillingPlan _selectedPlan = BillingPlan.creatorProMonthly;
  PaymentGateway _selectedGateway = PaymentGateway.paystack;
  PaymentStatus _status = PaymentStatus.idle;

  String? _currentCheckoutUrl;
  String? _currentReference;
  String? _statusMessage;
  SubscriptionRecord? _activeSubscription;
  bool _isProcessing = false;

  BillingProvider({
    required this.storageService,
    PaystackService? paystackService,
    NowPaymentsService? nowPaymentsService,
  }) : _paystackService = paystackService ?? PaystackService(),
       _nowPaymentsService = nowPaymentsService ?? NowPaymentsService() {
    _loadSubscription();
  }

  BillingPlan get selectedPlan => _selectedPlan;
  PaymentGateway get selectedGateway => _selectedGateway;
  PaymentStatus get status => _status;
  String? get currentCheckoutUrl => _currentCheckoutUrl;
  String? get currentReference => _currentReference;
  String? get statusMessage => _statusMessage;
  SubscriptionRecord? get activeSubscription => _activeSubscription;
  bool get isProcessing => _isProcessing;
  bool get hasActiveSubscription =>
      _activeSubscription != null &&
      _activeSubscription!.isActive &&
      !_activeSubscription!.isExpired;
  bool get isExpiringSoon =>
      _activeSubscription != null && _activeSubscription!.isExpiringSoon;
  bool get isExpired =>
      _activeSubscription != null && _activeSubscription!.isExpired;
  int get daysRemaining => _activeSubscription?.daysRemaining ?? 0;
  String get activeAccessCode => _activeSubscription?.accessCode ?? '';

  Future<void> _loadSubscription() async {
    _activeSubscription = await storageService.loadSubscription();
    if (_activeSubscription != null && _activeSubscription!.isExpired) {
      _statusMessage =
          'Your 30-Day Access Code has expired. Please renew your subscription.';
    }
    notifyListeners();
  }

  void selectPlan(BillingPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void selectGateway(PaymentGateway gateway) {
    _selectedGateway = gateway;
    notifyListeners();
  }

  /// Initiates monthly subscription checkout via Paystack or NOWPayments
  Future<bool> initiateMonthlyCheckout({
    required String customerEmail,
    required LicenseProvider licenseProvider,
  }) async {
    _isProcessing = true;
    _status = PaymentStatus.pending;
    _statusMessage =
        'Initiating monthly checkout with ${_selectedGateway == PaymentGateway.paystack ? 'Paystack' : 'NOWPayments Crypto'}...';
    notifyListeners();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefix = _selectedGateway == PaymentGateway.paystack ? 'pstk' : 'now';
    _currentReference = '${prefix}_${_selectedPlan.id}_$timestamp';

    try {
      if (_selectedGateway == PaymentGateway.paystack) {
        final result = await _paystackService.initializeTransaction(
          email: customerEmail,
          amountUsd: _selectedPlan.priceUsd,
          reference: _currentReference!,
          planCode: _selectedPlan.paystackPlanCode,
        );

        if (result.success) {
          _currentCheckoutUrl = result.authorizationUrl;
          _statusMessage =
              'Paystack monthly checkout ready. Opening browser...';
          await _launchUrlSafely(_currentCheckoutUrl!);
          _isProcessing = false;
          notifyListeners();
          return true;
        }
      } else {
        // NOWPayments Crypto Invoice
        final result = await _nowPaymentsService.createInvoice(
          amountUsd: _selectedPlan.priceUsd,
          orderId: _currentReference!,
          description:
              'Avatar Studio ${_selectedPlan.title} Monthly Subscription',
        );

        if (result.success) {
          _currentCheckoutUrl = result.invoiceUrl;
          _statusMessage =
              'NOWPayments Crypto invoice generated. Opening browser...';
          await _launchUrlSafely(_currentCheckoutUrl!);
          _isProcessing = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      _status = PaymentStatus.failed;
      _statusMessage = 'Checkout initialization error: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }

    _isProcessing = false;
    notifyListeners();
    return false;
  }

  /// Verifies completed payment with the selected gateway and activates the subscription
  Future<bool> verifyAndActivatePayment({
    required LicenseProvider licenseProvider,
  }) async {
    if (_currentReference == null) return false;

    _isProcessing = true;
    _status = PaymentStatus.verifying;
    _statusMessage =
        'Verifying authorization with ${_selectedGateway == PaymentGateway.paystack ? 'Paystack' : 'NOWPayments'}...';
    notifyListeners();

    bool verified = false;
    double paidAmount = _selectedPlan.priceUsd;
    String currency = 'USD';
    String email = 'creator@avatarstudio.io';

    try {
      if (_selectedGateway == PaymentGateway.paystack) {
        final res = await _paystackService.verifyTransaction(
          _currentReference!,
        );
        verified = res.isVerified;
        if (res.customerEmail.isNotEmpty) email = res.customerEmail;
        if (res.amount > 0) paidAmount = res.amount;
      } else {
        final res = await _nowPaymentsService.checkPaymentStatus(
          _currentReference!,
        );
        verified = res.isVerified;
        if (res.payCurrency != null) currency = res.payCurrency!;
      }

      if (verified) {
        final now = DateTime.now();
        final renewsAt = now.add(const Duration(days: 30));

        // Generate cryptographically signed 30-Day Access Code
        final accessCode = LicensingService.generate30DayAccessCode(
          _selectedPlan.tier,
          expiresAt: renewsAt,
        );

        _activeSubscription = SubscriptionRecord(
          subscriptionId: 'sub_${now.millisecondsSinceEpoch}',
          gateway: _selectedGateway,
          reference: _currentReference!,
          customerEmail: email,
          tier: _selectedPlan.tier,
          isActive: true,
          activatedAt: now,
          renewsAt: renewsAt,
          amountPaid: paidAmount,
          currency: currency,
          accessCode: accessCode,
        );

        await storageService.saveSubscription(_activeSubscription!);

        // Apply access code to license provider
        licenseProvider.applyLicenseKey(accessCode);

        _status = PaymentStatus.completed;
        _statusMessage =
            'Payment confirmed! 30-Day Access Code: $accessCode (Valid for 30 days)';
        _isProcessing = false;
        notifyListeners();
        return true;
      } else {
        _statusMessage =
            'Payment not yet confirmed by gateway. Please complete authorization and try again.';
      }
    } catch (e) {
      _statusMessage = 'Verification error: $e';
    }

    _isProcessing = false;
    notifyListeners();
    return false;
  }

  /// Activates or restores subscription directly using a 30-Day Access Code
  Future<bool> activateWithAccessCode(
    String accessCode, {
    required LicenseProvider licenseProvider,
  }) async {
    _isProcessing = true;
    _status = PaymentStatus.verifying;
    _statusMessage = 'Validating 30-Day Access Code...';
    notifyListeners();

    final result = LicensingService.validateAccessCode(accessCode);
    if (!result.isValid) {
      _isProcessing = false;
      _status = PaymentStatus.failed;
      _statusMessage = result.errorMessage ?? 'Invalid Access Code';
      notifyListeners();
      return false;
    }

    if (result.isExpired) {
      _isProcessing = false;
      _status = PaymentStatus.failed;
      _statusMessage =
          'This 30-Day Access Code expired on ${result.expiresAt.toLocal().toString().split(' ').first}. Please renew.';
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    _activeSubscription = SubscriptionRecord(
      subscriptionId: 'code_${now.millisecondsSinceEpoch}',
      gateway: PaymentGateway.paystack,
      reference: 'access_code_activation',
      customerEmail: 'license@td-avatar-studio.io',
      tier: result.tier,
      isActive: true,
      activatedAt: now,
      renewsAt: result.expiresAt,
      amountPaid:
          result.tier == SubscriptionTier.enterpriseStudio ? 79.0 : 19.0,
      currency: 'USD',
      accessCode: result.code,
    );

    await storageService.saveSubscription(_activeSubscription!);
    licenseProvider.applyLicenseKey(result.code);

    _status = PaymentStatus.completed;
    _statusMessage =
        '30-Day Access Code activated! Active for ${result.daysRemaining} more days.';
    _isProcessing = false;
    notifyListeners();
    return true;
  }

  Future<void> cancelSubscription({
    required LicenseProvider licenseProvider,
  }) async {
    await storageService.clearSubscription();
    _activeSubscription = null;
    licenseProvider.applyLicenseKey(''); // Reset back to Community Edition
    _status = PaymentStatus.idle;
    _statusMessage =
        'Monthly subscription cancelled. Reverted to Community Edition.';
    notifyListeners();
  }

  Future<void> _launchUrlSafely(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
}
