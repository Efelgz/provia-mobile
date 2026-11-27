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
import '../../models/provia_models.dart';

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
  static const List<String> _filters = [
    'Tümü',
    'Şirket Destekli',
    'Topluluk',
    'Başlangıç',
    'Orta',
    'İleri',
  ];

  String _selectedFilter = 'Tümü';

  List<ProviaProject> get _visibleProjects {
    final all = ProviaMockData.projects;
    switch (_selectedFilter) {
      case 'Şirket Destekli':
        return all.where((p) => p.isCompanySponsored).toList();
      case 'Topluluk':
        return all.where((p) => !p.isCompanySponsored).toList();
      case 'Başlangıç':
      case 'Orta':
      case 'İleri':
        return all.where((p) => p.difficulty == _selectedFilter).toList();
      default:
        return all;
    }
  }

  void _joinProject(ProviaProject project) {
    if (widget.joinedProjectIds.contains(project.id)) return;
    widget.onJoinProject(project);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '"${project.title}" projesine katıldın! +50 XP. '
            'Panelde aktif proje olarak seçildi.',
          ),
          action: SnackBarAction(
            label: 'Panele Git',
            textColor: ProviaTheme.primary,
            onPressed: widget.onGoToDashboard,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final projects = _visibleProjects;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Gerçek projeler, gerçek deneyim',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Şirket destekli ve topluluk projelerine katıl, ekibinle teslim et.',
          style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final selected = filter == _selectedFilter;
              return Material(
                color: selected
                    ? ProviaTheme.primary.withValues(alpha: 0.2)
                    : ProviaTheme.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: selected
                        ? ProviaTheme.primary.withValues(alpha: 0.6)
                        : ProviaTheme.borderDark,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
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
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${projects.length} proje listeleniyor',
          style: const TextStyle(color: ProviaTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (projects.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Bu filtreye uygun proje bulunamadı.',
                style: TextStyle(color: ProviaTheme.textMuted),
              ),
            ),
          ),
        for (final project in projects)
          _ProjectCard(
            project: project,
            joined: widget.joinedProjectIds.contains(project.id),
            onJoin: () => _joinProject(project),
          ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProviaProject project;
  final bool joined;
  final VoidCallback onJoin;

  const _ProjectCard({
    required this.project,
    required this.joined,
    required this.onJoin,
  });

  Color get _difficultyColor {
    switch (project.difficulty) {
      case 'Başlangıç':
        return ProviaTheme.accent;
      case 'Orta':
        return ProviaTheme.warning;
      default:
        return const Color(0xFFF43F5E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        project.isCompanySponsored
                            ? LucideIcons.building2
                            : LucideIcons.users,
                        size: 14,
                        color: ProviaTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          project.company,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ProviaTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (project.isCompanySponsored) ...[
                        const SizedBox(width: 8),
                        const Flexible(
                          child: _Tag(
                            text: 'Şirket Destekli',
                            color: ProviaTheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _Tag(text: project.difficulty, color: _difficultyColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              project.description,
              style: const TextStyle(
                color: ProviaTheme.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tech in project.technologies)
                  _Tag(text: tech, color: ProviaTheme.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.userPlus,
                  size: 14,
                  color: ProviaTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Açık roller: ${project.openRoles.join(', ')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: ProviaTheme.borderDark),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  LucideIcons.clock,
                  size: 13,
                  color: ProviaTheme.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  project.deadline,
                  style: const TextStyle(
                    color: ProviaTheme.warning,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  LucideIcons.zap,
                  size: 13,
                  color: ProviaTheme.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${project.xpReward} XP',
                  style: const TextStyle(
                    color: ProviaTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: joined
                  ? OutlinedButton.icon(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        disabledForegroundColor: ProviaTheme.accent,
                        side: BorderSide(
                          color: ProviaTheme.accent.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(LucideIcons.checkCircle, size: 16),
                      label: const Text('Katıldın'),
                    )
                  : ElevatedButton.icon(
                      onPressed: onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProviaTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(LucideIcons.userPlus, size: 16),
                      label: const Text('Projeye Katıl'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
