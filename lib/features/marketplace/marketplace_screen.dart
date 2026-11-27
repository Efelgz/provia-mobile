// SAHİBİ: Kişi 2 — Keşfet (Proje Pazarı) ekranı.
// Constructor imzası main.dart ile anlaşmadır, değiştirme:
//   MarketplaceScreen({
//     required Set<String> joinedProjectIds,
//     required ValueChanged<ProviaProject> onJoinProject,
//     required VoidCallback onGoToDashboard,
//   })
// Katılım durumu main.dart'ta tutulur. onJoinProject(proje) çağrılınca proje
// kullanıcının listesine eklenir, Panel'de aktif olur ve +50 XP verilir.
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/provia_components.dart';
import '../../models/provia_models.dart';

const _categories = {
  'p1': 'SaaS & Analitik',
  'p2': 'Mobil & Verimlilik',
  'p3': 'Eğitim & Kampüs',
  'p4': 'Sağlık Teknolojileri',
  'p5': 'E-Ticaret',
  'p6': 'B2B & Kurumsal',
};

String categoryOf(ProviaProject p) => _categories[p.id] ?? 'Yazılım';

/// Zorluk için sinyal rengi (yalnızca küçük metin olarak kullanılır).
Color difficultyColor(String difficulty) => switch (difficulty) {
  'Başlangıç' => ProviaTheme.accent,
  'Orta' => ProviaTheme.warning,
  _ => ProviaTheme.danger,
};

class MarketplaceScreen extends StatefulWidget {
  final Set<String> joinedProjectIds;
  final ValueChanged<ProviaProject> onJoinProject;
  final VoidCallback onGoToDashboard;

  const MarketplaceScreen({
    super.key,
    required this.joinedProjectIds,
    required this.onJoinProject,
    required this.onGoToDashboard,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  static const _filters = [
    'Tümü',
    'Şirket Destekli',
    'Topluluk',
    'Başlangıç',
    'Orta',
    'İleri',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _filter = 'Tümü';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(ProviaProject p, String filter) => switch (filter) {
    'Şirket Destekli' => p.isCompanySponsored,
    'Topluluk' => !p.isCompanySponsored,
    'Başlangıç' || 'Orta' || 'İleri' => p.difficulty == filter,
    _ => true,
  };

  bool _matchesQuery(ProviaProject p) {
    final q = foldForSearch(_query.trim());
    if (q.isEmpty) return true;
    final haystack = foldForSearch(
      [
        p.title,
        p.company,
        p.description,
        categoryOf(p),
        ...p.technologies,
        ...p.openRoles,
      ].join(' '),
    );
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }

  void _joinProject(ProviaProject project) {
    if (widget.joinedProjectIds.contains(project.id)) return;
    widget.onJoinProject(project);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '"${project.title}" projesine katıldın. +50 XP, ana sayfada aktif.',
          ),
          action: SnackBarAction(
            label: 'Ana Sayfaya Git',
            onPressed: widget.onGoToDashboard,
          ),
        ),
      );
  }

