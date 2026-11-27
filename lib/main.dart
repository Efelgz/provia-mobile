import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/theme/app_theme.dart';
import 'core/data/mock_data.dart';
import 'core/services/provia_storage.dart';
import 'models/provia_models.dart';
import 'features/auth/auth_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/workspace/workspace_screen.dart';
// Kişi 2'nin ekranları. main.dart'a dokunmadan yalnızca bu dosyaların
// içeriğini değiştirir; constructor imzaları sabit kalır.
import 'features/marketplace/marketplace_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/profile/profile_screen.dart';

void main() {
  runApp(const ProviaApp());
}

/// Uygulama kökü: kayıtlı oturumu yükler, giriş ekranı ile ana kabuk
/// arasında geçiş yapar.
class ProviaApp extends StatefulWidget {
  const ProviaApp({super.key});

  @override
  State<ProviaApp> createState() => _ProviaAppState();
}

class _ProviaAppState extends State<ProviaApp> {
  bool _ready = false;
  ProviaAccount? _account;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await ProviaStorage.init();
    if (!mounted) return;
    setState(() {
      _account = ProviaStorage.loadCurrentAccount();
      _ready = true;
    });
  }

  Future<void> _signIn(ProviaAccount account) async {
    await ProviaStorage.setCurrentAccount(account);
    if (!mounted) return;
    setState(() => _account = account);
  }

  Future<void> _signOut() async {
    await ProviaStorage.setCurrentAccount(null);
    if (!mounted) return;
    setState(() => _account = null);
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;
    final Widget home;
    if (!_ready) {
      home = const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else if (account == null) {
      home = AuthScreen(onSignedIn: _signIn);
    } else {
      home = ProviaMainShell(
        key: ValueKey(account.id),
        account: account,
        onSignOut: _signOut,
      );
    }

    return MaterialApp(
      title: 'PROVIA',
      debugShowCheckedModeBanner: false,
      theme: ProviaTheme.darkTheme,
      home: home,
    );
  }
}

class ProviaMainShell extends StatefulWidget {
  final ProviaAccount account;
  final VoidCallback onSignOut;

  const ProviaMainShell({
    super.key,
    required this.account,
    required this.onSignOut,
  });

  @override
  State<ProviaMainShell> createState() => _ProviaMainShellState();
}

class _ProviaMainShellState extends State<ProviaMainShell> {
  int _currentIndex = 0;
  int _userXp = 0;

  // Kullanıcının katıldığı projeler ve Panel/Alanım'da açık olan proje.
  final List<String> _joinedProjectIds = [];
  String? _activeProjectId;

  // AI değerlendirmesi yapılmış projeler (XP yalnızca ilk teslimde verilir).
  final Set<String> _evaluatedProjectIds = {};

  List<ProviaProject> get _joinedProjects =>
      _joinedProjectIds.map(ProviaMockData.projectById).toList();

