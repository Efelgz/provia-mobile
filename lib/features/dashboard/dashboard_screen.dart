import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  final int userXp;
  final VoidCallback onGoToWorkspace;
  final VoidCallback onGoToMarketplace;

  const DashboardScreen({
    super.key,
    required this.userXp,
    required this.onGoToWorkspace,
    required this.onGoToMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    final int level = (userXp ~/ 400) + 1;
    final double levelProgress = (userXp % 400) / 400;
    final activeProject = ProviaMockData.projects.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Hoş geldin 👋',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'İlk stajından önce gerçek projelerle deneyim kazan.',
          style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Seviye ve XP Kartı
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Seviye $level • Geliştirici',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$userXp XP',
                      style: const TextStyle(
                        color: ProviaTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: levelProgress,
                    minHeight: 8,
                    backgroundColor: ProviaTheme.borderDark,
                    color: ProviaTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sonraki seviyeye ${400 - (userXp % 400)} XP kaldı',
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Hızlı İstatistikler
        const Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.code2,
                label: 'Tamamlanan',
                value: '3 Proje',
                color: ProviaTheme.primary,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.flame,
                label: 'Aylık Sıra',
                value: '#4',
                color: ProviaTheme.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Aktif Proje
        const Text(
          'Aktif Projen',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ProviaTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          activeProject.company,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ProviaTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Spacer(),
                    const Icon(
                      LucideIcons.clock,
                      size: 13,
                      color: ProviaTheme.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeProject.deadline,
                      style: const TextStyle(
                        color: ProviaTheme.warning,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  activeProject.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activeProject.description,
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onGoToWorkspace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProviaTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(LucideIcons.arrowRight, size: 16),
                    label: const Text('Çalışma Alanına Git'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        OutlinedButton.icon(
          onPressed: onGoToMarketplace,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: ProviaTheme.borderDark),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(LucideIcons.compass, size: 18),
          label: const Text('Şirket Destekli Yeni Projeleri Keşfet'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
