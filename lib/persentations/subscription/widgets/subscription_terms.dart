import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:terator/core/styles.dart';
import 'package:url_launcher/url_launcher.dart';

const String _urlManageSubscriptions =
    'https://play.google.com/store/account/subscriptions?package=com.caraguna.terator';

/// Ketentuan langganan yang wajib terlihat sebelum pengguna membuka paywall
/// (Kebijakan Langganan Google Play): harga, periode tagihan, masa uji coba,
/// perpanjangan otomatis, cara membatalkan, dan bahwa langganan tidak wajib.
/// Harga diambil dari Google Play melalui RevenueCat sehingga selalu sesuai
/// dengan yang ditagihkan.
class SubscriptionTerms extends StatefulWidget {
  const SubscriptionTerms({super.key});

  @override
  State<SubscriptionTerms> createState() => _SubscriptionTermsState();
}

class _SubscriptionTermsState extends State<SubscriptionTerms> {
  late final Future<List<Package>> _packages = _loadPackages();

  Future<List<Package>> _loadPackages() async {
    if (kIsWeb) return [];
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      if (kDebugMode) print('RevenueCat offerings error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceVariant,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ketentuan Langganan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Package>>(
            future: _packages,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              final packages = snapshot.data ?? [];
              if (packages.isEmpty) {
                return _term(
                  'Harga dan periode tagihan ditampilkan di halaman paket '
                  'sebelum Anda membayar.',
                );
              }
              return Column(
                children: packages.map(_packageRow).toList(),
              );
            },
          ),
          const SizedBox(height: 6),
          _term(
            'Langganan diperpanjang otomatis di akhir setiap periode dan '
            'ditagihkan ke akun Google Play Anda, kecuali dibatalkan '
            'paling lambat 24 jam sebelum periode berakhir.',
          ),
          _term(
            'Jika ada masa uji coba gratis, tagihan pertama dikenakan '
            'otomatis saat uji coba berakhir kecuali Anda membatalkan '
            'sebelumnya.',
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
    );
  }

  Widget _packageRow(Package package) {
    final product = package.storeProduct;
    final option = product.defaultOption;
    final period =
        option?.billingPeriod ?? option?.fullPricePhase?.billingPeriod;
    final periodLabel = _periodLabel(period);
    final price = periodLabel.isEmpty
        ? product.priceString
        : '${product.priceString} / $periodLabel';

    final trial = option?.freePhase?.billingPeriod;
    final detail = trial != null
        ? 'Gratis ${_duration(trial)}, lalu $price, diperpanjang otomatis'
        : '$price, diperpanjang otomatis';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.workspace_premium_rounded,
                size: 16, color: kPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${_packageName(package, period)}: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: detail),
                ],
              ),
              style: const TextStyle(
                fontSize: 13,
                color: kTextPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _term(String text) {
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

  static String _packageName(Package package, Period? period) {
    switch (package.packageType) {
      case PackageType.weekly:
        return 'Paket Mingguan';
      case PackageType.monthly:
        return 'Paket Bulanan';
      case PackageType.twoMonth:
        return 'Paket 2 Bulan';
      case PackageType.threeMonth:
        return 'Paket 3 Bulan';
      case PackageType.sixMonth:
        return 'Paket 6 Bulan';
      case PackageType.annual:
        return 'Paket Tahunan';
      case PackageType.lifetime:
        return 'Paket Seumur Hidup';
      default:
        return period != null ? 'Paket ${_duration(period)}' : 'Paket Premium';
    }
  }

  /// "bulan", "3 bulan", "tahun", ... untuk teks harga per periode.
  static String _periodLabel(Period? period) {
    if (period == null) return '';
    final unit = _unit(period.unit);
    if (unit.isEmpty) return '';
    return period.value == 1 ? unit : '${period.value} $unit';
  }

  /// "7 hari", "1 bulan", ... untuk lama uji coba / nama paket.
  static String _duration(Period period) {
    final unit = _unit(period.unit);
    return unit.isEmpty ? '' : '${period.value} $unit';
  }

  static String _unit(PeriodUnit unit) {
    switch (unit) {
      case PeriodUnit.day:
        return 'hari';
      case PeriodUnit.week:
        return 'minggu';
      case PeriodUnit.month:
        return 'bulan';
      case PeriodUnit.year:
        return 'tahun';
      default:
        return '';
    }
  }
}
