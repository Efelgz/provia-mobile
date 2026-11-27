import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/provia_storage.dart';

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

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    filled: true,
    fillColor: ProviaTheme.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: ProviaTheme.borderDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: ProviaTheme.borderDark),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 28),
                    _ModeToggle(
                      isRegister: _isRegister,
                      onChanged: _switchMode,
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
                        decoration: _decoration(
                          'Üniversite',
                          LucideIcons.graduationCap,
                        ),
                        validator: (v) => _required(v, 'Üniversite gerekli'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _department,
                        isExpanded: true,
                        dropdownColor: ProviaTheme.surfaceDark,
                        decoration: _decoration('Bölüm', LucideIcons.bookOpen),
                        items: [
                          for (final d in _departments)
                            DropdownMenuItem(value: d, child: Text(d)),
                        ],
                        onChanged: (v) =>
                            setState(() => _department = v ?? _department),
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
                      decoration: _decoration('Şifre', LucideIcons.lock)
                          .copyWith(
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Şifreyi göster'
                                  : 'Şifreyi gizle',
                              icon: Icon(
                                _obscurePassword
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                                size: 18,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                      validator: _validatePassword,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProviaTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(_isRegister ? 'Hesap Oluştur' : 'Giriş Yap'),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: ProviaTheme.borderDark)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'veya',
                            style: TextStyle(
                              color: ProviaTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: ProviaTheme.borderDark)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => widget.onSignedIn(ProviaAccount.demo),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ProviaTheme.accent,
                        side: BorderSide(
                          color: ProviaTheme.accent.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(LucideIcons.zap, size: 18),
                      label: const Text('Hızlı Demo Girişi'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hazır demo hesabı: Deniz Aydın • 1450 XP • 1 aktif proje',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ProviaTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'MVP: Hesap bilgileri yalnızca bu cihazda saklanır, şifre '
                      'kaydedilmez ve doğrulanmaz. Gerçek kimlik doğrulama '
                      'sonraki sürümde eklenecek.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ProviaTheme.textMuted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ProviaTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ProviaTheme.primary.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'P',
                style: TextStyle(
                  color: ProviaTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'PROVIA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'İlk stajından önce deneyim kazan.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Şirket destekli gerçek projelerde takımla çalış, katkını '
          'değerlendirt, doğrulanmış portfolyonu oluştur.',
          style: TextStyle(
            color: ProviaTheme.textMuted,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isRegister;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.isRegister, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget option(String label, bool value) {
      final selected = isRegister == value;
      return Expanded(
        child: Material(
          color: selected
              ? ProviaTheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onChanged(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? ProviaTheme.textPrimary
                      : ProviaTheme.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: Row(
        children: [option('Giriş Yap', false), option('Kayıt Ol', true)],
      ),
    );
  }
}
