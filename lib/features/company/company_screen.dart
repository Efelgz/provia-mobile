// SAHİBİ: Kişi 1 — Şirket Paneli (önizleme). Şirketlerin proje görevi
// yayınladığı ve öğrenci yetenek havuzunu filtrelediği ekran.
// Bu bir önizlemedir: veriler demo amaçlıdır, kalıcı kaydedilmez.
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/provia_components.dart';

class _Posting {
  final String title;
  final String description;
  final List<String> roles;
  final List<String> technologies;
  final String difficulty;
  final String deadline;
  final int applicants;
  final String status; // Yayında, Taslak, Tamamlandı
  final int xpReward;

  const _Posting({
    required this.title,
    required this.description,
    required this.roles,
    required this.technologies,
    required this.difficulty,
    required this.deadline,
    required this.applicants,
    required this.status,
    required this.xpReward,
  });
}

/// Görev yayınlarken seçilebilen hazır beceriler.
const _roleChoices = [
  'Frontend',
  'Backend',
  'Mobile',
  'UI/UX',
  'Data',
  'DevOps',
  'QA / Test',
  'Proje Yönetimi',
];

const _techChoices = [
  'Flutter',
  'React',
  'TypeScript',
  'Node.js',
  'Spring Boot',
  'Python',
  'PostgreSQL',
  'Firebase',
  'Docker',
  'REST API',
  'Figma',
];

class _Talent {
  final String name;
  final String school;
  final List<String> skills;
  final int aiScore;
  final int projects;

  const _Talent(
    this.name,
    this.school,
    this.skills,
    this.aiScore,
    this.projects,
  );
}

const _companyName = 'TrendTech Yazılım';