  final List<String> _titles = [
    'PROVIA',
    'Projeleri Keşfet',
    'Çalışma Alanı',
    'Liderlik Tablosu',
    'Portfolyo & Profil',
  ];

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    ProviaMockData.currentUserName = account.name;
    ProviaMockData.currentUserUniversity = account.university;
    ProviaMockData.currentUserCompletedProjects = account.isDemo ? 3 : 0;
    _applyProgress(ProviaStorage.loadProgress(account));
  }

  /// Kayıtlı ilerlemeyi ekrana uygular (açılışta ve sıfırlamada).
  void _applyProgress(ProviaProgress progress) {
    final knownIds = ProviaMockData.projects.map((p) => p.id).toSet();

    ProviaMockData.resetTasks();
    for (final tasks in ProviaMockData.projectTasks.values) {
      for (final task in tasks) {
        final saved = progress.taskStates[task.id];
        if (saved != null) {
          task.status = saved.status;
          task.xpAwarded = saved.xpAwarded;
        }
      }
    }

    _userXp = progress.xp;
    _joinedProjectIds
      ..clear()
      ..addAll(progress.joinedProjectIds.where(knownIds.contains));
    _activeProjectId = _joinedProjectIds.contains(progress.activeProjectId)
        ? progress.activeProjectId
        : (_joinedProjectIds.isEmpty ? null : _joinedProjectIds.first);
    _evaluatedProjectIds
      ..clear()
      ..addAll(progress.evaluatedProjectIds);
  }

  /// Her değişiklikten sonra ilerleme cihaza kaydedilir.
  void _save() {
    final progress = ProviaProgress(
      xp: _userXp,
      joinedProjectIds: List.of(_joinedProjectIds),
      activeProjectId: _activeProjectId,
      evaluatedProjectIds: Set.of(_evaluatedProjectIds),
      taskStates: {
        for (final tasks in ProviaMockData.projectTasks.values)
          for (final task in tasks)
            task.id: TaskState(task.status, task.xpAwarded),
      },
    );
    unawaited(ProviaStorage.saveProgress(widget.account, progress));
  }

  void _update(VoidCallback change) {
    setState(change);
    _save();
  }

  void _addXp(int amount) => _update(() => _userXp += amount);

  void _selectProject(String projectId) =>
      _update(() => _activeProjectId = projectId);

  /// Yeni katılınan proje listeye eklenir ve otomatik olarak aktif olur.
  void _joinProject(ProviaProject project) {
    if (_joinedProjectIds.contains(project.id)) return;
    _update(() {
      _joinedProjectIds.add(project.id);
      _activeProjectId = project.id;
      _userXp += 50;
    });
  }

  void _markEvaluated(String projectId) =>
      _update(() => _evaluatedProjectIds.add(projectId));

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProviaTheme.surfaceDark,
        title: const Text('İlerlemeyi sıfırla?'),
        content: const Text(
          'XP, katıldığın projeler, görev durumları ve AI değerlendirmeleri '
          'başlangıç haline döner. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sıfırla',
              style: TextStyle(color: Color(0xFFF87171)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ProviaStorage.clearProgress(widget.account);
    if (!mounted) return;
    setState(() {
      _applyProgress(ProviaProgress.initialFor(widget.account));
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('İlerleme başlangıç haline döndü.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final activeId = _activeProjectId;

    final List<Widget> pages = [
      DashboardScreen(
        userXp: _userXp,
        joinedProjects: _joinedProjects,
        activeProjectId: activeId,
        onSelectProject: _selectProject,
        onGoToWorkspace: () => setState(() => _currentIndex = 2),
        onGoToMarketplace: () => setState(() => _currentIndex = 1),
      ),
      MarketplaceScreen(
        joinedProjectIds: _joinedProjectIds.toSet(),
        onJoinProject: _joinProject,
        onGoToDashboard: () => setState(() => _currentIndex = 0),
      ),
      WorkspaceScreen(
        project: activeId == null ? null : ProviaMockData.projectById(activeId),
        joinedProjects: _joinedProjects,
        evaluatedProjectIds: _evaluatedProjectIds,
        onSelectProject: _selectProject,
        onEarnXp: _addXp,
        onProjectEvaluated: _markEvaluated,
        onTasksChanged: _save,
        onGoToMarketplace: () => setState(() => _currentIndex = 1),
      ),
      LeaderboardScreen(userXp: _userXp),
      ProfileScreen(userXp: _userXp),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ProviaTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: ProviaTheme.primary.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'P',
                style: TextStyle(
                  color: ProviaTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                _titles[_currentIndex],
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ProviaTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ProviaTheme.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.zap,
                  size: 14,
                  color: ProviaTheme.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_userXp XP',
                  style: const TextStyle(
                    color: ProviaTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Hesap menüsü',
            icon: const Icon(LucideIcons.moreVertical, size: 20),
            color: ProviaTheme.surfaceDark,
            onSelected: (value) {
              if (value == 'reset') _confirmReset();
              if (value == 'logout') widget.onSignOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  '${widget.account.name}\n${widget.account.email}',
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(LucideIcons.rotateCcw, size: 16),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'İlerlemeyi Sıfırla',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 16),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text('Çıkış Yap', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ProviaTheme.borderDark, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: ProviaTheme.surfaceDark,
          indicatorColor: ProviaTheme.primary.withValues(alpha: 0.2),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard),
              label: 'Panel',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.compass),
              label: 'Keşfet',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.layers),
              label: 'Alanım',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.trophy),
              label: 'Sıralama',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.user),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
