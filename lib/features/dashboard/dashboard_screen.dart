import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
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
  final VoidCallback onGoToLeaderboard;

  const DashboardScreen({
    super.key,
    required this.userXp,
    required this.joinedProjects,
    required this.activeProjectId,
    required this.evaluatedProjectIds,
    required this.onSelectProject,
    required this.onGoToWorkspace,
    required this.onGoToMarketplace,
    required this.onGoToLeaderboard,
  });

  void _openProject(String id) {
    onSelectProject(id);
    onGoToWorkspace();
  }

  @override
  Widget build(BuildContext context) {
    final ranked = ProviaMockData.rankedLeaderboard(userXp);
    final myRank = ranked.firstWhere(ProviaMockData.isCurrentUser).rank;
    final myDoneTasks = [
      for (final p in joinedProjects)
        ...ProviaMockData.tasksFor(
          p.id,
        ).where((t) => t.assignee == 'Sen' && t.status == 'Tamamlandı'),
    ];
    final hasAiScore = evaluatedProjectIds.isNotEmpty;

    return ProviaPageView(
      children: [
        _WelcomeHeader(userXp: userXp),
        const SizedBox(height: 12),
        MetricStrip(
          items: [
            MetricItem(
              label: 'Aktif Projeler',
              value: '${joinedProjects.length}',
              caption: 'Çalışma alanında',
              icon: LucideIcons.folderOpen,
            ),
            MetricItem(
              label: 'Tamamlanan Görevler',
              value: '${myDoneTasks.length}',
              caption: 'Sana atanmış',
              icon: LucideIcons.checkSquare,
            ),
            MetricItem(
              label: 'Ortalama AI Skoru',
              value: hasAiScore ? '88/100' : '—',
              caption: hasAiScore ? 'MVP simülasyonu' : 'Henüz teslim yok',
              icon: LucideIcons.cpu,
            ),
            MetricItem(
              label: 'Aylık Sıralama',
              value: '#$myRank',
              caption: 'Bireysel ligde',
              icon: LucideIcons.trophy,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActiveProjectsPanel(
                  projects: joinedProjects,
                  activeProjectId: activeProjectId,
                  onOpen: _openProject,
                  onExplore: onGoToMarketplace,
                ),
                const SizedBox(height: 16),
                _RecommendedPanel(
                  joinedIds: joinedProjects.map((p) => p.id).toSet(),
                  userXp: userXp,
                  onExplore: onGoToMarketplace,
                ),
              ],
            );
            final right = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeadlinesPanel(projects: joinedProjects, onOpen: _openProject),
                const SizedBox(height: 16),
                _TopFivePanel(ranked: ranked, onSeeAll: onGoToLeaderboard),
                const SizedBox(height: 16),
                _ActivityPanel(
                  projects: joinedProjects,
                  evaluatedProjectIds: evaluatedProjectIds,
                ),
              ],
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
              children: [left, const SizedBox(height: 16), right],
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  final int userXp;

  const _WelcomeHeader({required this.userXp});

  @override
  Widget build(BuildContext context) {
    final level = (userXp ~/ 400) + 1;
    final nextLevelXp = level * 400;
    final xpInLevel = userXp % 400;
    final firstName = ProviaMockData.currentUserName.split(' ').first;

    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tekrar hoş geldin, $firstName',
          style: ProviaTheme.heading(size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          ProviaMockData.currentUserUniversity,
          style: const TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
        ),
      ],
    );

    final levelBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Seviye $level Geliştirici',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$userXp / $nextLevelXp XP',
              style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProviaProgressBar(value: xpInLevel / 400),
        const SizedBox(height: 6),
        Text(
          'Sonraki seviye için ${400 - xpInLevel} XP kaldı.',
          style: const TextStyle(color: ProviaTheme.textSubtle, fontSize: 11),
        ),
      ],
    );

    return ProviaCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 640) {
            return Row(
              children: [
                Expanded(child: greeting),
                const SizedBox(width: 24),
                SizedBox(width: 300, child: levelBlock),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [greeting, const SizedBox(height: 16), levelBlock],
          );
        },
      ),
    );
  }
}

class _ActiveProjectsPanel extends StatelessWidget {
  final List<ProviaProject> projects;
  final String? activeProjectId;
  final ValueChanged<String> onOpen;
  final VoidCallback onExplore;

  const _ActiveProjectsPanel({
    required this.projects,
    required this.activeProjectId,
    required this.onOpen,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return ProviaPanel(
      title: 'Aktif Projelerim',
      trailing: TextButton.icon(
        onPressed: onExplore,
        icon: const Icon(LucideIcons.plus, size: 14),
        label: const Text('Yeni Proje Keşfet'),
      ),
      children: [
        if (projects.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "Henüz bir projeye katılmadın. Bir proje seç ve ilk XP'ni kazan.",
                  style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
                ),
                ElevatedButton(
                  onPressed: onExplore,
                  child: const Text('İlk Projeni Seç'),
                ),
              ],
            ),
          ),
        for (final p in projects)
          _ProjectRow(
            project: p,
            active: p.id == activeProjectId,
            onOpen: () => onOpen(p.id),
          ),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final ProviaProject project;
  final bool active;
  final VoidCallback onOpen;

  const _ProjectRow({
    required this.project,
    required this.active,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = ProviaMockData.tasksFor(project.id);
    final done = tasks.where((t) => t.status == 'Tamamlandı').length;
    final completion = ProviaMockData.completionFor(project.id);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (project.isCompanySponsored) ...[
              const SizedBox(width: 8),
              const StatusBadge(label: 'Sponsorlu', color: ProviaTheme.accent),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          metaLine([
            'Teslim: ${ProviaMockData.deadlineLabel(project)}',
            '$done/${tasks.length} görev',
          ]),
          style: ProviaTheme.mono(size: 11, color: ProviaTheme.textSubtle),
        ),
      ],
    );

    final button = active
        ? ElevatedButton(
            onPressed: onOpen,
            child: const Text('Çalışma Alanında Aç'),
          )
        : OutlinedButton(
            onPressed: onOpen,
            child: const Text('Çalışma Alanında Aç'),
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 440;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                info
              else
                Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    button,
                  ],
                ),
              const SizedBox(height: 12),
              ProviaProgressBar(
                value: completion,
                color: active ? ProviaTheme.primary : ProviaTheme.textSubtle,
              ),
              if (narrow) ...[const SizedBox(height: 12), button],
            ],
          );
        },
      ),
    );
  }
}

