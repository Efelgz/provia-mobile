// SAHİBİ: Kişi 2 — Keşfet (Proje Pazarı) ekranı.
// Bu dosya geçici bir iskelettir. İçeriği tamamen değiştirebilirsin,
// ancak sınıf adı ve constructor imzası main.dart ile anlaşmadır:
//   MarketplaceScreen({required VoidCallback onJoinProject})
// Bir projeye katılınca onJoinProject() çağır (kullanıcıya +50 XP verir).
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';

class MarketplaceScreen extends StatelessWidget {
  final VoidCallback onJoinProject;

  const MarketplaceScreen({super.key, required this.onJoinProject});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoon(
      icon: LucideIcons.compass,
      title: 'Proje Pazarı',
      subtitle: 'Şirket destekli ve topluluk projeleri yakında burada.',
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ComingSoon({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: ProviaTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: ProviaTheme.textMuted)),
        ],
      ),
    );
  }
}
