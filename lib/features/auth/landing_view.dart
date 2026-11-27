import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/provia_components.dart';
import '../../core/widgets/provia_logo.dart';
import '../../models/provia_models.dart';

/// Giriş yapılmamış kullanıcının gördüğü tanıtım sayfası.
class LandingView extends StatefulWidget {
  final VoidCallback onDemo;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LandingView({
    super.key,
    required this.onDemo,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final _howKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _companyKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _companyPreview() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Şirket paneli önizlemesi yol haritasında (Faz 3). Şimdilik '
            'öğrenci deneyimini Hızlı Demo Girişi ile inceleyebilirsin.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= ProviaBreakpoints.desktop;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopNav(
              wide: wide,
              onHow: () => _scrollTo(_howKey),
              onProjects: () => _scrollTo(_projectsKey),
              onCompany: () => _scrollTo(_companyKey),
              onLogin: widget.onLogin,
              onRegister: widget.onRegister,
            ),
            _Hero(
              width: width,
              onRegister: widget.onRegister,
              onProjects: () => _scrollTo(_projectsKey),
              onDemo: widget.onDemo,
            ),
            const Divider(),
            _Section(key: _howKey, child: const _HowItWorks()),
            _Section(
              key: _projectsKey,
              topPadding: 8,
              child: _FeaturedProjects(onOpen: widget.onLogin),
            ),
            _Section(
              key: _companyKey,
              topPadding: 8,
              child: _CompanyCta(onPreview: _companyPreview),
            ),
            const Divider(),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

/// Ortalanmış, en fazla 1160px genişlikte bölüm.
class _Section extends StatelessWidget {
  final Widget child;
  final double topPadding;

  const _Section({super.key, required this.child, this.topPadding = 72});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            wide ? 32 : 20,
            wide ? topPadding : topPadding * 0.6,
            wide ? 32 : 20,
            wide ? 72 : 44,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final bool showName;

  const _Brand({this.showName = true});

  @override
  Widget build(BuildContext context) {
    return showName
        ? const ProviaLogo(height: 28)
        : const ProviaLogoMark(size: 28);
  }
}

class _TopNav extends StatelessWidget {
  final bool wide;
  final VoidCallback onHow;
  final VoidCallback onProjects;
  final VoidCallback onCompany;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _TopNav({
    required this.wide,
    required this.onHow,
    required this.onProjects,
    required this.onCompany,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    Widget link(String label, VoidCallback onTap) => TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: ProviaTheme.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ProviaTheme.borderDark)),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 32 : 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  _Brand(showName: MediaQuery.sizeOf(context).width >= 420),
                  const Spacer(),
                  if (wide) ...[
                    link('Nasıl Çalışır', onHow),
                    link('Projeler', onProjects),
                    link('Şirketler İçin', onCompany),
                    const Spacer(),
                  ],
                  TextButton(
                    onPressed: onLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: ProviaTheme.textPrimary,
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text('Giriş Yap'),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: onRegister,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Kayıt Ol'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final double width;
  final VoidCallback onRegister;
  final VoidCallback onProjects;
  final VoidCallback onDemo;

  const _Hero({
    required this.width,
    required this.onRegister,
    required this.onProjects,
    required this.onDemo,
  });

  @override
  Widget build(BuildContext context) {
    final headlineSize = width >= 900 ? 56.0 : (width >= 600 ? 44.0 : 34.0);
    final projects = ProviaMockData.projects;
    final sponsorCount = projects
        .where((p) => p.isCompanySponsored)
        .map((p) => p.company)
        .toSet()
        .length;
    final taskCount = ProviaMockData.projectTasks.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    return Stack(
      children: [
        _Section(
          topPadding: width >= 600 ? 96 : 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
                  border: Border.all(color: ProviaTheme.borderDark),
                ),
                child: Text(
                  '1. ve 2. sınıf yazılım öğrencileri için',
                  style: ProviaTheme.mono(
                    size: 11,
                    color: ProviaTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Text(
                  'İlk stajından önce deneyim kazan.',
                  style: TextStyle(
                    fontSize: headlineSize,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    letterSpacing: -headlineSize * 0.03,
                    color: ProviaTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: const Text(
                  'Üniversitedeyken gerçek iş senaryolarında takım arkadaşlarınla '
                  'projeler geliştir, GitHub teslimini yapay zekâ destekli '
                  'değerlendirmeyle kanıtla ve şirketlerin seni keşfetmesini sağla.',
                  style: TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRegister,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(LucideIcons.arrowRight, size: 17),
                    label: const Text('Ücretsiz Başla'),
                  ),
                  OutlinedButton(
                    onPressed: onProjects,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      backgroundColor: ProviaTheme.surfaceDark,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Projeleri İncele'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onDemo,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      foregroundColor: ProviaTheme.textPrimary,
                      backgroundColor: ProviaTheme.bgDark.withValues(
                        alpha: 0.06,
                      ),
                      side: BorderSide(color: ProviaTheme.borderDark),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(LucideIcons.play, size: 15),
                    label: const Text('Hızlı Demo Girişi'),
                  ),
                ],
              ),
              const SizedBox(height: 56),
              const Divider(),
              const SizedBox(height: 32),
              ProviaGrid(
                minItemWidth: 150,
                maxColumns: 4,
                spacing: 20,
                children: [
                  _Stat(
                    value: '${projects.length}',
                    label: 'Gerçek proje senaryosu',
                  ),
                  _Stat(value: '$sponsorCount', label: 'Sponsor şirket'),
                  _Stat(value: '$taskCount', label: 'Takım görevi'),
                  const _Stat(value: '3 adım', label: 'GitHub → AI raporu'),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'MVP demo verileri',
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: ProviaTheme.mono(size: 30, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: ProviaTheme.textMuted, fontSize: 14),
        ),
      ],
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = [
    (
      LucideIcons.folderOpen,
      'Proje Seç',
      'Seviyene ve ilgilendiğin teknolojilere uygun gerçek bir iş senaryosuna '
          'veya şirket görevine katıl.',
    ),
    (
      LucideIcons.users,
      'Takım Kur & Geliştir',
      'Frontend, Backend veya UI/UX rolünde takım arkadaşlarınla görevleri '
          'paylaş ve Kanban panosunda ilerle.',
    ),
    (
      LucideIcons.cpu,
      'GitHub & AI Değerlendirmesi',
      'Deponu teslim et; kod kalitesi, mimari ve bireysel katkı tahminini '
          'içeren raporu al.',
    ),
    (
      LucideIcons.briefcase,
      'Portfolyo & Şirket Keşfi',
      'Doğrulanmış projelerinle liderlik tablosunda yüksel, şirketlerin '
          'radarına gir.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Nasıl Çalışır?', style: ProviaTheme.heading(size: 24)),
        const SizedBox(height: 8),
        const Text(
          'Bir yazılım şirketinde çalışma deneyimini 4 net adımda simüle ediyoruz.',
          style: TextStyle(color: ProviaTheme.textMuted, fontSize: 15),
        ),
        const SizedBox(height: 32),
        ProviaGrid(
          minItemWidth: 230,
          maxColumns: 4,
          spacing: 16,
          children: [
            for (var i = 0; i < _steps.length; i++)
              ProviaCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconBox(
                          icon: _steps[i].$1,
                          color: ProviaTheme.textPrimary,
                          size: 40,
                        ),
                        const Spacer(),
                        Text(
                          '0${i + 1}',
                          style: ProviaTheme.mono(
                            size: 13,
                            color: ProviaTheme.textSubtle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _steps[i].$2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _steps[i].$3,
                      style: const TextStyle(
                        color: ProviaTheme.textMuted,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FeaturedProjects extends StatelessWidget {
  final VoidCallback onOpen;

  const _FeaturedProjects({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final featured = ProviaMockData.projects.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Öne Çıkan Gerçek Dünya Projeleri',
          style: ProviaTheme.heading(size: 24),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            const Text(
              'Şirket sponsorlu görevler ve topluluk senaryoları ile gerçek '
              'mühendislik pratiği.',
              style: TextStyle(color: ProviaTheme.textMuted, fontSize: 15),
            ),
            TextButton.icon(
              onPressed: onOpen,
              iconAlignment: IconAlignment.end,
              icon: const Icon(LucideIcons.arrowRight, size: 16),
              label: const Text('Tüm projeleri gör'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        ProviaGrid(
          minItemWidth: 300,
          maxColumns: 3,
          spacing: 16,
          children: [
            for (final p in featured)
              _LandingProjectCard(project: p, onOpen: onOpen),
          ],
        ),
      ],
    );
  }
}

class _LandingProjectCard extends StatelessWidget {
  final ProviaProject project;
  final VoidCallback onOpen;

  const _LandingProjectCard({required this.project, required this.onOpen});

  Color get _difficultyColor => switch (project.difficulty) {
    'Başlangıç' => ProviaTheme.accent,
    'Orta' => ProviaTheme.warning,
    _ => ProviaTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    return ProviaCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: project.isCompanySponsored
                      ? const StatusBadge(
                          label: 'Şirket Sponsorlu',
                          color: ProviaTheme.accent,
                          icon: LucideIcons.building2,
                        )
                      : const StatusBadge(
                          label: 'Topluluk Projesi',
                          color: ProviaTheme.textMuted,
                          icon: LucideIcons.users,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                project.difficulty,
                style: ProviaTheme.mono(size: 12, color: _difficultyColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ProviaTheme.textMuted,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in project.technologies) TechChip(t)],
          ),
          const Spacer(),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  project.company,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 13,
                  ),
                ),
              ),
              const Text(
                'İncele',
                style: TextStyle(
                  color: ProviaTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                LucideIcons.arrowRight,
                size: 14,
                color: ProviaTheme.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyCta extends StatelessWidget {
  final VoidCallback onPreview;

  const _CompanyCta({required this.onPreview});

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.building2, size: 16, color: ProviaTheme.primary),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Şirket Partnerliği',
                style: TextStyle(
                  color: ProviaTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          "CV'ye değil, gerçek koda bakarak yetenek keşfedin.",
          style: ProviaTheme.heading(size: 26),
        ),
        const SizedBox(height: 14),
        const Text(
          'Kendi iş senaryolarınızı proje görevi olarak yayınlayın; öğrencilerin '
          'GitHub teslimlerini, kod kalitesi raporlarını ve bireysel ekip '
          'katkılarını inceleyip başarılı adayları staj mülakatına davet edin.',
          style: TextStyle(
            color: ProviaTheme.textMuted,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ],
    );
    final button = ElevatedButton(
      onPressed: onPreview,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: const Text('Şirket Panelini Önizle'),
    );

    return ProviaCard(
      padding: EdgeInsets.all(
        MediaQuery.sizeOf(context).width >= 600 ? 36 : 22,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 760) {
            return Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: text,
                  ),
                ),
                const SizedBox(width: 32),
                button,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [text, const SizedBox(height: 24), button],
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 8,
            children: [
              const Text(
                '© 2026 PROVIA — Öğrenci Geliştirici Deneyim Platformu (MVP)',
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 13),
              ),
              Text(
                '"İlk stajından önce deneyim kazan."',
                style: ProviaTheme.mono(
                  size: 12,
                  weight: FontWeight.w500,
                  color: ProviaTheme.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
