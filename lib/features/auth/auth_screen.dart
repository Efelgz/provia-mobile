import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/provia_storage.dart';
import '../../core/widgets/provia_components.dart';
import 'landing_view.dart';
import '../../core/widgets/provia_logo.dart';

/// Giriş / Kayıt ekranı. MVP'de hesaplar yalnızca cihazda tutulur;
/// gerçek kimlik doğrulama Faz 3'te (Supabase Auth) eklenecek.
class AuthScreen extends StatefulWidget {
  final ValueChanged<ProviaAccount> onSignedIn;

  const AuthScreen({super.key, required this.onSignedIn});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _departments = [
    'Yazılım Mühendisliği',
    'Bilgisayar Mühendisliği',
    'Yazılım Geliştirme',
    'Yönetim Bilişim Sistemleri',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = false;

  /// true: tanıtım sayfası, false: giriş/kayıt formu.
  bool _showLanding = true;
  bool _obscurePassword = true;
  String _department = _departments.first;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchMode(bool register) {
    setState(() {
      _isRegister = register;
      _error = null;
    });
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final id = ProviaStorage.accountIdForEmail(_emailController.text);
    final existing = ProviaStorage.loadAccount(id);

    if (_isRegister) {
      if (existing != null) {
        setState(
          () => _error =
              'Bu e-posta ile zaten bir hesap var. Giriş yapabilirsin.',
        );
        return;
      }
      final account = ProviaAccount(
        id: id,
        name: _nameController.text.trim(),
        university: '${_universityController.text.trim()} • $_department',
        email: _emailController.text.trim(),
      );
      await ProviaStorage.saveAccount(account);
      widget.onSignedIn(account);
    } else {
      if (existing == null) {
        setState(
          () => _error =
              'Bu e-posta ile kayıtlı hesap bulunamadı. Kayıt olabilir '
              'veya Hızlı Demo Girişi\'ni kullanabilirsin.',
        );
        return;
      }
      widget.onSignedIn(existing);
    }
  }

  String? _required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'E-posta gerekli';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Geçerli bir e-posta gir';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  InputDecoration _decoration(String label, IconData icon) =>
      InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18));

  void _openForm({required bool register}) {
    setState(() {
      _showLanding = false;
      _isRegister = register;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLanding) {
      return LandingView(
        onDemo: () => widget.onSignedIn(ProviaAccount.demo),
        onLogin: () => _openForm(register: false),
        onRegister: () => _openForm(register: true),
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProviaSegmented<bool>(
            expand: true,
            value: _isRegister,
            onChanged: _switchMode,
            segments: const [
              ProviaSegment(false, 'Giriş Yap'),
              ProviaSegment(true, 'Kayıt Ol'),
            ],
          ),
          const SizedBox(height: 20),
          if (_isRegister) ...[
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: _decoration('Ad Soyad', LucideIcons.user),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Ad soyad en az 3 karakter olmalı'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _universityController,
              textInputAction: TextInputAction.next,
              decoration: _decoration('Üniversite', LucideIcons.graduationCap),
              validator: (v) => _required(v, 'Üniversite gerekli'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _department,
              isExpanded: true,
              dropdownColor: ProviaTheme.surfaceElevated,
              decoration: _decoration('Bölüm', LucideIcons.bookOpen),
              items: [
                for (final d in _departments)
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) => setState(() => _department = v ?? _department),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _decoration('E-posta', LucideIcons.mail),
            validator: _validateEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onFieldSubmitted: (_) => _submit(),
            decoration: _decoration('Şifre', LucideIcons.lock).copyWith(
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Şifreyi göster' : 'Şifreyi gizle',
                icon: Icon(
                  _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: _validatePassword,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ProviaTheme.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ProviaTheme.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            child: Text(_isRegister ? 'Hesap Oluştur' : 'Giriş Yap'),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'veya',
                  style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => widget.onSignedIn(ProviaAccount.demo),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
            icon: const Icon(LucideIcons.play, size: 13),
            label: const Text('Hızlı Demo Girişi'),
          ),
          const SizedBox(height: 8),
          Text(
            'Demo hesabı: Deniz Aydın · 1450 XP · 1 aktif proje',
            textAlign: TextAlign.center,
            style: ProviaTheme.mono(
              size: 11,
              weight: FontWeight.w500,
              color: ProviaTheme.textSubtle,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 24),
                      ProviaCard(
                        padding: const EdgeInsets.all(20),
                        child: form,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'MVP: Hesap bilgileri yalnızca bu cihazda saklanır, '
                        'şifre kaydedilmez ve doğrulanmaz. Gerçek kimlik '
                        'doğrulama sonraki sürümde eklenecek.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ProviaTheme.textSubtle,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                onPressed: () => setState(() => _showLanding = true),
                style: TextButton.styleFrom(
                  foregroundColor: ProviaTheme.textMuted,
                  minimumSize: const Size(0, 44),
                ),
                icon: const Icon(LucideIcons.arrowLeft, size: 16),
                label: const Text('Ana Sayfa'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProviaLogo(height: 44, showTagline: true),
        const SizedBox(height: 24),
        Text(
          'Hesabına giriş yap',
          textAlign: TextAlign.center,
          style: ProviaTheme.heading(size: 20),
        ),
        const SizedBox(height: 8),
        const Text(
          'İlk stajından önce gerçek projelerle deneyim kazan.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ProviaTheme.textMuted,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
