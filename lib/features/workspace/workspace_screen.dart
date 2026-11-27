import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/project_switcher.dart';
import '../../core/widgets/provia_components.dart';
import '../../models/provia_models.dart';

class WorkspaceScreen extends StatefulWidget {
  /// Açık proje. Kullanıcı henüz bir projeye katılmadıysa null.
  final ProviaProject? project;
  final List<ProviaProject> joinedProjects;

  /// AI değerlendirmesi yapılmış projeler (main.dart'ta saklanır).
  final Set<String> evaluatedProjectIds;
  final ValueChanged<String> onSelectProject;
  final Function(int) onEarnXp;
  final ValueChanged<String> onProjectEvaluated;

  /// Görev durumu değişince çağrılır (kayıt için).
  final VoidCallback onTasksChanged;
  final VoidCallback onGoToMarketplace;

  const WorkspaceScreen({
    super.key,
    required this.project,
    required this.joinedProjects,
    required this.evaluatedProjectIds,
    required this.onSelectProject,
    required this.onEarnXp,
    required this.onProjectEvaluated,
    required this.onTasksChanged,
    required this.onGoToMarketplace,
  });

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final TextEditingController _repoController = TextEditingController();
  bool _isAnalyzing = false;

  /// Mobilde gösterilen Kanban sütunu.
  String _mobileStatus = 'Devam Ediyor';

  bool get _showAiReport =>
      !_isAnalyzing &&
      widget.project != null &&
      widget.evaluatedProjectIds.contains(widget.project!.id);

  @override
  void initState() {
    super.initState();
    _repoController.text = _demoRepoFor(widget.project?.id);
  }