class _RecommendedPanel extends StatelessWidget {
  final Set<String> joinedIds;
  final int userXp;
  final VoidCallback onExplore;

  const _RecommendedPanel({
    required this.joinedIds,
    required this.userXp,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final level = (userXp ~/ 400) + 1;
    final fits = level <= 2
        ? const ['Başlangıç', 'Orta']
        : const ['Orta', 'İleri'];
    final candidates =
        ProviaMockData.projects.where((p) => !joinedIds.contains(p.id)).toList()
          ..sort(
            (a, b) => (fits.contains(b.difficulty) ? 1 : 0).compareTo(
              fits.contains(a.difficulty) ? 1 : 0,
            ),
          );
    final picks = candidates.take(2).toList();

    return ProviaPanel(
      title: 'Seviyene Göre Önerilen Projeler',
      trailing: TextButton(
        onPressed: onExplore,
        child: const Text('Tümünü gör'),
      ),
      children: [
        if (picks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tüm projelere katıldın.',
              style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(12),
            child: ProviaGrid(
              minItemWidth: 240,
              maxColumns: 2,
              children: [
                for (final p in picks)
                  _RecommendedCard(project: p, onOpen: onExplore),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final ProviaProject project;
  final VoidCallback onOpen;

  const _RecommendedCard({required this.project, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return ProviaCard(
      color: ProviaTheme.bgDark,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.isCompanySponsored
                      ? project.company
                      : 'Topluluk Projesi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: project.isCompanySponsored
                        ? ProviaTheme.accent
                        : ProviaTheme.textSubtle,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                project.difficulty,
                style: ProviaTheme.mono(
                  size: 11,
                  color: ProviaTheme.textSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ProviaTheme.textMuted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onOpen,
            child: const Text('Detayları İncele'),
          ),
        ],
      ),
    );
  }
}

class _DeadlinesPanel extends StatelessWidget {
  final List<ProviaProject> projects;
  final ValueChanged<String> onOpen;

  const _DeadlinesPanel({required this.projects, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final sorted = [...projects]
      ..sort(
        (a, b) =>
            ProviaMockData.daysLeft(a).compareTo(ProviaMockData.daysLeft(b)),
      );

    return ProviaPanel(
      title: 'Yaklaşan Teslim Tarihleri',
      children: [
        if (sorted.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Projeye katıldığında teslim tarihleri burada görünür.',
              style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
            ),
          ),
        for (final p in sorted)
          InkWell(
            onTap: () => onOpen(p.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: StatusDot(
                      ProviaMockData.daysLeft(p) <= 14
                          ? ProviaTheme.warning
                          : ProviaTheme.textSubtle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ProviaMockData.deadlineLabel(p),
                          style: ProviaTheme.mono(
                            size: 11,
                            color: ProviaTheme.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TopFivePanel extends StatelessWidget {
  final List<LeaderboardUser> ranked;
  final VoidCallback onSeeAll;

  const _TopFivePanel({required this.ranked, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return ProviaPanel(
      title: 'Aylık Liderlik (İlk 5)',
      trailing: TextButton(onPressed: onSeeAll, child: const Text('Tümü')),
      dividers: false,
      children: [
        const SizedBox(height: 4),
        for (final u in ranked.take(5))
          _TopFiveRow(user: u, isMe: ProviaMockData.isCurrentUser(u)),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _TopFiveRow extends StatelessWidget {
  final LeaderboardUser user;
  final bool isMe;

  const _TopFiveRow({required this.user, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? ProviaTheme.surfaceElevated : null,
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank}',
              style: ProviaTheme.mono(size: 12, color: ProviaTheme.textSubtle),
            ),
          ),
          Expanded(
            child: Text(
              user.name.replaceAll(' (Sen)', ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${user.xp} XP',
            style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
          ),
        ],
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  final List<ProviaProject> projects;
  final Set<String> evaluatedProjectIds;

  const _ActivityPanel({
    required this.projects,
    required this.evaluatedProjectIds,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(String, int)>[];
    for (final p in projects) {
      if (evaluatedProjectIds.contains(p.id)) {
        items.add(('${p.title} için AI değerlendirmesi tamamlandı.', 150));
      }
      for (final t in ProviaMockData.tasksFor(p.id)) {
        if (t.assignee == 'Sen' && t.status == 'Tamamlandı') {
          items.add(('"${t.title}" görevini tamamladın.', t.xp));
        }
      }
    }

    return ProviaPanel(
      title: 'Son Aktiviteler',
      children: [
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Henüz aktivite yok. Görev tamamladıkça burada görünür.',
              style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
            ),
          ),
        for (final item in items.take(4))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${item.$2} XP',
                  style: ProviaTheme.mono(size: 11, color: ProviaTheme.accent),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
