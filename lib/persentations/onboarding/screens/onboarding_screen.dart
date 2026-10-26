import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terator/core/styles.dart';
import 'package:terator/data/letter_categories.dart';
import 'package:terator/data/letter_data.dart';
import 'package:terator/persentations/account/account_cubits/cubit/account_cubit.dart';
import 'package:terator/persentations/account/screens/account_create_screen.dart';
import 'package:terator/persentations/kop_surat/screens/kop_surat_screen.dart';
import 'package:terator/persentations/letters/screens/letter_screen.dart';
import 'package:terator/persentations/navbar.dart';
import 'package:terator/persentations/subscription/cubit/subscription_cubit.dart';
import 'package:terator/persentations/subscription/widgets/premium_gate.dart';
import 'package:terator/repositories/account_repository.dart';
import 'package:terator/repositories/kop_surat_repository.dart';
import 'package:terator/utils/custom_snackbar.dart';

/// Guided setup: the user actually creates an Akun Surat, (optionally) sets
/// up a kop surat, then picks a template and goes through the real editor
/// flow. The editor ends on File Saya, which replaces this screen.
class OnboardingScreen extends StatefulWidget {
  /// Opened again from Pengaturan → Panduan Aplikasi: finishing just pops.
  final bool fromSettings;
  const OnboardingScreen({super.key, this.fromSettings = false});

