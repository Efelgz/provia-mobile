import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/theme/app_theme.dart';
import 'core/data/mock_data.dart';
import 'core/services/provia_storage.dart';
import 'core/services/provia_session.dart';
import 'core/widgets/provia_components.dart';
import 'core/widgets/provia_logo.dart';
import 'models/provia_models.dart';
import 'features/auth/auth_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/workspace/workspace_screen.dart';
// Kişi 2'nin ekranları. main.dart'a dokunmadan yalnızca bu dosyaların
// içeriğini değiştirir; constructor imzaları sabit kalır.
import 'features/marketplace/marketplace_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/teams/teams_screen.dart';
import 'features/events/events_screen.dart';
import 'features/company/company_screen.dart';

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
      // Geniş ekranda bildirimler ekran boyunca uzamasın.
      builder: (context, child) {
        if (!ProviaBreakpoints.isDesktop(context)) return child!;
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            snackBarTheme: theme.snackBarTheme.copyWith(width: 460),
          ),
          child: child!,
        );
      },
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

  // Takımlar ve Etkinlikler modülleri.
  final Set<String> _appliedTeamIds = {};
  final List<CreatedTeam> _createdTeams = [];
  final Set<String> _registeredEventIds = {};
  final Set<String> _awardedEventIds = {};

  List<ProviaProject> get _joinedProjects =>
      _joinedProjectIds.map(ProviaMockData.projectById).toList();

  final List<String> _titles = [
    'Ana Sayfa',
    'Projeleri Keşfet',
    'Çalışma Alanı',
    'Liderlik Tablosu',
    'Portfolyo & Profil',
    'Takımlar',
    'Etkinlikler',
    'Şirket Paneli',
  ];

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    ProviaMockData.currentUserName = account.name;
    ProviaMockData.currentUserUniversity = account.university;
    ProviaMockData.currentUserCompletedProjects = account.isDemo ? 3 : 0;
    _applyProgress(ProviaStorage.loadProgress(account));
    ProviaSession.invitedStudents.addListener(_save);
  }

  @override
  void dispose() {
    ProviaSession.invitedStudents.removeListener(_save);
    super.dispose();
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
    _appliedTeamIds
      ..clear()
      ..addAll(progress.appliedTeamIds);
    _createdTeams
      ..clear()
      ..addAll(progress.createdTeams);
    _registeredEventIds
      ..clear()
      ..addAll(progress.registeredEventIds);
    _awardedEventIds
      ..clear()
      ..addAll(progress.awardedEventIds);
    ProviaSession.invitedStudents.value = {...progress.invitedStudents};
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
      appliedTeamIds: Set.of(_appliedTeamIds),
      createdTeams: List.of(_createdTeams),
      registeredEventIds: Set.of(_registeredEventIds),
      awardedEventIds: Set.of(_awardedEventIds),
      invitedStudents: Set.of(ProviaSession.invitedStudents.value),
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

  void _applyToTeam(String teamId) =>
      _update(() => _appliedTeamIds.add(teamId));

  void _withdrawFromTeam(String teamId) =>
      _update(() => _appliedTeamIds.remove(teamId));

  void _createTeam(CreatedTeam team) => _update(() => _createdTeams.add(team));

  /// Etkinlik kaydı aç/kapat. XP yalnızca o etkinliğe ilk kayıtta verilir.
  void _toggleEvent(String eventId, int xpReward) {
    _update(() {
      if (_registeredEventIds.remove(eventId)) return;
      _registeredEventIds.add(eventId);
      if (_awardedEventIds.add(eventId)) _userXp += xpReward;
    });
  }

  /// Takımlar (5), Etkinlikler (6), Şirket Paneli (7) sayfaları.
  Widget _modulePage(int index) => switch (index) {
    5 => TeamsScreen(
      joinedProjects: _joinedProjects,
      appliedTeamIds: _appliedTeamIds,
      createdTeams: _createdTeams,
      onApply: _applyToTeam,
      onWithdraw: _withdrawFromTeam,
      onCreateTeam: _createTeam,
    ),
    6 => EventsScreen(
      registeredEventIds: _registeredEventIds,
      onToggleRegistration: _toggleEvent,
    ),
    _ => const CompanyScreen(),
  };

  /// Mobilde alt menü 5 öğeyle sınırlı; diğer modüller ayrı sayfa açılır.
  void _openModuleOnMobile(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(_titles[index])),
          body: _modulePage(index),
        ),
      ),
    );
  }

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
        evaluatedProjectIds: _evaluatedProjectIds,
        onSelectProject: _selectProject,
        onGoToWorkspace: () => setState(() => _currentIndex = 2),
        onGoToMarketplace: () => setState(() => _currentIndex = 1),
        onGoToLeaderboard: () => setState(() => _currentIndex = 3),
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
      _modulePage(5),
      _modulePage(6),
      _modulePage(7),
    ];

    final body = IndexedStack(index: _currentIndex, children: pages);
    final notifications = _buildNotifications();

    // Geniş ekran: sol menü + üst başlık + ortalanmış içerik.
    if (ProviaBreakpoints.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              currentIndex: _currentIndex,
              onSelect: (i) => setState(() => _currentIndex = i),
              account: widget.account,
              userXp: _userXp,
              onReset: _confirmReset,
              onSignOut: widget.onSignOut,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  _TopHeader(
                    title: _desktopTitles[_currentIndex],
                    userXp: _userXp,
                    notifications: notifications,
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobil: üst bar + alt menü.
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: ProviaHomeLink(
          onTap: () => setState(() => _currentIndex = 0),
          child: _currentIndex == 0
              ? const ProviaLogo(height: 24)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LogoMark(size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _titles[_currentIndex],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          _XpPill(xp: _userXp, compact: true),
          PopupMenuButton<String>(
            tooltip: 'Hesap menüsü',
            icon: const Icon(LucideIcons.moreVertical, size: 20),
            onSelected: (value) {
              if (value == 'reset') _confirmReset();
              if (value == 'logout') widget.onSignOut();
              if (value == 'teams') _openModuleOnMobile(5);
              if (value == 'events') _openModuleOnMobile(6);
              if (value == 'company') _openModuleOnMobile(7);
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
                value: 'teams',
                child: _MenuRow(icon: LucideIcons.users, label: 'Takımlar'),
              ),
              const PopupMenuItem(
                value: 'events',
                child: _MenuRow(
                  icon: LucideIcons.calendarDays,
                  label: 'Etkinlikler',
                ),
              ),
              const PopupMenuItem(
                value: 'company',
                child: _MenuRow(
                  icon: LucideIcons.building2,
                  label: 'Şirket Paneli (Önizleme)',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: _MenuRow(
                  icon: LucideIcons.rotateCcw,
                  label: 'İlerlemeyi Sıfırla',
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: _MenuRow(icon: LucideIcons.logOut, label: 'Çıkış Yap'),
              ),
            ],
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ProviaTheme.borderDark)),
        ),
        child: NavigationBar(
          // Modül sayfaları (5+) masaüstünde açıksa mobil menüde Panel seçili.
          selectedIndex: _currentIndex < 5 ? _currentIndex : 0,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.home),
              label: 'Ana Sayfa',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.compass),
              label: 'Keşfet',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.terminalSquare),
              label: 'Alanım',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.trophy),
              label: 'Sıralama',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.userCircle),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  /// Bildirimler: açık görevler ve sıralama durumu (demo verisinden).
  List<String> _buildNotifications() {
    final items = <String>[];
    for (final project in _joinedProjects) {
      final open = ProviaMockData.tasksFor(
        project.id,
      ).where((t) => t.assignee == 'Sen' && t.status != 'Tamamlandı').length;
      if (open > 0) {
        items.add('${project.title}: $open açık görevin var.');
      }
    }
    final rank = ProviaMockData.rankedLeaderboard(
      _userXp,
    ).firstWhere(ProviaMockData.isCurrentUser).rank;
    items.add('Aylık sıralamada #$rank sıradasın.');
    return items;
  }
}

