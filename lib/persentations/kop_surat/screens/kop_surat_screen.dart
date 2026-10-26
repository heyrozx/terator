import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:terator/core/styles.dart';
import 'package:terator/data/kop_surat_designs.dart';
import 'package:terator/models/kop_surat_model.dart';
import 'package:terator/persentations/kop_surat/screens/kop_design_screen.dart';
import 'package:terator/persentations/kop_surat/widgets/kop_design_preview.dart';
import 'package:terator/persentations/subscription/cubit/subscription_cubit.dart';
import 'package:terator/persentations/subscription/widgets/premium_gate.dart';
import 'package:terator/repositories/kop_surat_repository.dart';
import 'package:terator/utils/custom_snackbar.dart';

class KopSuratScreen extends StatefulWidget {
  const KopSuratScreen({super.key});

  @override
  State<KopSuratScreen> createState() => _KopSuratScreenState();
}

class _KopSuratScreenState extends State<KopSuratScreen> {
  final KopSuratRepository _kopRepo = KopSuratRepository();

  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _addressController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  KopSuratModel _kop = const KopSuratModel();
  String? _savedLogoPath;
  String? _savedSecondaryLogoPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final kop = await _kopRepo.get();
    _nameController.text = kop.institutionName;
    _subtitleController.text = kop.subtitle;
    _addressController.text = kop.address;
    _telephoneController.text = kop.telephone;
    _emailController.text = kop.email;
    _websiteController.text = kop.website;
    if (!mounted) return;
    setState(() {
      _kop = kop;
      _savedLogoPath = kop.logoPath;
      _savedSecondaryLogoPath = kop.secondaryLogoPath;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // Leaving without saving: clean up logos picked in this session.
    if (_kop.logoPath != null && _kop.logoPath != _savedLogoPath) {
      _kopRepo.deleteLogo(_kop.logoPath);
    }
    if (_kop.secondaryLogoPath != null &&
        _kop.secondaryLogoPath != _savedSecondaryLogoPath) {
      _kopRepo.deleteLogo(_kop.secondaryLogoPath);
    }
    _nameController.dispose();
    _subtitleController.dispose();
    _addressController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  KopSuratModel get _currentKop => _kop.copyWith(
        institutionName: _nameController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        address: _addressController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        website: _websiteController.text.trim(),
      );

  Future<void> _pickLogo({bool secondary = false}) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (picked == null) return;
    final storedPath = await _kopRepo.storeLogo(picked.path);
    final current = secondary ? _kop.secondaryLogoPath : _kop.logoPath;
    final saved = secondary ? _savedSecondaryLogoPath : _savedLogoPath;
    // Drop an unsaved logo picked earlier in this session.
    if (current != null && current != saved) {
      await _kopRepo.deleteLogo(current);
    }
    setState(() => _kop = secondary
        ? _kop.copyWith(secondaryLogoPath: storedPath)
        : _kop.copyWith(logoPath: storedPath));
  }

  Future<void> _save() async {
    final kop = _currentKop;
    if (!kop.isConfigured) {
      CustomSnackbar.show(context,
          type: SnackbarType.warning,
          message: 'Isi minimal logo atau nama instansi');
      return;
    }
    await _kopRepo.save(kop);
    if (_savedLogoPath != null && _savedLogoPath != kop.logoPath) {
      await _kopRepo.deleteLogo(_savedLogoPath);
    }
    if (_savedSecondaryLogoPath != null &&
        _savedSecondaryLogoPath != kop.secondaryLogoPath) {
      await _kopRepo.deleteLogo(_savedSecondaryLogoPath);
    }
    _savedLogoPath = kop.logoPath;
    _savedSecondaryLogoPath = kop.secondaryLogoPath;
    if (!mounted) return;
    // Non-premium users may set up the kop to try it out, but it is only
    // applied to letters once they upgrade.
    final isPremium = context.read<SubscriptionCubit>().state.isPremium;
    CustomSnackbar.show(context,
        type: isPremium ? SnackbarType.success : SnackbarType.warning,
        message: isPremium
            ? 'Kop surat berhasil disimpan'
            : 'Kop surat disimpan. Upgrade ke Premium untuk memakainya di surat');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppTheme.modernAppBar(
        title: 'Kop Surat',
        showBack: true,
        context: context,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _buildPremiumBanner(),
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildLogoCard(
                  path: _kop.logoPath,
                  title: 'Logo Utama',
                  onPick: () => _pickLogo(),
                  onRemove: () =>
                      setState(() => _kop = _kop.copyWith(clearLogo: true)),
                ),
                const SizedBox(height: 12),
                _buildLogoCard(
                  path: _kop.secondaryLogoPath,
                  title: 'Logo Kedua (opsional)',
                  onPick: () => _pickLogo(secondary: true),
                  onRemove: () => setState(
                      () => _kop = _kop.copyWith(clearSecondaryLogo: true)),
                ),
                const SizedBox(height: 16),
                _buildFieldsCard(),
                const SizedBox(height: 16),
                _buildDesignTile(),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: AppTheme.gradientButton(
                  label: 'Simpan Kop Surat',
                  icon: Icons.save_rounded,
                  onTap: _save,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
    );
  }

  /// Shown to non-premium users: they can explore and save the kop, but it
  /// is only applied to letters with Premium.
  Widget _buildPremiumBanner() {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (state.isPremium) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFD97706).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.crown, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Kop surat adalah fitur Premium. Kamu bisa mengaturnya sekarang, '
                  'tapi kop baru bisa dipakai di surat setelah upgrade.',
                  style:
                      TextStyle(fontSize: 12, color: kTextPrimary, height: 1.4),
                ),
              ),
              TextButton(
                onPressed: () => PremiumGate.show(context),
                child: const Text(
                  'Upgrade',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBgLavender,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: kPrimary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Setelah disimpan, aktifkan "Gunakan Kop Surat" di halaman detail '
              'surat. Semua surat yang diaktifkan akan memakai kop ini.',
              style: TextStyle(fontSize: 12, color: kTextPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard({
    required String? path,
    required String title,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final logo = KopSuratRepository.logoImage(path);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: kSurfaceVariant,
                borderRadius: BorderRadius.circular(kRadiusMd),
                border: Border.all(color: Colors.grey.shade200),
              ),
              clipBehavior: Clip.antiAlias,
              child: logo != null
                  ? Image(
                      image: logo, fit: BoxFit.contain, gaplessPlayback: true)
                  : const Icon(Icons.add_photo_alternate_rounded,
                      color: kPrimary, size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Gunakan gambar persegi dengan latar transparan/putih',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TextButton(
                      onPressed: onPick,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(logo != null ? 'Ganti Logo' : 'Upload Logo'),
                    ),
                    if (logo != null) ...[
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: onRemove,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          foregroundColor: kError,
                        ),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          AppTheme.sectionHeader(
            icon: Icons.business_rounded,
            title: 'Identitas Instansi',
            subtitle: 'Teks yang tampil di kop surat',
          ),
          _field(_nameController, 'Nama Instansi', 'Contoh: PT Maju Bersama',
              Icons.apartment_rounded),
          _field(_subtitleController, 'Sub-judul / Tagline (opsional)',
              'Contoh: Divisi Sumber Daya Manusia', Icons.short_text_rounded),
          _field(_addressController, 'Alamat',
              'Contoh: Jl. Merdeka No. 17, Jakarta', Icons.location_on_outlined,
              maxLines: 2),
          _field(_telephoneController, 'No. Telepon', 'Contoh: (021) 1234567',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          _field(_emailController, 'Email', 'Contoh: info@majubersama.co.id',
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          _field(_websiteController, 'Website', 'Contoh: www.majubersama.co.id',
              Icons.language_rounded,
              keyboardType: TextInputType.url, last: true),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String hint,
      IconData icon,
      {int maxLines = 1, TextInputType? keyboardType, bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        decoration: AppTheme.inputDecoration(
          label: label,
          hint: hint,
          prefixIcon: icon,
        ),
      ),
    );
  }

  /// Opens [KopDesignScreen]; shows the current default design as a preview.
  Widget _buildDesignTile() {
    final design = KopSuratDesigns.byId(_kop.designId);
    return GestureDetector(
      onTap: () async {
        final designId = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => KopDesignScreen(kop: _currentKop)),
        );
        if (designId != null && mounted) {
          setState(() => _kop = _kop.copyWith(designId: designId));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kRadiusSm),
                  ),
                  child: const Icon(Icons.style_rounded,
                      color: kPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Desain Kop Surat',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: kTextPrimary,
                        ),
                      ),
                      Text(
                        'Default: ${design.name}',
                        style: const TextStyle(
                            fontSize: 12, color: kTextSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: kTextMuted),
              ],
            ),
            const SizedBox(height: 14),
            KopDesignPreview(kop: _currentKop, designId: design.id),
          ],
        ),
      ),
    );
  }
}
