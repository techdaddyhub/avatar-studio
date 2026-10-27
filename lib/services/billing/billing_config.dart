class BillingConfig {
  BillingConfig._();

  // Paystack standard endpoints
  static const String paystackBaseUrl = 'https://api.paystack.co';

  // NOWPayments endpoints
  static const String nowPaymentsBaseUrl = 'https://api.nowpayments.io/v1';
  static const String nowPaymentsSandboxUrl =
      'https://api-sandbox.nowpayments.io/v1';

  // Default keys (can be configured or overridden in app settings)
  // Paystack public test key format
  static String paystackPublicKey = 'pk_test_avatar_studio_community_key';
  static String paystackSecretKey = 'sk_test_avatar_studio_community_key';

  // NOWPayments API key
  static String nowPaymentsApiKey = 'NOWPAYMENTS_DEMO_STUDIO_API_KEY';
  static bool useNowPaymentsSandbox = true;

  // Local redirect callback URL served by Avatar Studio's local Shelf server
  static const String paystackLocalCallbackUrl =
      'http://127.0.0.1:8088/billing/paystack-callback';
  static const String nowPaymentsLocalCallbackUrl =
      'http://127.0.0.1:8088/billing/nowpayments-callback';
}
