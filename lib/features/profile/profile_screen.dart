// SAHİBİ: Kişi 2 — Profil (Öğrenci Profili & Portfolyo) ekranı.
// Bu dosya geçici bir iskelettir. İçeriği tamamen değiştirebilirsin,
// ancak sınıf adı ve constructor imzası main.dart ile anlaşmadır:
//   ProfileScreen({required int userXp})
// userXp: kullanıcının canlı XP değeri (seviye = userXp ~/ 400 + 1).
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final int userXp;

  const ProfileScreen({super.key, required this.userXp});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoon(
      icon: LucideIcons.user,
      title: 'Öğrenci Profili',
      subtitle: 'Doğrulanmış portfolyo ve rozetler yakında burada.',
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