  @override
  void didUpdateWidget(covariant WorkspaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project?.id != widget.project?.id) {
      _repoController.text = _demoRepoFor(widget.project?.id);
      _isAnalyzing = false;
    }
  }

  @override
  void dispose() {
    _repoController.dispose();
    super.dispose();
  }

  String _demoRepoFor(String? projectId) =>
      projectId == null ? '' : ProviaMockData.demoRepoUrls[projectId] ?? '';

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _cycleTaskStatus(ProviaTask task) {
    setState(() {
      if (task.status == 'Yapılacak') {
        task.status = 'Devam Ediyor';
      } else if (task.status == 'Devam Ediyor') {
        task.status = 'Tamamlandı';
        if (!task.xpAwarded) {
          task.xpAwarded = true;
          widget.onEarnXp(task.xp);
          _showMessage('Görev tamamlandı! +${task.xp} XP kazandın.');
        } else {
          _showMessage('Görev tekrar tamamlandı (XP daha önce verildi).');
        }
      } else {
        task.status = 'Yapılacak';
      }
    });
    widget.onTasksChanged();
  }

  Future<void> _runSimulatedAiEvaluation() async {
    final project = widget.project;
    if (project == null || _repoController.text.trim().isEmpty) return;
    final projectId = project.id;
    final firstSubmission = !widget.evaluatedProjectIds.contains(projectId);
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    // Kullanıcı bu sırada başka projeye geçtiyse sonucu gösterme.
    if (!mounted || widget.project?.id != projectId) return;
    setState(() => _isAnalyzing = false);
    widget.onProjectEvaluated(projectId);
    if (firstSubmission) {
      widget.onEarnXp(150);
      _showMessage('Teslim değerlendirildi! +150 XP kazandın.');
    } else {
      _showMessage(
        'Yeniden değerlendirildi (XP yalnızca ilk teslimde verilir).',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    if (project == null) {
      return _EmptyWorkspace(onGoToMarketplace: widget.onGoToMarketplace);
    }
    final tasks = ProviaMockData.tasksFor(project.id);

    return ProviaPageView(
      children: [
        if (widget.joinedProjects.length > 1) ...[
          ProjectSwitcher(
            projects: widget.joinedProjects,
            activeProjectId: project.id,
            onSelect: widget.onSelectProject,
          ),
          const SizedBox(height: 16),
        ],
        _ProjectHeaderCard(project: project, tasks: tasks),
        const SizedBox(height: 28),
        SectionHeader(
          title: 'Görev Panosu',
          subtitle: 'Durumu ilerletmek için göreve dokun',
          trailing: StatusBadge(
            label: '${tasks.length} görev',
            color: ProviaTheme.textMuted,
            mono: true,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 760) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _statuses.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _KanbanColumn(
                        status: _statuses[i],
                        tasks: tasks
                            .where((t) => t.status == _statuses[i].name)
                            .toList(),
                        onTapTask: _cycleTaskStatus,
                      ),
                    ),
                  ],
                ],
              );
            }
            final current = _statuses.firstWhere(
              (s) => s.name == _mobileStatus,
            );
            final visible = tasks
                .where((t) => t.status == current.name)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProviaSegmented<String>(
                  expand: true,
                  value: _mobileStatus,
                  onChanged: (v) => setState(() => _mobileStatus = v),
                  segments: [
                    for (final s in _statuses)
                      ProviaSegment(
                        s.name,
                        s.shortLabel,
                        count: tasks.where((t) => t.status == s.name).length,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      '"${current.name}" sütununda görev yok.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ProviaTheme.textSubtle,
                        fontSize: 13,
                      ),
                    ),
                  ),
                for (final task in visible) ...[
                  _TaskCard(
                    task: task,
                    status: current,
                    onTap: () => _cycleTaskStatus(task),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        _SubmissionCard(
          controller: _repoController,
          isAnalyzing: _isAnalyzing,
          onSubmit: _runSimulatedAiEvaluation,
        ),
        if (_showAiReport) ...[
          const SizedBox(height: 16),
          _AiReportCard(project: project, tasks: tasks),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kanban
// ---------------------------------------------------------------------------

class _StatusInfo {
  final String name;
  final String shortLabel;
  final Color color;
  final String actionLabel;
  final IconData actionIcon;

  const _StatusInfo(
    this.name,
    this.shortLabel,
    this.color,
    this.actionLabel,
    this.actionIcon,
  );
}

const _statuses = [
  _StatusInfo(
    'Yapılacak',
    'Yapılacak',
    ProviaTheme.textMuted,
    'Başlat',
    LucideIcons.play,
  ),
  _StatusInfo(
    'Devam Ediyor',
    'Devam',
    ProviaTheme.warning,
    'Tamamla',
    LucideIcons.check,
  ),
  _StatusInfo(
    'Tamamlandı',
    'Bitti',
    ProviaTheme.accent,
    'Geri Al',
    LucideIcons.rotateCcw,
  ),
];

class _KanbanColumn extends StatelessWidget {
  final _StatusInfo status;
  final List<ProviaTask> tasks;
  final ValueChanged<ProviaTask> onTapTask;

  const _KanbanColumn({
    required this.status,
    required this.tasks,
    required this.onTapTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C111C),
        borderRadius: BorderRadius.circular(ProviaTheme.radius),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                StatusBadge(
                  label: '${tasks.length}',
                  color: status.color,
                  mono: true,
                ),
              ],
            ),
          ),
          if (tasks.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ProviaTheme.borderDark),
              ),
              child: const Text(
                'Görev yok',
                textAlign: TextAlign.center,
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
              ),
            ),
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _TaskCard(
              task: tasks[i],
              status: status,
              onTap: () => onTapTask(tasks[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final ProviaTask task;
  final _StatusInfo status;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.status == 'Tamamlandı';
    final name = ProviaMockData.displayName(task.assignee);
    final isMine = task.assignee == 'Sen';

    return ProviaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: done
                        ? ProviaTheme.textMuted
                        : ProviaTheme.textPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: ProviaTheme.textSubtle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${task.xp}',
                style: ProviaTheme.mono(size: 11, color: ProviaTheme.xp),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ProviaAvatar(name: name, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMine ? 'Sen • ${task.role}' : '$name • ${task.role}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMine
                        ? ProviaTheme.textPrimary
                        : ProviaTheme.textMuted,
                    fontSize: 11,
                    fontWeight: isMine ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(status.actionIcon, size: 12, color: ProviaTheme.textSubtle),
              const SizedBox(width: 4),
              Text(
                status.actionLabel,
                style: const TextStyle(
                  color: ProviaTheme.textSubtle,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proje başlığı
// ---------------------------------------------------------------------------

class _ProjectHeaderCard extends StatelessWidget {
  final ProviaProject project;
  final List<ProviaTask> tasks;

  const _ProjectHeaderCard({required this.project, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completion = ProviaMockData.completionFor(project.id);
    final done = tasks.where((t) => t.status == 'Tamamlandı').length;
    final team = ProviaMockData.teamFor(project.id);

    return ProviaCard(
      highlight: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(
                label: project.company,
                color: project.isCompanySponsored
                    ? ProviaTheme.primary
                    : ProviaTheme.textMuted,
                icon: project.isCompanySponsored
                    ? LucideIcons.building2
                    : LucideIcons.users,
              ),
              StatusBadge(
                label: project.deadline,
                color: ProviaTheme.warning,
                icon: LucideIcons.clock,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(project.title, style: ProviaTheme.heading(size: 20)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Genel ilerleme',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: ProviaTheme.textMuted, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$done/${tasks.length} görev • %${(completion * 100).round()}',
                style: ProviaTheme.mono(size: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProviaProgressBar(value: completion, color: ProviaTheme.accent),
          const SizedBox(height: 16),
          Row(
            children: [
              AvatarStack(names: team, max: 5),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  team
                      .map(
                        (n) => n == ProviaMockData.currentUserName ? 'Sen' : n,
                      )
                      .join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GitHub teslimi ve AI raporu
// ---------------------------------------------------------------------------

class _SubmissionCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isAnalyzing;
  final VoidCallback onSubmit;

  const _SubmissionCard({
    required this.controller,
    required this.isAnalyzing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      style: ProviaTheme.mono(size: 13, weight: FontWeight.w500),
      decoration: const InputDecoration(
        prefixIcon: Icon(LucideIcons.github, size: 18),
        hintText: 'https://github.com/kullanici/proje',
      ),
    );
    final button = ElevatedButton.icon(
      onPressed: isAnalyzing ? null : onSubmit,
      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 46)),
      icon: isAnalyzing
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ProviaTheme.onPrimary,
              ),
            )
          : const Icon(LucideIcons.sparkles, size: 16),
      label: Text(
        isAnalyzing ? 'Analiz ediliyor...' : 'Teslim Et ve Değerlendir',
      ),
    );

    return ProviaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              IconBox(icon: LucideIcons.github, color: ProviaTheme.textMuted),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GitHub Teslimi & AI Değerlendirme',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Depo bağlantını gönder; kod kalitesi ve bireysel katkı '
                      'tahmini çıkarılsın.',
                      style: TextStyle(
                        color: ProviaTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 560) {
                return Row(
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: 10),
                    button,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [field, const SizedBox(height: 10), button],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Contribution {
  final String name;
  final String role;
  final double share;
  final int commits;
  final int prs;

  const _Contribution(this.name, this.role, this.share, this.commits, this.prs);
}

class _AiReportCard extends StatelessWidget {
  final ProviaProject project;
  final List<ProviaTask> tasks;

  const _AiReportCard({required this.project, required this.tasks});

  /// MVP simülasyonu: katkı payı, kişiye atanan görevlerin XP ağırlığından
  /// tahmin edilir. Gerçek analiz Faz 3'te GitHub API + Gemini ile gelecek.
  List<_Contribution> _contributions() {
    final totalXp = tasks.fold<int>(0, (sum, t) => sum + t.xp);
    final byPerson = <String, (String, int)>{};
    for (final t in tasks) {
      final name = ProviaMockData.displayName(t.assignee);
      final prev = byPerson[name];
      byPerson[name] = (prev?.$1 ?? t.role, (prev?.$2 ?? 0) + t.xp);
    }
    final list = [
      for (final e in byPerson.entries)
        _Contribution(
          e.key,
          e.value.$1,
          totalXp == 0 ? 0 : e.value.$2 / totalXp,
          ((totalXp == 0 ? 0 : e.value.$2 / totalXp) * 38).round() + 2,
          ((totalXp == 0 ? 0 : e.value.$2 / totalXp) * 9).round().clamp(1, 9),
        ),
    ]..sort((a, b) => b.share.compareTo(a.share));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _contributions();

    return ProviaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Değerlendirme Raporu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(
                      label: 'MVP Simülasyonu',
                      color: ProviaTheme.warning,
                      icon: LucideIcons.flaskConical,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ProviaTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ProviaTheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '88',
                        style: ProviaTheme.mono(
                          size: 24,
                          weight: FontWeight.w800,
                          color: ProviaTheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: '/100',
                        style: ProviaTheme.mono(
                          size: 13,
                          color: ProviaTheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _ScoreRow(label: 'Kod Kalitesi & Mimari', score: 0.90),
          const _ScoreRow(label: 'Gereksinimlere Uyum', score: 0.88),
          const _ScoreRow(label: 'Güvenlik & Dokümantasyon', score: 0.82),
          const SizedBox(height: 12),
          const Text(
            'Bireysel Katkı Tahmini',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ProviaTheme.borderDark),
            ),
            child: Column(
              children: [
                const _ContributionHeader(),
                for (final row in rows) ...[
                  const Divider(),
                  _ContributionRow(row: row),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.info, size: 13, color: ProviaTheme.textSubtle),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bu rapor MVP simülasyonudur; gerçek bir AI analizi değildir. '
                  'Katkı payı görev ağırlıklarından tahmin edilir; itiraz ve '
                  'mentor incelemesine açıktır.',
                  style: TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContributionHeader extends StatelessWidget {
  const _ContributionHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: ProviaTheme.textSubtle,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text('Üye', style: style)),
          SizedBox(width: 64, child: Text('Pay', style: style)),
          SizedBox(
            width: 52,
            child: Text('Commit', textAlign: TextAlign.right, style: style),
          ),
          SizedBox(
            width: 32,
            child: Text('PR', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _ContributionRow extends StatelessWidget {
  final _Contribution row;

  const _ContributionRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final isMe = row.name == ProviaMockData.currentUserName;
    return Container(
      color: isMe ? ProviaTheme.primary.withValues(alpha: 0.06) : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          ProviaAvatar(name: row.name, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isMe ? '${row.name} (Sen)' : row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '%${(row.share * 100).round()}',
              style: ProviaTheme.mono(
                size: 12,
                color: isMe ? ProviaTheme.primary : ProviaTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              '${row.commits}',
              textAlign: TextAlign.right,
              style: ProviaTheme.mono(size: 12, color: ProviaTheme.textMuted),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${row.prs}',
              textAlign: TextAlign.right,
              style: ProviaTheme.mono(size: 12, color: ProviaTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double score;

  const _ScoreRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ProviaTheme.textMuted,
                  ),
                ),
              ),
              Text(
                '${(score * 100).round()}',
                style: ProviaTheme.mono(size: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ProviaProgressBar(value: score, height: 4),
        ],
      ),
    );
  }
}

class _EmptyWorkspace extends StatelessWidget {
  final VoidCallback onGoToMarketplace;

  const _EmptyWorkspace({required this.onGoToMarketplace});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ProviaCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconBox(
                  icon: LucideIcons.layers,
                  color: ProviaTheme.primary,
                  size: 40,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Henüz bir projen yok',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Keşfet sekmesinden bir projeye katıl; görev panon ve GitHub '
                  'teslimin burada görünecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onGoToMarketplace,
                  icon: const Icon(LucideIcons.compass, size: 16),
                  label: const Text('Projeleri Keşfet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
