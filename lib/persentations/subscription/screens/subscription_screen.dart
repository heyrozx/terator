import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terator/core/styles.dart';
import 'package:terator/persentations/subscription/cubit/subscription_cubit.dart';
import 'package:terator/persentations/subscription/widgets/subscription_terms.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.modernAppBar(
        title: 'Langganan',
        showBack: true,
        context: context,
      ),
      backgroundColor: kSurface,
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              // ─── Status Card ───
              _buildStatusCard(context, state),
              const SizedBox(height: 20),

              // ─── Benefits Section ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keuntungan Premium',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitRow(
                      Icons.block_rounded,
                      kError,
                      'Tanpa Iklan',
                      'Nikmati aplikasi tanpa gangguan iklan sama sekali',
                      state.isPremium,
                    ),
                    const SizedBox(height: 14),
                    _buildBenefitRow(
                      Icons.all_inclusive_rounded,
                      kPrimary,
                      'Akses Semua Fitur',
                      'Buka semua fitur premium tanpa batasan',
                      state.isPremium,
                    ),
                    const SizedBox(height: 14),
                    _buildBenefitRow(
                      Icons.bolt_rounded,
                      kWarning,
                      'Update Prioritas',
                      'Dapatkan fitur baru lebih awal',
                      state.isPremium,
                    ),
                    const SizedBox(height: 14),
                    _buildBenefitRow(
                      Icons.support_agent_rounded,
                      kSuccess,
                      'Prioritas Support',
                      'Bantuan prioritas dari tim kami',
                      state.isPremium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Plan Cards ───
              if (!state.isPremium) ...[
                const Text(
                  'Pilih Paket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const SubscriptionTerms(),
                const SizedBox(height: 16),

                // ─── Upgrade Button ───
                Container(
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
                      'Lihat Paket Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      context.read<SubscriptionCubit>().showPaywall();
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Restore Button ───
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final cubit = context.read<SubscriptionCubit>();
                      final result = await cubit.restorePurchases();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result
                                ? 'Pembelian berhasil di-restore! 🎉'
                                : 'Tidak ditemukan pembelian sebelumnya.'),
                            backgroundColor: result ? kSuccess : kTextMuted,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.restore_rounded,
                        color: kTextSecondary, size: 18),
                    label: const Text(
                      'Restore Pembelian',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ─── Status Card ───
  Widget _buildStatusCard(BuildContext context, SubscriptionState state) {
    final isPremium = state.isPremium;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: kGradientPrimary,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadiusXl),
        boxShadow: kShadowPrimary,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(kRadiusMd),
                ),
                child: Icon(
                  isPremium ? LucideIcons.crown : Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Premium Aktif' : 'Akun Gratis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPremium
                          ? 'Nikmati semua fitur tanpa batas!'
                          : 'Upgrade untuk pengalaman terbaik',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isPremium) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(kRadiusSm),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Semua fitur premium telah aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Benefit Row ───
  Widget _buildBenefitRow(
    IconData icon,
    Color color,
    String title,
    String desc,
    bool isPremium,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(kRadiusSm),
          ),
          child: Icon(icon, color: color, size: 20),
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
              const SizedBox(height: 2),
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
        if (isPremium)
          const Icon(Icons.check_circle_rounded, color: kSuccess, size: 20),
      ],
    );
  }
}
