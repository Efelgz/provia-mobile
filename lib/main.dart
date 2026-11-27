import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/theme/app_theme.dart';
import 'core/data/mock_data.dart';
import 'core/services/provia_storage.dart';
import 'core/widgets/provia_components.dart';
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

  void _showSoon(String module) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$module modülü yakında geliyor (yol haritası).'),
        ),
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
              onSoon: _showSoon,
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
        title: Row(
          children: [
            const _LogoMark(size: 26),
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
          _XpPill(xp: _userXp, compact: true),
          PopupMenuButton<String>(
            tooltip: 'Hesap menüsü',
            icon: const Icon(LucideIcons.moreVertical, size: 20),
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
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutGrid),
              label: 'Panel',
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
  'Genel Bakış',
  'Projeleri Keşfet',
  'Proje Çalışma Alanı',
  'Liderlik Tablosu',
  'Profil & Portfolyo',
];

class _NavEntry {
  /// Sayfa sırası; null ise modül henüz hazır değil.
  final int? index;
  final IconData icon;
  final String label;

  const _NavEntry(this.index, this.icon, this.label);
}

const _studentEntries = [
  _NavEntry(0, LucideIcons.layoutGrid, 'Genel Bakış'),
  _NavEntry(1, LucideIcons.compass, 'Projeleri Keşfet'),
  _NavEntry(2, LucideIcons.terminalSquare, 'Proje Çalışma Alanı'),
  _NavEntry(null, LucideIcons.users, 'Takımlar'),
  _NavEntry(3, LucideIcons.trophy, 'Liderlik Tablosu'),
  _NavEntry(null, LucideIcons.calendarDays, 'Etkinlikler'),
  _NavEntry(4, LucideIcons.userCircle, 'Profil & Portfolyo'),
];

class _LogoMark extends StatelessWidget {
  final double size;

  const _LogoMark({this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ProviaTheme.primary,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Text(
        'P',
        style: TextStyle(
          color: ProviaTheme.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.52,
        ),
      ),
    );
  }
}

/// "1450 XP | Sv. 4" hapı.
class _XpPill extends StatelessWidget {
  final int xp;
  final bool compact;

  const _XpPill({required this.xp, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final level = (xp ~/ 400) + 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ProviaTheme.xp.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ProviaTheme.xp.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.zap, size: 13, color: ProviaTheme.xp),
          const SizedBox(width: 6),
          Text(
            compact ? '$xp XP' : '$xp XP  |  Sv. $level',
            style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
          ),
        ],
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
        Icon(icon, size: 16),
        const SizedBox(width: 10),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

/// Masaüstü üst başlığı: sayfa adı + XP hapı + bildirimler.
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
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
              style: ProviaTheme.heading(size: 17),
            ),
          ),
          _XpPill(xp: userXp),
          const SizedBox(width: 10),
          PopupMenuButton<int>(
            tooltip: 'Bildirimler',
            offset: const Offset(0, 44),
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                height: 36,
                child: Text(
                  'BİLDİRİMLER',
                  style: TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              for (final n in notifications)
                PopupMenuItem(
                  enabled: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: ProviaTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          n,
                          style: const TextStyle(
                            color: ProviaTheme.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ProviaTheme.borderDark),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    LucideIcons.bell,
                    size: 16,
                    color: ProviaTheme.textMuted,
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 9,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: ProviaTheme.primary,
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

/// Masaüstü sol menüsü (260px).
class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<String> onSoon;
  final ProviaAccount account;
  final int userXp;
  final VoidCallback onReset;
  final VoidCallback onSignOut;

  const _Sidebar({
    required this.currentIndex,
    required this.onSelect,
    required this.onSoon,
    required this.account,
    required this.userXp,
    required this.onReset,
    required this.onSignOut,
  });

  static const _sectionStyle = TextStyle(
    color: ProviaTheme.textSubtle,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    final level = (userXp ~/ 400) + 1;
    final school = account.university.split('•').first.trim();

    return Container(
      width: 260,
      color: ProviaTheme.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ProviaTheme.borderDark)),
            ),
            child: Row(
              children: [
                const _LogoMark(size: 30),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROVIA',
                      style: ProviaTheme.heading(
                        size: 15,
                        weight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'MVP v1.0',
                      style: ProviaTheme.mono(
                        size: 10,
                        weight: FontWeight.w500,
                        color: ProviaTheme.textSubtle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 12),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text('ÖĞRENCİ PLATFORMU', style: _sectionStyle),
                ),
                for (final entry in _studentEntries)
                  _SidebarItem(
                    icon: entry.icon,
                    label: entry.label,
                    selected: entry.index == currentIndex,
                    trailing: entry.index == null
                        ? const StatusBadge(
                            label: 'Yakında',
                            color: ProviaTheme.textSubtle,
                          )
                        : null,
                    muted: entry.index == null,
                    onTap: () => entry.index == null
                        ? onSoon(entry.label)
                        : onSelect(entry.index!),
                  ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text('GELECEK MODÜLÜ', style: _sectionStyle),
                ),
                _SidebarItem(
                  icon: LucideIcons.building2,
                  label: 'Şirket Paneli',
                  selected: false,
                  muted: true,
                  trailing: StatusBadge(
                    label: 'Önizleme',
                    color: ProviaTheme.primary,
                    mono: true,
                  ),
                  onTap: () => onSoon('Şirket Paneli'),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: TextButton.icon(
              onPressed: onReset,
              style: TextButton.styleFrom(
                foregroundColor: ProviaTheme.textSubtle,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: const Icon(LucideIcons.rotateCcw, size: 14),
              label: const Text('Demo Verilerini Sıfırla'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 14),
            child: Row(
              children: [
                ProviaAvatar(name: account.name, size: 34),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$school • Sv. $level',
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
                  icon: const Icon(
                    LucideIcons.logOut,
                    size: 17,
                    color: ProviaTheme.textMuted,
                  ),
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
  final Widget? trailing;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.muted = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? ProviaTheme.primary
        : (muted ? ProviaTheme.textSubtle : ProviaTheme.textMuted);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected
            ? ProviaTheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? ProviaTheme.borderHighlight : Colors.transparent,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? ProviaTheme.primary : color,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
