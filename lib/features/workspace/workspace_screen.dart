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
          const SizedBox(height: 20),
        ],
        _ProjectHeader(project: project, tasks: tasks),
        const SizedBox(height: 24),
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
                UnderlineTabs<String>(
                  value: _mobileStatus,
                  onChanged: (v) => setState(() => _mobileStatus = v),
                  tabs: [
                    for (final s in _statuses)
                      ProviaSegment(
                        s.name,
                        s.shortLabel,
                        count: tasks.where((t) => t.status == s.name).length,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _TaskList(
                  tasks: visible,
                  status: current,
                  onTapTask: _cycleTaskStatus,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _SubmissionBar(
          controller: _repoController,
          isAnalyzing: _isAnalyzing,
          onSubmit: _runSimulatedAiEvaluation,
        ),
        if (_showAiReport) ...[
          const SizedBox(height: 16),
          _AiReport(tasks: tasks, repoUrl: _repoController.text),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Proje başlığı
// ---------------------------------------------------------------------------

class _ProjectHeader extends StatelessWidget {
  final ProviaProject project;
  final List<ProviaTask> tasks;

  const _ProjectHeader({required this.project, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completion = ProviaMockData.completionFor(project.id);
    final done = tasks.where((t) => t.status == 'Tamamlandı').length;
    final team = ProviaMockData.teamFor(project.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: ProviaTheme.heading(size: 20)),
                  const SizedBox(height: 4),
                  Text(
                    metaLine([
                      project.company,
                      'Teslim ${ProviaMockData.deadlineLabel(project)}',
                      '${team.length} kişi',
                    ]),
                    style: const TextStyle(
                      color: ProviaTheme.textSubtle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AvatarStack(names: team, max: 5),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: ProviaProgressBar(value: completion)),
            const SizedBox(width: 12),
            Text(
              '$done/${tasks.length}  ·  %${(completion * 100).round()}',
              style: ProviaTheme.mono(size: 11, color: ProviaTheme.textMuted),
            ),
          ],
        ),
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

  const _StatusInfo(this.name, this.shortLabel, this.color, this.actionLabel);
}

const _statuses = [
  _StatusInfo('Yapılacak', 'Yapılacak', ProviaTheme.textSubtle, 'Başlat'),
  _StatusInfo('Devam Ediyor', 'Devam', ProviaTheme.warning, 'Tamamla'),
  _StatusInfo('Tamamlandı', 'Bitti', ProviaTheme.accent, 'Geri al'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
          child: Row(
            children: [
              StatusDot(status.color),
              const SizedBox(width: 8),
              Text(
                status.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${tasks.length}',
                style: ProviaTheme.mono(
                  size: 11,
                  color: ProviaTheme.textSubtle,
                ),
              ),
            ],
          ),
        ),
        _TaskList(tasks: tasks, status: status, onTapTask: onTapTask),
      ],
    );
  }
}

/// Tek kenarlıklı görev listesi; görevler 1px ayraçla bölünür.
class _TaskList extends StatelessWidget {
  final List<ProviaTask> tasks;
  final _StatusInfo status;
  final ValueChanged<ProviaTask> onTapTask;

  const _TaskList({
    required this.tasks,
    required this.status,
    required this.onTapTask,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ProviaTheme.radius),
          border: Border.all(color: ProviaTheme.borderDark),
        ),
        child: const Text(
          'Görev yok',
          textAlign: TextAlign.center,
          style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
        ),
      );
    }
    return ProviaPanel(
      children: [
        for (final t in tasks)
          _TaskRow(task: t, status: status, onTap: () => onTapTask(t)),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final ProviaTask task;
  final _StatusInfo status;
  final VoidCallback onTap;

  const _TaskRow({
    required this.task,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.status == 'Tamamlandı';
    final name = ProviaMockData.displayName(task.assignee);
    final isMine = task.assignee == 'Sen';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: done ? ProviaTheme.textSubtle : ProviaTheme.textPrimary,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: ProviaTheme.textSubtle,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ProviaAvatar(name: name, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    metaLine([isMine ? 'Sen' : name, task.role]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isMine
                          ? ProviaTheme.textMuted
                          : ProviaTheme.textSubtle,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  '+${task.xp}',
                  style: ProviaTheme.mono(size: 11, color: ProviaTheme.xp),
                ),
                const SizedBox(width: 10),
                Text(
                  status.actionLabel,
                  style: const TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GitHub teslimi ve AI raporu
// ---------------------------------------------------------------------------

class _SubmissionBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isAnalyzing;
  final VoidCallback onSubmit;

  const _SubmissionBar({
    required this.controller,
    required this.isAnalyzing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ProviaPanel(
      title: 'GitHub Teslimi',
      subtitle:
          'Depo bağlantını gönder; kod kalitesi ve bireysel katkı '
          'tahmini çıkarılsın.',
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: ProviaTheme.mono(size: 12),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(LucideIcons.github, size: 16),
                    hintText: 'https://github.com/kullanici/proje',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isAnalyzing ? null : onSubmit,
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 42)),
                icon: isAnalyzing
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: ProviaTheme.onPrimary,
                        ),
                      )
                    : const Icon(LucideIcons.play, size: 13),
                label: Text(isAnalyzing ? 'Analiz' : 'Değerlendir'),
              ),
            ],
          ),
        ),
      ],
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

class _AiReport extends StatelessWidget {
  final List<ProviaTask> tasks;
  final String repoUrl;

  const _AiReport({required this.tasks, required this.repoUrl});

  /// MVP simülasyonu: katkı payı, kişiye atanan görevlerin XP ağırlığından
  /// tahmin edilir. Gerçek analiz sonraki sürümde GitHub API ile gelecek.
  List<_Contribution> _contributions() {
    final totalXp = tasks.fold<int>(0, (sum, t) => sum + t.xp);
    final byPerson = <String, (String, int)>{};
    for (final t in tasks) {
      final name = ProviaMockData.displayName(t.assignee);
      final prev = byPerson[name];
      byPerson[name] = (prev?.$1 ?? t.role, (prev?.$2 ?? 0) + t.xp);
    }
    return [
      for (final e in byPerson.entries)
        () {
          final share = totalXp == 0 ? 0.0 : e.value.$2 / totalXp;
          return _Contribution(
            e.key,
            e.value.$1,
            share,
            (share * 38).round() + 2,
            (share * 9).round().clamp(1, 9),
          );
        }(),
    ]..sort((a, b) => b.share.compareTo(a.share));
  }

  @override
  Widget build(BuildContext context) {
    final rows = _contributions();
    final repo = repoUrl.replaceFirst('https://github.com/', '');

    return ProviaPanel(
      title: 'AI Değerlendirme Raporu',
      subtitle: metaLine(['MVP simülasyonu', repo]),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StatusBadge(
            label: 'Geçti',
            color: ProviaTheme.accent,
            icon: LucideIcons.check,
          ),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '88',
                  style: ProviaTheme.mono(size: 18, weight: FontWeight.w700),
                ),
                TextSpan(
                  text: '/100',
                  style: ProviaTheme.mono(
                    size: 12,
                    color: ProviaTheme.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      children: [
        const _ScoreRow(label: 'Kod kalitesi & mimari', score: 90),
        const _ScoreRow(label: 'Gereksinimlere uyum', score: 88),
        const _ScoreRow(label: 'Güvenlik & dokümantasyon', score: 82),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Text(
            'Bireysel Katkı Tahmini',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
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
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Text(
            'Not: Bu rapor MVP simülasyonudur, gerçek bir AI analizi değildir. '
            'Katkı payı görev ağırlıklarından tahmin edilir; itiraz ve mentor '
            'incelemesine açıktır.',
            style: TextStyle(
              color: ProviaTheme.textSubtle,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: ProviaTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: ProviaProgressBar(value: score / 100, height: 3),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: ProviaTheme.mono(size: 12),
            ),
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
      fontWeight: FontWeight.w500,
    );
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text('Üye', style: style)),
          SizedBox(width: 56, child: Text('Pay', style: style)),
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
      color: isMe ? ProviaTheme.surfaceElevated : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isMe ? '${row.name} (Sen)' : row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '%${(row.share * 100).round()}',
              style: ProviaTheme.mono(size: 12),
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

class _EmptyWorkspace extends StatelessWidget {
  final VoidCallback onGoToMarketplace;

  const _EmptyWorkspace({required this.onGoToMarketplace});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.layers,
                size: 22,
                color: ProviaTheme.textSubtle,
              ),
              const SizedBox(height: 12),
              const Text(
                'Henüz bir projen yok',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onGoToMarketplace,
                child: const Text('Projeleri Keşfet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
