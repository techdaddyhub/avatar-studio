class BillingConfig {
  BillingConfig._();

  // Paystack standard endpoints
  static const String paystackBaseUrl = 'https://api.paystack.co';

  // NOWPayments endpoints
  static const String nowPaymentsBaseUrl = 'https://api.nowpayments.io/v1';
  static const String nowPaymentsSandboxUrl =
      'https://api-sandbox.nowpayments.io/v1';

  // Default keys (can be configured or overridden in app settings / env)
  static String paystackPublicKey = const String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: 'pk_live_avatar_studio_commercial',
  );
  static String paystackSecretKey = const String.fromEnvironment(
    'PAYSTACK_SECRET_KEY',
    defaultValue: 'sk_live_avatar_studio_commercial',
  );

  // NOWPayments Production API Key & Public Key
  static String nowPaymentsApiKey = const String.fromEnvironment(
    'NOWPAYMENTS_API_KEY',
    defaultValue: '316FMKQ-AAE45WB-M480GSF-4M620E7',
  );
  static String nowPaymentsPublicKey = const String.fromEnvironment(
    'NOWPAYMENTS_PUBLIC_KEY',
    defaultValue: '6cffbee0-1ae6-406a-8399-0db59addc5c8',
  );
  static bool useNowPaymentsSandbox = false; // Production Live Mode

  // Local redirect callback URL served by Avatar Studio's local Shelf server
  static const String paystackLocalCallbackUrl =
      'http://127.0.0.1:8088/billing/paystack-callback';
  static const String nowPaymentsLocalCallbackUrl =
      'http://127.0.0.1:8088/billing/nowpayments-callback';
}
