// SAHİBİ: Kişi 2 — Sıralama (Liderlik Tablosu) ekranı.
// Bu dosya geçici bir iskelettir. İçeriği tamamen değiştirebilirsin,
// ancak sınıf adı ve constructor imzası main.dart ile anlaşmadır:
//   LeaderboardScreen({required int userXp})
// userXp: kullanıcının canlı XP değeri ("Sen" satırını güncel göstermek için).
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  final int userXp;

  const LeaderboardScreen({super.key, required this.userXp});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoon(
      icon: LucideIcons.trophy,
      title: 'Liderlik Tablosu',
      subtitle: 'Aylık XP sıralaması yakında burada.',
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