  void _openDetail(ProviaProject project) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ProjectDetailDialog(
        project: project,
        joined: widget.joinedProjectIds.contains(project.id),
        onJoin: () {
          Navigator.of(dialogContext).pop();
          _joinProject(project);
        },
      ),
    );
  }

  void _clear() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = 'Tümü';
    });
  }

  @override
  Widget build(BuildContext context) {
    final searched = ProviaMockData.projects.where(_matchesQuery).toList();
    final projects = searched.where((p) => _matchesFilter(p, _filter)).toList();

    final search = TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _query = v),
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Proje, teknoloji veya şirket ara...',
        prefixIcon: const Icon(LucideIcons.search, size: 15),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Aramayı temizle',
                icon: const Icon(LucideIcons.x, size: 14),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
      ),
    );

    return ProviaPageView(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final count = Text(
              '${projects.length} proje',
              style: ProviaTheme.mono(size: 12, color: ProviaTheme.textSubtle),
            );
            if (constraints.maxWidth >= 640) {
              return Row(
                children: [
                  SizedBox(width: 340, child: search),
                  const Spacer(),
                  count,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: count),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        UnderlineTabs<String>(
          value: _filter,
          onChanged: (v) => setState(() => _filter = v),
          tabs: [
            for (final f in _filters)
              ProviaSegment(
                f,
                f,
                count: searched.where((p) => _matchesFilter(p, f)).length,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (projects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const Text(
                  'Aramana uygun proje bulunamadı.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Farklı bir anahtar kelime veya filtre dene.',
                  style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 13),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: _clear,
                  child: const Text('Filtreleri Temizle'),
                ),
              ],
            ),
          )
        else
          ProviaGrid(
            minItemWidth: 360,
            maxColumns: 2,
            children: [
              for (final p in projects)
                _ProjectCard(
                  project: p,
                  joined: widget.joinedProjectIds.contains(p.id),
                  onJoin: () => _joinProject(p),
                  onDetail: () => _openDetail(p),
                ),
            ],
          ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProviaProject project;
  final bool joined;
  final VoidCallback onJoin;
  final VoidCallback onDetail;

  const _ProjectCard({
    required this.project,
    required this.joined,
    required this.onJoin,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return ProviaCard(
      onTap: onDetail,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                project.difficulty,
                style: ProviaTheme.mono(
                  size: 11,
                  color: difficultyColor(project.difficulty),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: metaLine([project.company, categoryOf(project)]),
                ),
                if (project.isCompanySponsored)
                  const TextSpan(
                    text: '  ·  Sponsorlu',
                    style: TextStyle(color: ProviaTheme.accent),
                  ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ProviaTheme.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [for (final t in project.technologies) TechChip(t)],
          ),
          const Spacer(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${ProviaMockData.daysLeft(project)} gün  ·  ',
                      ),
                      TextSpan(
                        text: '${project.xpReward} XP',
                        style: const TextStyle(color: ProviaTheme.xp),
                      ),
                    ],
                  ),
                  style: ProviaTheme.mono(
                    size: 12,
                    color: ProviaTheme.textSubtle,
                  ),
                ),
              ),
              TextButton(onPressed: onDetail, child: const Text('Detay')),
              const SizedBox(width: 4),
              joined
                  ? OutlinedButton.icon(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        disabledForegroundColor: ProviaTheme.accent,
                      ),
                      icon: const Icon(LucideIcons.check, size: 13),
                      label: const Text('Katıldın'),
                    )
                  : ElevatedButton(
                      onPressed: onJoin,
                      child: const Text('Katıl'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectDetailDialog extends StatelessWidget {
  final ProviaProject project;
  final bool joined;
  final VoidCallback onJoin;

  const _ProjectDetailDialog({
    required this.project,
    required this.joined,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = ProviaMockData.tasksFor(project.id);

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ProviaTheme.textSubtle,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: ProviaTheme.heading(size: 18),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 16),
                  ),
                ],
              ),
              Text(
                metaLine([
                  project.company,
                  categoryOf(project),
                  project.difficulty,
                ]),
                style: const TextStyle(
                  color: ProviaTheme.textSubtle,
                  fontSize: 12,
                ),
              ),
              section(
                'Problem',
                Text(
                  project.description,
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),
              section(
                'Açık roller',
                Text(
                  metaLine(project.openRoles),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              section(
                'Teknolojiler',
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [for (final t in project.technologies) TechChip(t)],
                ),
              ),
              section(
                'Kilometre taşları',
                ProviaPanel(
                  children: [
                    for (final t in tasks)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              t.status == 'Tamamlandı'
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.circle,
                              size: 13,
                              color: t.status == 'Tamamlandı'
                                  ? ProviaTheme.accent
                                  : ProviaTheme.textSubtle,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t.title,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              '+${t.xp}',
                              style: ProviaTheme.mono(
                                size: 11,
                                color: ProviaTheme.xp,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              section(
                'Değerlendirme',
                const Text(
                  'GitHub teslimi sonrası kod kalitesi, gereksinimlere uyum ve '
                  'bireysel katkı raporlanır (MVP simülasyonu).',
                  style: TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${ProviaMockData.deadlineLabel(project)}  ·  '
                      '${project.xpReward} XP',
                      style: ProviaTheme.mono(
                        size: 12,
                        color: ProviaTheme.textSubtle,
                      ),
                    ),
                  ),
                  if (joined)
                    const Text(
                      'Katıldın',
                      style: TextStyle(
                        color: ProviaTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: onJoin,
                      child: const Text('Projeye Katıl'),
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
