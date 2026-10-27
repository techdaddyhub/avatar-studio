import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final licProv = context.watch<LicenseProvider>();
    final entitlements = licProv.entitlements;

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Account & Subscription Licensing',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Avatar Studio operates completely offline. No internet connection is required to use your local studio.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Active Tier Card
            GlassCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 32,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT ACTIVE LICENSE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entitlements.statusLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Full local studio features active. Unlimited avatar creation and OBS streaming.',
                          style: TextStyle(
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

            // License Key Input Box
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter License Key',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you received a Creator Pro or Enterprise key, enter it below for instant offline activation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

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
                      ElevatedButton(
                        onPressed: () {
                          licProv.applyLicenseKey(_keyController.text);
                        },
                        child: const Text('ACTIVATE KEY'),
                      ),
                    ],
                  ),
                  if (licProv.statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      licProv.statusMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: licProv.isPro
                            ? AppColors.statusOnline
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Comparison Table
            const Text(
              'License Tiers Comparison',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Table(
              border: TableBorder.all(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              children: [
                _buildTableRow([
                  'Feature',
                  'Community Edition',
                  'Creator Pro',
                  'Enterprise Studio',
                ], isHeader: true),
                _buildTableRow([
                  'Local Studio Rendering',
                  '✓ Unlimited',
                  '✓ Unlimited',
                  '✓ Unlimited',
                ]),
                _buildTableRow([
                  'OBS Browser Source (Alpha)',
                  '✓ Included',
                  '✓ Included',
                  '✓ Included',
                ]),
                _buildTableRow([
                  'Real-Time Face & Voice Sync',
                  '✓ Included',
                  '✓ Included',
                  '✓ Included',
                ]),
                _buildTableRow([
                  'Custom Avatar Import (GLB/glTF)',
                  '✓ Included',
                  '✓ Included',
                  '✓ Included',
                ]),
                _buildTableRow([
                  'Max Saved Avatar Profiles',
                  '10 Profiles',
                  '50 Profiles',
                  'Unlimited',
                ]),
                _buildTableRow([
                  'Commercial Livestreaming',
                  'Permitted',
                  'Permitted',
                  'Multi-seat Organization',
                ]),
                _buildTableRow([
                  'Offline Operation Guarantee',
                  '✓ 100% Offline',
                  '✓ 100% Offline',
                  '✓ 100% Offline',
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? AppColors.bgElevated : Colors.transparent,
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            cell,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
              color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