const _techOptions = [
  'Tümü',
  'Flutter',
  'React',
  'Node.js',
  'PostgreSQL',
  'Python',
  'Figma',
  'Spring Boot',
];

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final List<_Posting> _postings = [
    const _Posting(
      title: 'KOBİ Aylık Satış Analiz Paneli',
      description:
          'Küçük işletmelerin aylık gelir, gider ve stok devir hızlarını tek '
          'ekranda takip edebileceği responsive bir panel geliştireceksiniz. '
          'Satış verisini REST API üzerinden çekip grafiklere dönüştürmek, '
          'tarih ve kategori filtreleri eklemek ve JWT ile giriş akışını '
          'kurmak beklenir.',
      roles: ['Frontend', 'Backend', 'UI/UX'],
      technologies: ['Flutter', 'REST API', 'PostgreSQL'],
      difficulty: 'Orta',
      deadline: '9 Aralık 2026',
      applicants: 14,
      status: 'Yayında',
      xpReward: 450,
    ),
    const _Posting(
      title: 'Stok Devir Hızı Tahmin Modülü',
      description:
          'Geçmiş satış verisinden ürün bazında stok tükenme tahmini yapan '
          'bir servis ve bu tahminleri gösteren yönetici ekranı. Basit bir '
          'zaman serisi modeli, tahmin API uç noktası ve uyarı eşikleri '
          'tasarlanacak.',
      roles: ['Backend', 'Data'],
      technologies: ['Python', 'PostgreSQL', 'Docker'],
      difficulty: 'İleri',
      deadline: '20 Ocak 2027',
      applicants: 0,
      status: 'Taslak',
      xpReward: 600,
    ),
    const _Posting(
      title: 'Fatura OCR Prototipi',
      description:
          'Fotoğrafı çekilen kağıt faturalardan tutar, tarih ve firma '
          'bilgisini okuyup forma dolduran mobil prototip.',
      roles: ['Mobile', 'Backend'],
      technologies: ['Flutter', 'Firebase'],
      difficulty: 'Orta',
      deadline: '15 Ekim 2026',
      applicants: 11,
      status: 'Tamamlandı',
      xpReward: 400,
    ),
  ];

  final Set<String> _invited = {};
  String _tech = 'Tümü';
  int _minScore = 0;

  List<_Talent> get _talents => [
    const _Talent(
      'Selin Demir',
      'İTÜ • Bilgisayar Müh.',
      ['Spring Boot', 'PostgreSQL', 'Docker'],
      94,
      6,
    ),
    const _Talent(
      'Kaan Yılmaz',
      'ODTÜ • Yazılım Müh.',
      ['Flutter', 'Firebase', 'Node.js'],
      90,
      5,
    ),
    const _Talent(
      'Zeynep Arslan',
      'Yıldız Teknik • YBS',
      ['Figma', 'Flutter'],
      89,
      4,
    ),
    _Talent(
      ProviaMockData.currentUserName,
      ProviaMockData.currentUserUniversity,
      const ['Flutter', 'REST API', 'PostgreSQL'],
      88,
      ProviaMockData.currentUserCompletedProjects,
    ),
    const _Talent(
      'Mert Kılıç',
      'Hacettepe • Bilgisayar Müh.',
      ['Node.js', 'PostgreSQL', 'Python'],
      86,
      3,
    ),
    const _Talent('Ece Tunç', 'Ege Üni. • YBS', ['Figma', 'React'], 84, 3),
    const _Talent(
      'Burak Kaya',
      'Ege Üni. • Bilgisayar Müh.',
      ['Flutter', 'Dart'],
      77,
      2,
    ),
  ];

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _publish() async {
    final posting = await showDialog<_Posting>(
      context: context,
      builder: (_) => const _PublishDialog(),
    );
    if (posting == null || !mounted) return;
    setState(() => _postings.insert(0, posting));
    _message(
      '"${posting.title}" yayınlandı (önizleme, öğrencilere gönderilmez).',
    );
  }

  void _invite(_Talent t) {
    setState(() => _invited.add(t.name));
    _message('${t.name} mülakata davet edildi (demo).');
  }

  @override
  Widget build(BuildContext context) {
    final talents = _talents
        .where(
          (t) =>
              (_tech == 'Tümü' || t.skills.contains(_tech)) &&
              t.aiScore >= _minScore,
        )
        .toList();
    final live = _postings.where((p) => p.status == 'Yayında').length;
    final applicants = _postings.fold<int>(0, (s, p) => s + p.applicants);
    final avgScore =
        (_talents.fold<int>(0, (s, t) => s + t.aiScore) / _talents.length)
            .round();

    return ProviaPageView(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Şirket Paneli',
                        style: ProviaTheme.heading(size: 20),
                      ),
                      const StatusBadge(
                        label: 'Önizleme',
                        color: ProviaTheme.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '$_companyName olarak görüntülüyorsun. Veriler demo '
                    'amaçlıdır ve kaydedilmez.',
                    style: TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _publish,
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Görev Yayınla'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MetricStrip(
          items: [
            MetricItem(
              label: 'Yayındaki Görevler',
              value: '$live',
              caption: '${_postings.length} toplam',
              icon: LucideIcons.briefcase,
            ),
            MetricItem(
              label: 'Başvuran Öğrenci',
              value: '$applicants',
              caption: 'Tüm görevlerde',
              icon: LucideIcons.users,
            ),
            MetricItem(
              label: 'Ortalama AI Skoru',
              value: '$avgScore/100',
              caption: 'Yetenek havuzu',
              icon: LucideIcons.cpu,
            ),
            MetricItem(
              label: 'Mülakat Daveti',
              value: '${_invited.length}',
              caption: 'Bu oturumda',
              icon: LucideIcons.mail,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProviaPanel(
          title: 'Proje Görevleri',
          subtitle: 'Öğrencilerin katılabildiği iş senaryoların',
          children: [for (final p in _postings) _PostingRow(posting: p)],
        ),
        const SizedBox(height: 16),
        ProviaPanel(
          title: 'Yetenek Havuzu',
          subtitle:
              'Doğrulanmış teslimlere göre öğrenciler (AI skorları MVP '
              'simülasyonudur)',
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 220,
                    child: ProviaSelect<String>(
                      label: 'Teknoloji',
                      value: _tech,
                      options: [for (final t in _techOptions) (t, t)],
                      onChanged: (v) => setState(() => _tech = v),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: ProviaSelect<int>(
                      label: 'Min. AI skoru',
                      value: _minScore,
                      options: const [
                        (0, 'Tümü'),
                        (80, '80+'),
                        (85, '85+'),
                        (90, '90+'),
                      ],
                      onChanged: (v) => setState(() => _minScore = v),
                    ),
                  ),
                ],
              ),
            ),
            if (talents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Bu filtrelere uyan öğrenci yok.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 13),
                ),
              ),
            for (final t in talents)
              _TalentRow(
                talent: t,
                invited: _invited.contains(t.name),
                onInvite: () => _invite(t),
              ),
          ],
        ),
      ],
    );
  }
}

