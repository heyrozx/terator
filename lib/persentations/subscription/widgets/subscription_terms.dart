import 'package:flutter/material.dart';
import 'package:terator/core/styles.dart';
import 'package:url_launcher/url_launcher.dart';

const String _urlManageSubscriptions =
    'https://play.google.com/store/account/subscriptions?package=com.caraguna.terator';

/// Tautan "Ketentuan Langganan" yang ditampilkan sebelum pengguna membuka
/// paywall. Saat diketuk membuka modal berisi ketentuan lengkap (Kebijakan
/// Langganan Google Play): perpanjangan otomatis, cara membatalkan, dan
/// bahwa langganan tidak wajib.
class SubscriptionTerms extends StatelessWidget {
  const SubscriptionTerms({super.key});

  static Future<void> showDetails(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const _SubscriptionTermsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusSm),
        onTap: () => showDetails(context),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: kPrimary),
              SizedBox(width: 6),
              Text(
                'Lihat Ketentuan Langganan',
                style: TextStyle(
                  color: kPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: kPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Isi modal ketentuan langganan.
class _SubscriptionTermsDialog extends StatelessWidget {
  const _SubscriptionTermsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLg),
      ),
      title: const Text(
        'Ketentuan Langganan',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _term(
              'Langganan diperpanjang otomatis di akhir setiap periode dan '
              'ditagihkan ke akun Google Play Anda, kecuali dibatalkan '
              'paling lambat 24 jam sebelum periode berakhir.',
            ),
            _term(
              'Batalkan kapan saja melalui Google Play Store › Profil › '
              'Pembayaran & langganan › Langganan.',
            ),
            _term(
              'Langganan tidak wajib. Template surat gratis dan fitur dasar '
              'tetap dapat digunakan tanpa berlangganan.',
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse(_urlManageSubscriptions),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text(
                'Kelola langganan di Google Play',
                style: TextStyle(
                  color: kPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: kPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Tutup',
            style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  static Widget _term(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ',
              style: TextStyle(fontSize: 12, color: kTextSecondary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: kTextSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