const _desktopTitles = [
  'Ana Sayfa',
  'Projeleri Keşfet',
  'Proje Çalışma Alanı',
  'Liderlik Tablosu',
  'Profil & Portfolyo',
  'Takımlar',
  'Etkinlikler',
  'Şirket Paneli',
];

class _NavEntry {
  /// IndexedStack içindeki sayfa sırası.
  final int index;
  final IconData icon;
  final String label;

  const _NavEntry(this.index, this.icon, this.label);
}

const _studentEntries = [
  _NavEntry(0, LucideIcons.home, 'Ana Sayfa'),
  _NavEntry(1, LucideIcons.compass, 'Projeleri Keşfet'),
  _NavEntry(2, LucideIcons.terminalSquare, 'Proje Çalışma Alanı'),
  _NavEntry(5, LucideIcons.users, 'Takımlar'),
  _NavEntry(3, LucideIcons.trophy, 'Liderlik Tablosu'),
  _NavEntry(6, LucideIcons.calendarDays, 'Etkinlikler'),
  _NavEntry(4, LucideIcons.userCircle, 'Profil & Portfolyo'),
];

class _LogoMark extends StatelessWidget {
  final double size;

  const _LogoMark({this.size = 24});

  @override
  Widget build(BuildContext context) => ProviaLogoMark(size: size);
}

