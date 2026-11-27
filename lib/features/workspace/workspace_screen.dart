import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/project_switcher.dart';
import '../../models/provia_models.dart';

class WorkspaceScreen extends StatefulWidget {
  final ProviaProject project;
  final List<ProviaProject> joinedProjects;
  final ValueChanged<String> onSelectProject;
  final Function(int) onEarnXp;

  const WorkspaceScreen({
    super.key,
    required this.project,
    required this.joinedProjects,
    required this.onSelectProject,
    required this.onEarnXp,
  });

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final TextEditingController _repoController = TextEditingController();
  bool _isAnalyzing = false;

  /// AI değerlendirmesi yapılmış projeler (XP yalnızca ilk teslimde verilir).
  final Set<String> _evaluatedProjectIds = {};

  bool get _showAiReport => _evaluatedProjectIds.contains(widget.project.id);

  @override
  void initState() {
    super.initState();
    _repoController.text = _demoRepoFor(widget.project.id);
  }

  @override
  void didUpdateWidget(covariant WorkspaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id) {
      _repoController.text = _demoRepoFor(widget.project.id);
      _isAnalyzing = false;
    }
  }

  @override
  void dispose() {
    _repoController.dispose();
    super.dispose();
  }

  String _demoRepoFor(String projectId) =>
      ProviaMockData.demoRepoUrls[projectId] ?? '';

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
  }

  Future<void> _runSimulatedAiEvaluation() async {
    if (_repoController.text.trim().isEmpty) return;
    final projectId = widget.project.id;
    final firstSubmission = !_evaluatedProjectIds.contains(projectId);
    setState(() {
      _isAnalyzing = true;
      _evaluatedProjectIds.remove(projectId);
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _evaluatedProjectIds.add(projectId);
    });
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
    final tasks = ProviaMockData.tasksFor(widget.project.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.joinedProjects.length > 1) ...[
          ProjectSwitcher(
            projects: widget.joinedProjects,
            activeProjectId: widget.project.id,
            onSelect: widget.onSelectProject,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          widget.project.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          widget.project.company,
          style: const TextStyle(color: ProviaTheme.primary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        const Text(
          'Takım Görevleri (Durumu değiştirmek için göreve dokun)',
          style: TextStyle(color: ProviaTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),

        ...tasks.map((task) {
          final bool done = task.status == 'Tamamlandı';
          final Color badgeColor = done
              ? ProviaTheme.accent
              : (task.status == 'Devam Ediyor'
                    ? ProviaTheme.warning
                    : ProviaTheme.textMuted);

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => _cycleTaskStatus(task),
              leading: Icon(
                done ? LucideIcons.checkCircle2 : LucideIcons.circle,
                color: badgeColor,
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '${task.assignee} • ${task.role} • +${task.xp} XP',
                style: const TextStyle(
                  color: ProviaTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        const Divider(color: ProviaTheme.borderDark),
        const SizedBox(height: 12),

        const Text(
          'GitHub Teslimi & AI Değerlendirme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _repoController,
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.github, size: 18),
            hintText: 'https://github.com/kullanici/proje',
            filled: true,
            fillColor: ProviaTheme.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ProviaTheme.borderDark),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _runSimulatedAiEvaluation,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProviaTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(LucideIcons.sparkles, size: 18),
            label: Text(
              _isAnalyzing
                  ? 'Kod ve Katkılar Analiz Ediliyor...'
                  : 'Projeyi Teslim Et ve AI ile Değerlendir',
            ),
          ),
        ),

        if (_showAiReport) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI Değerlendirme Raporu (Demo)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ProviaTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '88 / 100',
                          style: TextStyle(
                            color: ProviaTheme.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _ScoreRow(label: 'Kod Kalitesi & Mimari', score: 0.90),
                  const _ScoreRow(label: 'Gereksinimlere Uyum', score: 0.88),
                  const _ScoreRow(
                    label: 'Güvenlik & Dokümantasyon',
                    score: 0.82,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bireysel Katkı Tahmini: %44 (Yüksek Katkı — 14 anlamlı commit, 3 PR)',
                    style: TextStyle(
                      color: ProviaTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Not: Bu çıktı MVP simülasyonudur; itiraz veya mentor incelemesine açıktır.',
                    style: TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                '${(score * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score,
            minHeight: 6,
            backgroundColor: ProviaTheme.borderDark,
            color: ProviaTheme.primary,
          ),
        ],
      ),
    );
  }
}
