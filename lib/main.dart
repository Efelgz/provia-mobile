import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/workspace/workspace_screen.dart';
// SEVGİLİN KENDİ DOSYALARINI EKLEYİNCE AŞAĞIDAKİ 3 SATIRIN YORUMUNU KALDIRACAK:
// import 'features/marketplace/marketplace_screen.dart';
// import 'features/leaderboard/leaderboard_screen.dart';
// import 'features/profile/profile_screen.dart';

void main() {
  runApp(const ProviaApp());
}

class ProviaApp extends StatelessWidget {
  const ProviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROVIA',
      debugShowCheckedModeBanner: false,
      theme: ProviaTheme.darkTheme,
      home: const ProviaMainShell(),
    );
  }
}

class ProviaMainShell extends StatefulWidget {
  const ProviaMainShell({super.key});

  @override
  State<ProviaMainShell> createState() => _ProviaMainShellState();
}

class _ProviaMainShellState extends State<ProviaMainShell> {
  int _currentIndex = 0;
  int _userXp = 1450;

  final List<String> _titles = [
    'PROVIA',
    'Projeleri Keşfet',
    'Çalışma Alanı',
    'Liderlik Tablosu',
    'Portfolyo & Profil',
  ];

  void _addXp(int amount) {
    setState(() => _userXp += amount);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        userXp: _userXp,
        onGoToWorkspace: () => setState(() => _currentIndex = 2),
        onGoToMarketplace: () => setState(() => _currentIndex = 1),
      ),
      // SEVGİLİN BURAYI MarketplaceScreen(onJoinProject: () => _addXp(50)) YAPACAK:
      const _PlaceholderScreen(
        title: 'Proje Pazarı',
        subtitle: 'Sevgilinin dalından gelecek',
      ),
      WorkspaceScreen(onEarnXp: _addXp),
      // SEVGİLİN BURAYI const LeaderboardScreen() YAPACAK:
      const _PlaceholderScreen(
        title: 'Liderlik Tablosu',
        subtitle: 'Sevgilinin dalından gelecek',
      ),
      // SEVGİLİN BURAYI ProfileScreen(userXp: _userXp) YAPACAK:
      const _PlaceholderScreen(
        title: 'Öğrenci Profili',
        subtitle: 'Sevgilinin dalından gelecek',
      ),
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
            Text(_titles[_currentIndex]),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
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

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PlaceholderScreen({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: ProviaTheme.textMuted)),
        ],
      ),
    );
  }
}
