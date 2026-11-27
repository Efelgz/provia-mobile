import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/project_switcher.dart';
import '../../core/widgets/provia_components.dart';
import '../../models/provia_models.dart';

class DashboardScreen extends StatelessWidget {
  final int userXp;
  final List<ProviaProject> joinedProjects;
  final String? activeProjectId;
  final Set<String> evaluatedProjectIds;
  final ValueChanged<String> onSelectProject;
  final VoidCallback onGoToWorkspace;
  final VoidCallback onGoToMarketplace;

  const DashboardScreen({
    super.key,
    required this.userXp,
    required this.joinedProjects,
    required this.activeProjectId,
    required this.evaluatedProjectIds,
    required this.onSelectProject,
    required this.onGoToWorkspace,
    required this.onGoToMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    final int level = (userXp ~/ 400) + 1;
    final int xpInLevel = userXp % 400;
    final ProviaProject? activeProject = joinedProjects.isEmpty
        ? null
        : joinedProjects.firstWhere(
            (p) => p.id == activeProjectId,
            orElse: () => joinedProjects.first,
          );
    final myRank = ProviaMockData.rankedLeaderboard(
      userXp,
    ).firstWhere(ProviaMockData.isCurrentUser).rank;
    final hasAiScore = evaluatedProjectIds.isNotEmpty;
    final firstName = ProviaMockData.currentUserName.split(' ').first;
    final isDesktop = ProviaBreakpoints.isDesktop(context);

    return ProviaPageView(
      children: [
        // Karşılama başlığı
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş geldin, $firstName',
                    style: ProviaTheme.heading(
                      size: 24,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'İlk stajından önce gerçek projelerle deneyim kazan.',
                    style: TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onGoToMarketplace,
                icon: const Icon(LucideIcons.compass, size: 16),
                label: const Text('Projeleri Keşfet'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 22),

        // KPI ızgarası: masaüstünde 4 sütun, mobilde 2x2
        ProviaGrid(
          minItemWidth: 150,
          maxColumns: 4,
          children: [
            MetricStatCard(
              icon: LucideIcons.zap,
              color: ProviaTheme.xp,
              label: 'Seviye & XP',
              value: 'Sv. $level',
              caption: '$userXp XP toplam',
            ),
            MetricStatCard(
              icon: LucideIcons.layers,
              color: ProviaTheme.primary,
              label: 'Aktif Proje',
              value: '${joinedProjects.length}',
              caption: joinedProjects.isEmpty
                  ? 'Henüz katılım yok'
                  : 'Devam eden proje',
            ),
            MetricStatCard(
              icon: LucideIcons.trophy,
              color: ProviaTheme.warning,
              label: 'Aylık Sıra',
              value: '#$myRank',
              caption: 'Kasım 2026',
            ),
            MetricStatCard(
              icon: LucideIcons.sparkles,
              color: ProviaTheme.info,
              label: 'AI Kod Skoru',
              value: hasAiScore ? '88' : '—',
              caption: hasAiScore
                  ? '/100 • MVP simülasyonu'
                  : 'Henüz teslim yok',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Seviye ilerlemesi
        ProviaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Seviye $level',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: '  →  Seviye ${level + 1}',
                            style: const TextStyle(
                              color: ProviaTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$xpInLevel / 400 XP',
                    style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProviaProgressBar(value: xpInLevel / 400),
              const SizedBox(height: 8),
              Text(
                'Sonraki seviyeye ${400 - xpInLevel} XP kaldı',
                style: const TextStyle(
                  color: ProviaTheme.textSubtle,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Ana bölüm: masaüstünde 2 sütun, mobilde alt alta
        LayoutBuilder(
          builder: (context, constraints) {
            final left = _ActiveProjectSection(
              joinedProjects: joinedProjects,
              activeProject: activeProject,
              onSelectProject: onSelectProject,
              onGoToWorkspace: onGoToWorkspace,
              onGoToMarketplace: onGoToMarketplace,
            );
            final right = _SidePanel(
              joinedProjects: joinedProjects,
              onSelectProject: onSelectProject,
              onGoToWorkspace: onGoToWorkspace,
              onGoToMarketplace: onGoToMarketplace,
            );
            if (constraints.maxWidth >= 860) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: left),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: right),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [left, const SizedBox(height: 28), right],
            );
          },
        ),
      ],
    );
  }
}

class _ActiveProjectSection extends StatelessWidget {
  final List<ProviaProject> joinedProjects;
  final ProviaProject? activeProject;
  final ValueChanged<String> onSelectProject;
  final VoidCallback onGoToWorkspace;
  final VoidCallback onGoToMarketplace;

  const _ActiveProjectSection({
    required this.joinedProjects,
    required this.activeProject,
    required this.onSelectProject,
    required this.onGoToWorkspace,
    required this.onGoToMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    final project = activeProject;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: joinedProjects.length > 1
              ? 'Projelerin (${joinedProjects.length})'
              : 'Aktif Projen',
          subtitle: 'Takımınla birlikte yürüttüğün projeler',
        ),
        const SizedBox(height: 12),
        if (project == null)
          _NoProjectCard(onGoToMarketplace: onGoToMarketplace)
        else ...[
          if (joinedProjects.length > 1) ...[
            ProjectSwitcher(
              projects: joinedProjects,
              activeProjectId: project.id,
              onSelect: onSelectProject,
            ),
            const SizedBox(height: 12),
          ],
          _ActiveProjectCard(
            project: project,
            onGoToWorkspace: onGoToWorkspace,
          ),
        ],
      ],
    );
  }
}

class _ActiveProjectCard extends StatelessWidget {
  final ProviaProject project;
  final VoidCallback onGoToWorkspace;

  const _ActiveProjectCard({
    required this.project,
    required this.onGoToWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    final completion = ProviaMockData.completionFor(project.id);
    final team = ProviaMockData.teamFor(project.id);

    return ProviaCard(
      highlight: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                    label: project.company,
                    color: project.isCompanySponsored
                        ? ProviaTheme.primary
                        : ProviaTheme.textMuted,
                    icon: project.isCompanySponsored
                        ? LucideIcons.building2
                        : LucideIcons.users,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: project.deadline,
                color: ProviaTheme.warning,
                icon: LucideIcons.clock,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(project.title, style: ProviaTheme.heading(size: 18)),
          const SizedBox(height: 6),
          Text(
            project.description,
            style: const TextStyle(
              color: ProviaTheme.textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Tamamlanma',
                style: TextStyle(color: ProviaTheme.textMuted, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '%${(completion * 100).round()}',
                style: ProviaTheme.mono(size: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProviaProgressBar(value: completion, color: ProviaTheme.accent),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in project.technologies) TechChip(t)],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 14),
          // Dar ekranda buton alt satıra iner, genişte sağa yaslanır.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarStack(names: team),
                    const SizedBox(width: 10),
                    Text(
                      '${team.length} kişilik takım',
                      style: const TextStyle(
                        color: ProviaTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onGoToWorkspace,
                  icon: const Icon(LucideIcons.arrowRight, size: 15),
                  label: const Text('Çalışma Alanına Git'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  final List<ProviaProject> joinedProjects;
  final ValueChanged<String> onSelectProject;
  final VoidCallback onGoToWorkspace;
  final VoidCallback onGoToMarketplace;

  const _SidePanel({
    required this.joinedProjects,
    required this.onSelectProject,
    required this.onGoToWorkspace,
    required this.onGoToMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = [...joinedProjects]
      ..sort(
        (a, b) =>
            ProviaMockData.daysLeft(a).compareTo(ProviaMockData.daysLeft(b)),
      );
    final joinedIds = joinedProjects.map((p) => p.id).toSet();
    final candidates =
        ProviaMockData.projects.where((p) => !joinedIds.contains(p.id)).toList()
          ..sort(
            (a, b) => (b.isCompanySponsored ? 1 : 0).compareTo(
              a.isCompanySponsored ? 1 : 0,
            ),
          );
    final recommended = candidates.isEmpty ? null : candidates.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Yaklaşan Teslimler',
          subtitle: 'Sana atanmış açık görevler',
        ),
        const SizedBox(height: 12),
        ProviaCard(
          padding: EdgeInsets.zero,
          child: upcoming.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Bir projeye katıldığında teslim tarihleri burada görünür.',
                    style: TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < upcoming.length; i++) ...[
                      if (i > 0) const Divider(),
                      _DeadlineRow(
                        project: upcoming[i],
                        onTap: () {
                          onSelectProject(upcoming[i].id);
                          onGoToWorkspace();
                        },
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Önerilen Proje',
          actionLabel: 'Tümü',
          onAction: onGoToMarketplace,
        ),
        const SizedBox(height: 12),
        if (recommended == null)
          const ProviaCard(
            child: Text(
              'Tüm projelere katıldın. Yeni projeler yakında eklenecek.',
              style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
            ),
          )
        else
          ProviaCard(
            onTap: onGoToMarketplace,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recommended.company,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProviaTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '+${recommended.xpReward} XP',
                      style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recommended.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in recommended.technologies.take(3))
                      TechChip(t),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusBadge(
                      label: recommended.difficulty,
                      color: ProviaTheme.textMuted,
                    ),
                    const Spacer(),
                    const Text(
                      'İncele',
                      style: TextStyle(
                        color: ProviaTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                      color: ProviaTheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  final ProviaProject project;
  final VoidCallback onTap;

  const _DeadlineRow({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final myOpenTasks = ProviaMockData.tasksFor(
      project.id,
    ).where((t) => t.assignee == 'Sen' && t.status != 'Tamamlandı').length;
    final days = ProviaMockData.daysLeft(project);
    final urgent = days <= 12;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: (urgent ? ProviaTheme.warning : ProviaTheme.textMuted)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '$days',
                    style: ProviaTheme.mono(
                      size: 15,
                      weight: FontWeight.w700,
                      color: urgent
                          ? ProviaTheme.warning
                          : ProviaTheme.textPrimary,
                    ),
                  ),
                  const Text(
                    'gün',
                    style: TextStyle(
                      color: ProviaTheme.textSubtle,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    myOpenTasks == 0
                        ? 'Açık görevin yok'
                        : '$myOpenTasks açık görevin var',
                    style: const TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: ProviaTheme.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoProjectCard extends StatelessWidget {
  final VoidCallback onGoToMarketplace;

  const _NoProjectCard({required this.onGoToMarketplace});

  @override
  Widget build(BuildContext context) {
    return ProviaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBox(icon: LucideIcons.rocket, color: ProviaTheme.primary),
          const SizedBox(height: 14),
          const Text(
            'Henüz bir projeye katılmadın',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "Şirket destekli veya topluluk projelerinden birine katıl, "
            "takımınla görevleri tamamlayarak ilk XP'ni kazan.",
            style: TextStyle(
              color: ProviaTheme.textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onGoToMarketplace,
            icon: const Icon(LucideIcons.compass, size: 16),
            label: const Text('İlk Projeni Seç'),
          ),
        ],
      ),
    );
  }
}
