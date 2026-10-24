import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terator/core/styles.dart';
import 'package:terator/persentations/subscription/cubit/subscription_cubit.dart';
import 'package:terator/persentations/subscription/widgets/subscription_terms.dart';
import 'package:terator/utils/custom_snackbar.dart';

/// Reusable premium gate modal.
/// Shows a lock screen with upgrade CTA when user is not premium.
class PremiumGate {
  /// Show premium gate bottom sheet.
  /// Returns true if user upgraded successfully.
  static Future<bool> show(BuildContext context) async {
    bool upgraded = false;

    await AppTheme.showModernBottomSheet(
      context: context,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Lock Icon ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kPrimary.withValues(alpha: 0.1),
                      kViolet.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // ─── Title ───
              const Text(
                'Fitur Premium 👑',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upgrade ke Premium untuk mengakses\nsemua fitur tanpa batas!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // ─── Benefits ───
              _buildBenefit(
                Icons.block_rounded,
                'Tanpa Iklan',
                'Nikmati aplikasi tanpa gangguan iklan',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.all_inclusive_rounded,
                'Semua Fitur Premium',
                'Akses penuh ke seluruh fitur aplikasi',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.support_agent_rounded,
                'Prioritas Support',
                'Dapatkan bantuan prioritas dari tim kami',
              ),
              const SizedBox(height: 16),

              // ─── Subscription terms link (Google Play Subscriptions policy) ───
              const SubscriptionTerms(),
              const SizedBox(height: 12),

              // ─── Upgrade Button ───
              Builder(builder: (ctx) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: kGradientPrimary),
                    borderRadius: BorderRadius.circular(kRadiusMd),
                    boxShadow: kShadowPrimary,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadiusMd),
                      ),
                    ),
                    icon: const Icon(LucideIcons.crown, color: Colors.white),
                    label: const Text(
                      'Upgrade ke Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final result =
                          await context.read<SubscriptionCubit>().showPaywall();
                      upgraded = result;
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),

              // ─── Restore button ───
              TextButton(
                onPressed: () async {
                  final result = await context
                      .read<SubscriptionCubit>()
                      .restorePurchases();
                  upgraded = result;
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (result) {
                      CustomSnackbar.show(context,
                          message: "Pembelian berhasil di-restore! 🎉",
                          type: SnackbarType.success);
                    } else {
                      CustomSnackbar.show(context,
                          message: "Tidak ditemukan pembelian sebelumnya",
                          type: SnackbarType.warning);
                    }
                  }
                },
                child: const Text(
                  'Restore Pembelian',
                  style: TextStyle(
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return upgraded;
  }

  static Widget _buildBenefit(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(kRadiusSm),
          ),
          child: Icon(icon, color: kPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: kTextPrimary,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
