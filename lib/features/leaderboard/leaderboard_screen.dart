// SAHİBİ: Kişi 2 — Sıralama (Liderlik Tablosu) ekranı.
// Constructor imzası main.dart ile anlaşmadır, değiştirme:
//   LeaderboardScreen({required int userXp})
// userXp: kullanıcının canlı XP değeri. "Sen" satırı bu değerle güncellenir
// ve sıralama her XP değişiminde yeniden hesaplanır. Bir satıra dokununca
// o öğrencinin profil sayfası (StudentProfileScreen) açılır.
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../models/provia_models.dart';
import '../profile/profile_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  final int userXp;

  const LeaderboardScreen({super.key, required this.userXp});

  static bool _isMe(LeaderboardUser user) => ProviaMockData.isCurrentUser(user);

  @override
  Widget build(BuildContext context) {
    final users = ProviaMockData.rankedLeaderboard(userXp);
    final me = users.firstWhere(_isMe);
    final above = me.rank > 1 ? users[me.rank - 2] : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Kasım 2026 Sıralaması',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Görev tamamlayarak ve proje teslim ederek XP kazan, üst sıralara çık.',
          style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Kullanıcının kendi durumu
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ProviaTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${me.rank}',
                    style: const TextStyle(
                      color: ProviaTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Senin sıran',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        above == null
                            ? 'Zirvedesin! Yerini korumak için üretmeye devam et.'
                            : '${above.name} adlı kullanıcıyı geçmek için ${above.xp - me.xp + 1} XP kaldı.',
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
        ),
        const SizedBox(height: 16),
        for (final user in users)
          _LeaderboardRow(user: user, isMe: _isMe(user)),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardUser user;
  final bool isMe;

  const _LeaderboardRow({required this.user, required this.isMe});

  Color? get _medalColor {
    switch (user.rank) {
      case 1:
        return const Color(0xFFFACC15);
      case 2:
        return const Color(0xFFCBD5E1);
      case 3:
        return const Color(0xFFD97706);
      default:
        return null;
    }
  }

  String get _initials {
    final parts = user.name
        .replaceAll('(Sen)', '')
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.take(2).map((p) => p[0]).join();
  }

  @override
  Widget build(BuildContext context) {
    final medal = _medalColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isMe
            ? ProviaTheme.primary.withValues(alpha: 0.10)
            : ProviaTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isMe
                ? ProviaTheme.primary.withValues(alpha: 0.5)
                : ProviaTheme.borderDark,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StudentProfileScreen(user: user, isMe: isMe),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: medal != null
                      ? Icon(LucideIcons.award, size: 20, color: medal)
                      : Text(
                          '${user.rank}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ProviaTheme.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: ProviaTheme.borderDark,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ProviaTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.university,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProviaTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Seviye ${user.level} • ${user.completedProjects} proje',
                        style: const TextStyle(
                          color: ProviaTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${user.xp} XP',
                  style: const TextStyle(
                    color: ProviaTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: ProviaTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