/// "1450 XP · Sv. 4" — kılcal kenarlıklı, sade.
class _XpPill extends StatelessWidget {
  final int xp;
  final bool compact;

  const _XpPill({required this.xp, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final level = (xp ~/ 400) + 1;
    return Semantics(
      label: '$xp XP, seviye $level',
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
          border: Border.all(color: ProviaTheme.borderDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$xp XP',
              style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
            ),
            if (!compact) ...[
              Text(
                '  ·  ',
                style: ProviaTheme.mono(
                  size: 12,
                  color: ProviaTheme.textSubtle,
                ),
              ),
              Text(
                'Sv. $level',
                style: ProviaTheme.mono(size: 12, color: ProviaTheme.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: ProviaTheme.textMuted),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Masaüstü üst başlığı: sayfa adı + XP + bildirimler.
class _TopHeader extends StatelessWidget {
  final String title;
  final int userXp;
  final List<String> notifications;

  const _TopHeader({
    required this.title,
    required this.userXp,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: ProviaTheme.bgDark,
        border: Border(bottom: BorderSide(color: ProviaTheme.borderDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          _XpPill(xp: userXp),
          const SizedBox(width: 8),
          PopupMenuButton<int>(
            tooltip: 'Bildirimler',
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                height: 32,
                child: Text(
                  'Bildirimler',
                  style: TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final n in notifications)
                PopupMenuItem(
                  enabled: false,
                  height: 36,
                  child: Text(
                    n,
                    style: const TextStyle(
                      color: ProviaTheme.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
                border: Border.all(color: ProviaTheme.borderDark),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    LucideIcons.bell,
                    size: 14,
                    color: ProviaTheme.textMuted,
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 7,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: ProviaTheme.textPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Masaüstü sol menüsü (220px).
class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final ProviaAccount account;
  final int userXp;
  final VoidCallback onReset;
  final VoidCallback onSignOut;

  const _Sidebar({
    required this.currentIndex,
    required this.onSelect,
    required this.account,
    required this.userXp,
    required this.onReset,
    required this.onSignOut,
  });

  static const _sectionStyle = TextStyle(
    color: ProviaTheme.textSubtle,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    final level = (userXp ~/ 400) + 1;
    final school = account.university.split('•').first.trim();

    return Container(
      width: 220,
      color: ProviaTheme.bgDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ProviaHomeLink(
                    onTap: () => onSelect(0),
                    child: const ProviaLogo(height: 24),
                  ),
                  const Spacer(),
                  Text(
                    'v1.0',
                    style: ProviaTheme.mono(
                      size: 11,
                      color: ProviaTheme.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 6),
                  child: Text('Öğrenci', style: _sectionStyle),
                ),
                for (final entry in _studentEntries)
                  _SidebarItem(
                    icon: entry.icon,
                    label: entry.label,
                    selected: entry.index == currentIndex,
                    onTap: () => onSelect(entry.index),
                  ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 6),
                  child: Text('Şirket', style: _sectionStyle),
                ),
                _SidebarItem(
                  icon: LucideIcons.building2,
                  label: 'Şirket Paneli',
                  selected: currentIndex == 7,
                  trailingText: 'Önizleme',
                  onTap: () => onSelect(7),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: _SidebarItem(
              icon: LucideIcons.rotateCcw,
              label: 'Demo verilerini sıfırla',
              selected: false,
              muted: true,
              onTap: onReset,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 10),
            child: Row(
              children: [
                ProviaAvatar(name: account.name, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        metaLine([school, 'Sv. $level']),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProviaTheme.textSubtle,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Çıkış Yap',
                  onPressed: onSignOut,
                  icon: const Icon(LucideIcons.logOut, size: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool muted;
  final String? trailingText;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.muted = false,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? ProviaTheme.textPrimary
        : (muted ? ProviaTheme.textSubtle : ProviaTheme.textMuted);

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: selected ? ProviaTheme.surfaceElevated : Colors.transparent,
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
                if (trailingText != null)
                  Text(
                    trailingText!,
                    style: ProviaTheme.mono(
                      size: 10,
                      color: ProviaTheme.textSubtle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