class _PostingRow extends StatelessWidget {
  final _Posting posting;

  const _PostingRow({required this.posting});

  @override
  Widget build(BuildContext context) {
    final color = switch (posting.status) {
      'Yayında' => ProviaTheme.accent,
      'Taslak' => ProviaTheme.textSubtle,
      _ => ProviaTheme.textMuted,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  posting.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metaLine([
                    posting.difficulty,
                    'Son: ${posting.deadline}',
                    '${posting.xpReward} XP',
                  ]),
                  style: ProviaTheme.mono(
                    size: 11,
                    color: ProviaTheme.textSubtle,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  posting.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aranan: ${metaLine(posting.roles)}',
                  style: const TextStyle(
                    color: ProviaTheme.textPrimary,
                    fontSize: 12,
                  ),
                ),
                if (posting.technologies.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final t in posting.technologies) TechChip(t),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusDot(color),
                  const SizedBox(width: 6),
                  Text(
                    posting.status,
                    style: const TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${posting.applicants} başvuru',
                style: ProviaTheme.mono(
                  size: 11,
                  color: ProviaTheme.textSubtle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TalentRow extends StatelessWidget {
  final _Talent talent;
  final bool invited;
  final VoidCallback onInvite;

  const _TalentRow({
    required this.talent,
    required this.invited,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final info = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProviaAvatar(name: talent.name, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                talent.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metaLine([
                  talent.school,
                  '${talent.projects} doğrulanmış proje',
                ]),
                style: const TextStyle(
                  color: ProviaTheme.textSubtle,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [for (final s in talent.skills) TechChip(s)],
              ),
            ],
          ),
        ),
      ],
    );

    final score = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${talent.aiScore}',
            style: ProviaTheme.mono(size: 15, weight: FontWeight.w600),
          ),
          TextSpan(
            text: '/100',
            style: ProviaTheme.mono(size: 11, color: ProviaTheme.textSubtle),
          ),
        ],
      ),
    );

    final action = invited
        ? OutlinedButton.icon(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              disabledForegroundColor: ProviaTheme.accent,
            ),
            icon: const Icon(LucideIcons.check, size: 13),
            label: const Text('Davet edildi'),
          )
        : OutlinedButton(
            onPressed: onInvite,
            child: const Text('Mülakata Davet Et'),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 10),
                Row(children: [score, const Spacer(), action]),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 16),
              score,
              const SizedBox(width: 20),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _PublishDialog extends StatefulWidget {
  const _PublishDialog();

  @override
  State<_PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<_PublishDialog> {
  static const _minDescription = 40;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _roles = {};
  final Set<String> _technologies = {};
  String _difficulty = 'Orta';
  int _xp = 400;
  String? _titleError;
  String? _descriptionError;
  String? _rolesError;

  @override
  void initState() {
    super.initState();
    // Karakter sayacı canlı güncellensin.
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    setState(() {
      _titleError = title.length < 5
          ? 'Görev başlığı en az 5 karakter olmalı.'
          : null;
      _descriptionError = description.length < _minDescription
          ? 'İş tanımı en az $_minDescription karakter olmalı; öğrencinin '
                'ne yapacağını açıkça anlat.'
          : null;
      _rolesError = _roles.isEmpty ? 'En az bir rol seç.' : null;
    });
    if (_titleError != null ||
        _descriptionError != null ||
        _rolesError != null) {
      return;
    }
    Navigator.of(context).pop(
      _Posting(
        title: title,
        description: description,
        roles: _roleChoices.where(_roles.contains).toList(),
        technologies: _techChoices.where(_technologies.contains).toList(),
        difficulty: _difficulty,
        deadline: '31 Ocak 2027',
        applicants: 0,
        status: 'Yayında',
        xpReward: _xp,
      ),
    );
  }

  Widget _label(String text, {String? hint}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        if (hint != null) ...[
          const SizedBox(width: 8),
          Text(
            hint,
            style: const TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
          ),
        ],
      ],
    ),
  );

  Widget _chips(List<String> options, Set<String> selected) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final o in options)
        FilterPill(
          label: selected.contains(o) ? '✓  $o' : o,
          selected: selected.contains(o),
          onTap: () => setState(() {
            selected.contains(o) ? selected.remove(o) : selected.add(o);
            if (identical(selected, _roles) && _roles.isNotEmpty) {
              _rolesError = null;
            }
          }),
        ),
    ],
  );

  Widget _error(String? text) => text == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            text,
            style: const TextStyle(color: ProviaTheme.danger, fontSize: 12),
          ),
        );

  @override
  Widget build(BuildContext context) {
    final length = _descriptionController.text.trim().length;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Proje Görevi Yayınla',
                style: ProviaTheme.heading(size: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                'Önizleme: görev yalnızca bu panelde görünür.',
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Görev başlığı',
                  hintText: 'Örn. Sipariş takip ekranı ve REST API',
                  errorText: _titleError,
                ),
              ),
              const SizedBox(height: 18),
              _label('İş tanımı', hint: 'Öğrenci bu görevde ne yapacak?'),
              TextField(
                controller: _descriptionController,
                minLines: 5,
                maxLines: 10,
                maxLength: 1200,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 13, height: 1.5),
                decoration: InputDecoration(
                  hintText:
                      'Problemi, beklenen çıktıları, teslim edilecekleri ve '
                      'başarı ölçütlerini adım adım anlat. Örn: "Sipariş '
                      'listesini gösteren mobil ekranı geliştirecek, '
                      'filtreleme ekleyecek ve API ile bağlayacaksın..."',
                  hintMaxLines: 4,
                  errorText: _descriptionError,
                  errorMaxLines: 2,
                  counterText: length < _minDescription
                      ? '$length / en az $_minDescription karakter'
                      : '$length karakter',
                  counterStyle: ProviaTheme.mono(
                    size: 11,
                    color: length < _minDescription
                        ? ProviaTheme.textSubtle
                        : ProviaTheme.accent,
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              _label('Gerekli roller', hint: 'En az bir tane seç'),
              _chips(_roleChoices, _roles),
              _error(_rolesError),
              const SizedBox(height: 18),
              _label('Teknolojiler', hint: 'İsteğe bağlı'),
              _chips(_techChoices, _technologies),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _difficulty,
                      dropdownColor: ProviaTheme.surfaceElevated,
                      decoration: const InputDecoration(labelText: 'Zorluk'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Başlangıç',
                          child: Text('Başlangıç'),
                        ),
                        DropdownMenuItem(value: 'Orta', child: Text('Orta')),
                        DropdownMenuItem(value: 'İleri', child: Text('İleri')),
                      ],
                      onChanged: (v) =>
                          setState(() => _difficulty = v ?? _difficulty),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _xp,
                      dropdownColor: ProviaTheme.surfaceElevated,
                      decoration: const InputDecoration(labelText: 'XP ödülü'),
                      items: const [
                        DropdownMenuItem(value: 300, child: Text('300 XP')),
                        DropdownMenuItem(value: 400, child: Text('400 XP')),
                        DropdownMenuItem(value: 500, child: Text('500 XP')),
                        DropdownMenuItem(value: 650, child: Text('650 XP')),
                      ],
                      onChanged: (v) => setState(() => _xp = v ?? _xp),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Vazgeç'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Yayınla'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
