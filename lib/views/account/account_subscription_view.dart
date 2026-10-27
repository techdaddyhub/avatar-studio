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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account & Monthly Subscriptions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Integrated monthly billing via Paystack (Cards/Bank) and NOWPayments (Cryptocurrency).',
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
                      'CANCEL SUBSCRIPTION',
                      style: TextStyle(color: AppColors.accentRed),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Active Subscription Status Banner
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
                              ? 'ACTIVE MONTHLY SUBSCRIPTION'
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
                              ? '${sub!.tier.name.toUpperCase()} — Renews in ${sub.daysRemaining} days'
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
                              ? 'Paid via ${sub!.gateway == PaymentGateway.paystack ? 'Paystack' : 'NOWPayments Crypto'} (Ref: ${sub.reference})'
                              : 'Unlimited local desktop rendering. Upgrade to Monthly Pro for commercial streaming and up to 50 profiles.',
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

            // Monthly Subscription Plans
            const Text(
              'Select Monthly Subscription Plan',
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
                                fontSize: 20,
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

            // Payment Gateway Selection
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method & Billing Gateway',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Paystack Option
                      Expanded(
                        child: _buildGatewayTile(
                          gateway: PaymentGateway.paystack,
                          title: 'Paystack',
                          subtitle: 'Cards, Bank Transfer, Apple Pay, USSD',
                          icon: Icons.credit_card,
                          isSelected:
                              billProv.selectedGateway ==
                              PaymentGateway.paystack,
                          onSelect: () =>
                              billProv.selectGateway(PaymentGateway.paystack),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // NOWPayments Option
                      Expanded(
                        child: _buildGatewayTile(
                          gateway: PaymentGateway.nowpayments,
                          title: 'NOWPayments Crypto',
                          subtitle: 'USDT, Bitcoin, Ethereum, Solana, BNB',
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
                          'Customer Email for Receipt & Subscription Updates',
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
                              : 'SUBSCRIBE VIA ${billProv.selectedGateway == PaymentGateway.paystack ? 'PAYSTACK' : 'NOWPAYMENTS'} (${billProv.selectedPlan.formattedPrice})',
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
                          label: const Text('VERIFY PAYMENT STATUS'),
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

            // Offline License Key Activation Fallback
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Offline License Key Activation (Optional Fallback)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'If you received a pre-purchased offline key (e.g., PRO-XXXX or ENT-XXXX), activate it directly below without internet.',
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
                            hintText: 'e.g. PRO-8821-XXXX or ENT-9941-XXXX',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          licProv.applyLicenseKey(_keyController.text);
                        },
                        child: const Text('ACTIVATE OFFLINE KEY'),
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
