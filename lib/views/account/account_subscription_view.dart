import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/billing_models.dart';
import '../../providers/billing_provider.dart';
import '../../providers/license_provider.dart';
import '../../widgets/glass_card.dart';

class AccountSubscriptionView extends StatefulWidget {
  const AccountSubscriptionView({super.key});

  @override
  State<AccountSubscriptionView> createState() =>
      _AccountSubscriptionViewState();
}

class _AccountSubscriptionViewState extends State<AccountSubscriptionView> {
  final _keyController = TextEditingController();
  final _emailController = TextEditingController(
    text: 'creator@avatarstudio.io',
  );

  @override
  void dispose() {
    _keyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final licProv = context.watch<LicenseProvider>();
    final billProv = context.watch<BillingProvider>();
    final hasSub = billProv.hasActiveSubscription;
    final sub = billProv.activeSubscription;

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account & Commercial Licensing',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1-Time Lifetime Commercial Studio License (₦200,000 NGN) via Paystack & NOWPayments.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (hasSub)
                  OutlinedButton.icon(
                    onPressed: () =>
                        _confirmCancellation(context, billProv, licProv),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: AppColors.accentRed,
                    ),
                    label: const Text(
                      'RESET LICENSE',
                      style: TextStyle(color: AppColors.accentRed),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // 1. Proactive Renewal Reminder Banner (if not lifetime and expiring soon or expired)
            if (!billProv.isLifetime && (billProv.isExpiringSoon || billProv.isExpired)) ...[
              _buildRenewalAlertBanner(billProv, licProv),
              const SizedBox(height: 20),
            ],

            // 2. Access Code Display Box (When active subscription/license exists)
            if (hasSub && sub != null && sub.accessCode.isNotEmpty) ...[
              _buildAccessCodeDisplayCard(context, sub),
              const SizedBox(height: 20),
            ],

            // 3. Subscription Status Summary Banner
            GlassCard(
              borderColor: hasSub
                  ? AppColors.accentGreen
                  : AppColors.primaryCyan,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          (hasSub
                                  ? AppColors.accentGreen
                                  : AppColors.primaryCyan)
                              .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasSub ? Icons.auto_awesome : Icons.verified,
                      size: 32,
                      color: hasSub
                          ? AppColors.accentGreen
                          : AppColors.primaryCyan,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasSub
                              ? (sub!.isLifetime
                                  ? 'ACTIVE 1-TIME LIFETIME STUDIO LICENSE'
                                  : 'ACTIVE 30-DAY SUBSCRIPTION')
                              : 'COMMUNITY EDITION (FREE LOCAL DESKTOP)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: hasSub
                                ? AppColors.accentGreen
                                : AppColors.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasSub
                              ? (sub!.isLifetime
                                  ? 'TD-AVATAR-STUDIO LIFETIME LICENSE (₦200,000)'
                                  : '${sub.tier.name.toUpperCase()} — ${sub.daysRemaining} Days Remaining')
                              : licProv.entitlements.statusLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasSub
                              ? (sub!.isLifetime
                                  ? 'Activated on ${sub.activatedAt.toLocal().toString().split(' ').first} • Permanent Commercial Ownership (No Recurring Fees)'
                                  : 'Activated on ${sub.activatedAt.toLocal().toString().split(' ').first} • Renews on ${sub.renewsAt.toLocal().toString().split(' ').first}')
                              : 'Unlimited local desktop rendering. Upgrade below to generate your 1-Time Lifetime Access Code (₦200,000) for commercial streaming.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Commercial Studio License Plan
            const Text(
              '1-Time Lifetime Commercial Studio License',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Row(
              children: BillingPlan.all.map((plan) {
                final isSelected = billProv.selectedPlan.id == plan.id;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () => billProv.selectPlan(plan),
                      borderRadius: BorderRadius.circular(12),
                      child: GlassCard(
                        borderColor: isSelected
                            ? AppColors.primaryCyan
                            : AppColors.borderSubtle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: AppColors.primaryCyan,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              plan.formattedPrice,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...plan.features.map(
                              (f) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: AppColors.statusOnline,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 5. Payment Gateway Selection
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method & 1-Time Checkout',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'After completing the 1-time payment of ₦200,000 (or \$135 crypto), a permanent Lifetime Access Code (TD-LIFE-XXXX-YYYY) is generated and unlocked on this installation.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildGatewayTile(
                          gateway: PaymentGateway.paystack,
                          title: 'Paystack (₦200,000 NGN)',
                          subtitle: 'Cards, Bank Transfer, USSD (Instant Lifetime Access)',
                          icon: Icons.credit_card,
                          isSelected:
                              billProv.selectedGateway ==
                              PaymentGateway.paystack,
                          onSelect: () => billProv.selectGateway(
                            PaymentGateway.paystack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGatewayTile(
                          gateway: PaymentGateway.nowpayments,
                          title: 'NOWPayments Crypto (\$135 USD)',
                          subtitle: 'USDT, BTC, ETH, Solana, BNB (Instant Lifetime Access)',
                          icon: Icons.currency_bitcoin,
                          isSelected:
                              billProv.selectedGateway ==
                              PaymentGateway.nowpayments,
                          onSelect: () => billProv.selectGateway(
                            PaymentGateway.nowpayments,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Billing Email Field
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText:
                          'Customer Email for Lifetime License Receipt & Access Code',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Checkout Action Button
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: billProv.isProcessing
                            ? null
                            : () => billProv.initiateMonthlyCheckout(
                                customerEmail: _emailController.text,
                                licenseProvider: licProv,
                              ),
                        icon: const Icon(Icons.lock, size: 16),
                        label: Text(
                          billProv.isProcessing
                              ? 'PREPARING CHECKOUT...'
                              : 'GET 1-TIME LIFETIME ACCESS VIA ${billProv.selectedGateway == PaymentGateway.paystack ? 'PAYSTACK (₦200,000)' : 'NOWPAYMENTS (\$135)'}',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (billProv.currentReference != null)
                        OutlinedButton.icon(
                          onPressed: billProv.isProcessing
                              ? null
                              : () => billProv.verifyAndActivatePayment(
                                  licenseProvider: licProv,
                                ),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('VERIFY & GET LIFETIME ACCESS CODE'),
                        ),
                    ],
                  ),

                  // Active Session Info Box
                  if (billProv.statusMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgDarkest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                billProv.status == PaymentStatus.completed
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                size: 16,
                                color:
                                    billProv.status == PaymentStatus.completed
                                    ? AppColors.statusOnline
                                    : AppColors.primaryCyan,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  billProv.statusMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (billProv.currentCheckoutUrl != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    billProv.currentCheckoutUrl!,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: AppColors.primaryCyan,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 14),
                                  tooltip: 'Copy Checkout Link',
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: billProv.currentCheckoutUrl!,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Checkout link copied!'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 6. Manual Access Code Activation Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activate with Access Code / License Key',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Already have a Lifetime Access Code (e.g., TD-LIFE-XXXX-YYYY from email receipt or previous purchase)? Enter it below to unlock this installation immediately.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _keyController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. TD-LIFE-7E1A-884F or TD-PRO-7E1A-884F',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: billProv.isProcessing
                            ? null
                            : () async {
                                final success = await billProv.activateWithAccessCode(
                                  _keyController.text,
                                  licenseProvider: licProv,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Access Code activated successfully!'
                                            : (billProv.statusMessage ??
                                                'Failed to activate Access Code'),
                                      ),
                                      backgroundColor: success
                                          ? AppColors.statusOnline
                                          : AppColors.accentRed,
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.vpn_key, size: 16),
                        label: const Text('ACTIVATE ACCESS CODE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryCyan,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessCodeDisplayCard(BuildContext context, SubscriptionRecord sub) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.15),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_outlined, size: 20, color: AppColors.primaryCyan),
              const SizedBox(width: 10),
              Text(
                sub.isLifetime ? 'YOUR LIFETIME ACCESS CODE' : 'YOUR 30-DAY ACCESS CODE',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.primaryCyan,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusOnline.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sub.isLifetime ? 'LIFETIME ACTIVE' : '${sub.daysRemaining} DAYS REMAINING',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.statusOnline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgDarkest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    sub.accessCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sub.accessCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Access Code copied to clipboard!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('COPY CODE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep this code safe. You can use it to re-activate this installation or transfer your commercial studio license.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalAlertBanner(BillingProvider billProv, LicenseProvider licProv) {
    final isExpired = billProv.isExpired;
    final color = isExpired ? AppColors.accentRed : AppColors.statusWarning;
    final sub = billProv.activeSubscription;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.cancel : Icons.access_time_filled,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpired
                      ? '30-DAY ACCESS CODE EXPIRED'
                      : 'RENEWAL REMINDER: ${billProv.daysRemaining} DAYS REMAINING',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isExpired
                      ? 'Your 30-day subscription ended on ${sub?.renewsAt.toLocal().toString().split(' ').first}. Renew now to generate a new 30-day Access Code.'
                      : 'Your 30-day subscription expires on ${sub?.renewsAt.toLocal().toString().split(' ').first}. Click below to renew and get your next 30-day code.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            onPressed: () => billProv.initiateMonthlyCheckout(
              customerEmail: _emailController.text,
              licenseProvider: licProv,
            ),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('RENEW NOW'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayTile({
    required PaymentGateway gateway,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryCyan.withValues(alpha: 0.12)
              : AppColors.bgDarkest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryCyan : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? AppColors.primaryCyan
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancellation(
    BuildContext context,
    BillingProvider billProv,
    LicenseProvider licProv,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Cancel Monthly Subscription?'),
        content: const Text(
          'Your active monthly subscription will be cancelled and your account will revert to the Free Community Edition.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('KEEP SUBSCRIPTION'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            onPressed: () {
              billProv.cancelSubscription(licenseProvider: licProv);
              Navigator.pop(ctx);
            },
            child: const Text('CONFIRM CANCEL'),
          ),
        ],
      ),
    );
  }
}