  static const String doneKey = 'onboarding_done';

  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(doneKey) ?? false;
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(doneKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _StepInfo {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String description;
  const _StepInfo(
      this.label, this.icon, this.gradient, this.title, this.description);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _stepAccount = 0;
  static const int _stepKop = 1;
  static const int _stepTemplate = 2;

  static const List<_StepInfo> _steps = [
    _StepInfo(
      'Akun',
      Icons.person_add_alt_1_rounded,
      kGradientSekolah,
      'Buat Akun Surat',
      'Simpan data diri seperti nama, alamat, pendidikan, dan tanda tangan. '
          'Cukup sekali, otomatis terisi di semua surat.',
    ),
    _StepInfo(
      'Kop',
      Icons.article_rounded,
      [Color(0xFFD97706), Color(0xFFF59E0B)],
      'Atur Kop Surat',
      'Tambahkan kop dengan logo dan identitas instansi. Langkah ini '
          'opsional dan khusus pengguna Premium.',
    ),
    _StepInfo(
      'Template',
      Icons.description_rounded,
      kGradientPekerjaan,
      'Pilih Template & Buat Surat',
      'Pilih kategori, buka template, isi data surat, lalu simpan sebagai '
          'PDF. Surat tersimpan otomatis di menu File Saya.',
    ),
  ];

  final AccountRepository _accountRepo = AccountRepository();
  final KopSuratRepository _kopRepo = KopSuratRepository();

  int _step = 0;
  int _accountCount = 0;
  bool _kopConfigured = false;
  bool _isLoading = true;

  bool get _isLast => _step == _steps.length - 1;
  bool get _hasAccount => _accountCount > 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final accounts = await _accountRepo.all();
    final kop = await _kopRepo.get();
    if (!mounted) return;
    setState(() {
      _accountCount = accounts.length;
      _kopConfigured = kop.isConfigured;
      _isLoading = false;
    });
  }

  Future<void> _finish() async {
    await OnboardingScreen.markDone();
    if (!mounted) return;
    if (widget.fromSettings) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Navbar()),
    );
  }

  void _goTo(int step) => setState(() => _step = step);

  void _next() {
    if (_step == _stepAccount && !_hasAccount) {
      CustomSnackbar.show(context,
          type: SnackbarType.warning,
          message: 'Buat Akun Surat terlebih dahulu');
      return;
    }
    if (_isLast) {
      _finish();
    } else {
      _goTo(_step + 1);
    }
  }

  Future<void> _createAccount() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AccountCreateScreen()),
    );
    if (!mounted) return;
    if (created == true) {
      context.read<AccountCubit>().getAccounts(isInit: true);
    }
    final hadAccount = _hasAccount;
    await _refresh();
    // First account just created: move on to the next step.
    if (!hadAccount && _hasAccount && _step == _stepAccount) {
      _goTo(_stepKop);
    }
  }

  Future<void> _setupKop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KopSuratScreen()),
    );
    await _refresh();
  }

  Future<void> _openCategory(Map<String, dynamic> cat) async {
    // The editor flow ends by replacing the whole stack with File Saya, so
    // the guide counts as done once the user starts on a template.
    await OnboardingScreen.markDone();
    if (!mounted) return;
    final category = LetterData.listLetters(q: '')[cat['index']];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LetterScreen(
          letters: category['letters'],
          title: category['title'],
        ),
      ),
    );
  }

  bool _isStepDone(int step) {
    switch (step) {
      case _stepAccount:
        return _hasAccount;
      case _stepKop:
        return _kopConfigured;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimary))
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: SingleChildScrollView(
                        key: ValueKey(_step),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: _buildStepContent(),
                      ),
                    ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Memulai',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ikuti langkah berikut untuk membuat surat pertamamu',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _finish,
            child: const Text(
              'Lewati',
              style: TextStyle(
                color: kTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Horizontal stepper: numbered circles joined by lines ───
  Widget _buildStepIndicator() {
    final children = <Widget>[];
    for (int i = 0; i < _steps.length; i++) {
      if (i > 0) {
        final reached = i <= _step;
        children.add(Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 22),
            color: reached ? kPrimary : Colors.grey.shade300,
          ),
        ));
      }
      children.add(_buildStepDot(i));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(children: children),
    );
  }

  Widget _buildStepDot(int i) {
    final active = i == _step;
    final done = _isStepDone(i) && !active;
    final reached = i <= _step || done;
    return GestureDetector(
      // Jumping ahead still requires an Akun Surat.
      onTap: () => i > _stepAccount && !_hasAccount ? _next() : _goTo(i),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: reached
                  ? const LinearGradient(colors: kGradientPrimary)
                  : null,
              color: reached ? null : kCardWhite,
              border: reached ? null : Border.all(color: Colors.grey.shade300),
              boxShadow: active ? kShadowPrimary : null,
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: reached ? Colors.white : kTextMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _steps[i].label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? kPrimary : kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    final step = _steps[_step];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kRadiusMd),
                  gradient: LinearGradient(
                    colors: step.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(step.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah ${_step + 1} dari ${_steps.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          step.description,
          style: const TextStyle(
            fontSize: 13,
            color: kTextSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildStepAction(),
      ],
    );
  }

  Widget _buildStepAction() {
    switch (_step) {
      case _stepAccount:
        return _buildAccountAction();
      case _stepKop:
        return _buildKopAction();
      case _stepTemplate:
      default:
        return _buildTemplateAction();
    }
  }

  Widget _buildAccountAction() {
    if (!_hasAccount) {
      return AppTheme.gradientButton(
        label: 'Buat Akun Surat',
        width: double.infinity,
        icon: Icons.person_add_rounded,
        onTap: _createAccount,
      );
    }
    return Column(
      children: [
        _statusCard(
          icon: Icons.check_circle_rounded,
          color: kSuccess,
          title: 'Akun Surat siap',
          subtitle: '$_accountCount akun tersimpan dan bisa dipilih saat '
              'membuat surat.',
        ),
        const SizedBox(height: 12),
        _outlinedButton(
          label: 'Tambah Akun Lain',
          icon: Icons.add_rounded,
          onTap: _createAccount,
        ),
      ],
    );
  }

  Widget _buildKopAction() {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (!state.isPremium) {
          return Column(
            children: [
              _statusCard(
                icon: LucideIcons.crown,
                color: const Color(0xFFD97706),
                title: 'Fitur Premium',
                subtitle: 'Kamu bisa mengatur kop surat sekarang, tapi '
                    'memakainya di surat perlu upgrade ke Premium. Kamu juga '
                    'bisa melewati langkah ini.',
              ),
              const SizedBox(height: 12),
              AppTheme.gradientButton(
                label: _kopConfigured ? 'Ubah Kop Surat' : 'Atur Kop Surat',
                width: double.infinity,
                icon: Icons.article_rounded,
                onTap: _setupKop,
              ),
              const SizedBox(height: 10),
              _outlinedButton(
                label: 'Lihat Premium',
                icon: LucideIcons.crown,
                onTap: () => PremiumGate.show(context),
              ),
            ],
          );
        }
        if (_kopConfigured) {
          return Column(
            children: [
              _statusCard(
                icon: Icons.check_circle_rounded,
                color: kSuccess,
                title: 'Kop surat siap',
                subtitle: 'Aktifkan "Gunakan Kop Surat" di halaman detail '
                    'template untuk memakainya.',
              ),
              const SizedBox(height: 12),
              _outlinedButton(
                label: 'Ubah Kop Surat',
                icon: Icons.edit_rounded,
                onTap: _setupKop,
              ),
            ],
          );
        }
        return AppTheme.gradientButton(
          label: 'Atur Kop Surat',
          width: double.infinity,
          icon: Icons.article_rounded,
          onTap: _setupKop,
        );
      },
    );
  }

  Widget _buildTemplateAction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih kategori surat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: letterCategories.length,
          itemBuilder: (context, i) {
            final cat = letterCategories[i];
            return GestureDetector(
              onTap: () => _openCategory(cat),
              child: Container(
                decoration: BoxDecoration(
                  color: kCardWhite,
                  borderRadius: BorderRadius.circular(kRadiusLg),
                  boxShadow: kShadowSm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: cat['gradient'],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(kRadiusSm),
                      ),
                      child: Icon(cat['icon'], color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
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
                  'Buka template → "Gunakan Template" → isi data surat → '
                  'pilih Akun Surat → simpan PDF. Setelah disimpan kamu akan '
                  'diarahkan ke File Saya.',
                  style:
                      TextStyle(fontSize: 12, color: kTextPrimary, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: kTextSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: kPrimary, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: kPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final String nextLabel;
    if (_isLast) {
      nextLabel = 'Selesai';
    } else if (_step == _stepKop && !_kopConfigured) {
      nextLabel = 'Lewati Langkah Ini';
    } else {
      nextLabel = 'Lanjut';
    }
    final bool blocked = _step == _stepAccount && !_hasAccount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      // Fixed height so the outlined and gradient buttons match.
      child: SizedBox(
        height: 52,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusMd),
                    ),
                  ),
                  onPressed: () => _goTo(_step - 1),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: Opacity(
                opacity: blocked ? 0.5 : 1,
                child: AppTheme.gradientButton(
                  label: nextLabel,
                  icon: _isLast
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  padding: EdgeInsets.zero,
                  onTap: _next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
