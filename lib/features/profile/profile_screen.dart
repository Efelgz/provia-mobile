// SAHİBİ: Kişi 2 — Profil (Öğrenci Profili & Portfolyo) ekranları.
// Constructor imzası main.dart ile anlaşmadır, değiştirme:
//   ProfileScreen({required int userXp})
// userXp: kullanıcının canlı XP değeri (seviye = userXp ~/ 400 + 1).
//
// StudentProfileScreen: Sıralama'da bir öğrenciye dokununca açılan sayfa.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../models/provia_models.dart';
import 'profile_data.dart';

/// Alt menüdeki "Profil" sekmesi: kullanıcının kendi profili.
class ProfileScreen extends StatelessWidget {
  final int userXp;

  const ProfileScreen({super.key, required this.userXp});

  @override
  Widget build(BuildContext context) {
    final me = ProviaMockData.rankedLeaderboard(
      userXp,
    ).firstWhere(ProviaMockData.isCurrentUser);
    return ProfileView(user: me, isMe: true);
  }
}

/// Sıralama ekranından açılan, başka bir öğrencinin (veya kendinin) profili.
class StudentProfileScreen extends StatelessWidget {
  final LeaderboardUser user;
  final bool isMe;

  const StudentProfileScreen({
    super.key,
    required this.user,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isMe ? 'Profilin' : 'Öğrenci Profili')),
      body: ProfileView(user: user, isMe: isMe),
    );
  }
}

/// Profil içeriği. Hem "Profil" sekmesi hem de öğrenci sayfası kullanır.
class ProfileView extends StatelessWidget {
  final LeaderboardUser user;
  final bool isMe;

  const ProfileView({super.key, required this.user, required this.isMe});

  Future<void> _sharePortfolio(
    BuildContext context,
    StudentProfile profile,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: 'provia.app/portfolyo/${profile.githubHandle}'),
    );
    if (!context.mounted) return;
    _showMessage(context, 'Portfolyo bağlantısı kopyalandı (demo bağlantı).');
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final profile = profileFor(user.name);
    final int xpInLevel = user.xp % 400;
    final subtitle = [
      user.university,
      if (profile.classYear.isNotEmpty) profile.classYear,
    ].join(' • ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profil başlığı
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: ProviaTheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          color: ProviaTheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 8),
                                const _SmallTag(
                                  text: 'Sen',
                                  color: ProviaTheme.primary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ProviaTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.focus,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(label: 'Sıra', value: '#${user.rank}'),
                    ),
                    Expanded(
                      child: _MiniStat(label: 'Seviye', value: '${user.level}'),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Proje',
                        value: '${user.completedProjects}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Toplam ${user.xp} XP',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$xpInLevel / 400 XP',
                      style: const TextStyle(
                        color: ProviaTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: xpInLevel / 400,
                    minHeight: 8,
                    backgroundColor: ProviaTheme.borderDark,
                    color: ProviaTheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: isMe
                      ? OutlinedButton.icon(
                          onPressed: () => _sharePortfolio(context, profile),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ProviaTheme.textPrimary,
                            side: const BorderSide(
                              color: ProviaTheme.borderDark,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(LucideIcons.share2, size: 16),
                          label: const Text('Portfolyoyu Paylaş'),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => _showMessage(
                            context,
                            '${profile.name} adlı öğrenciye takım daveti '
                            'gönderildi (demo).',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProviaTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(LucideIcons.userPlus, size: 16),
                          label: const Text('Takımına Davet Et'),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Rozetler
        if (profile.badges.isNotEmpty) ...[
          const _SectionTitle('Rozetler'),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final badge in profile.badges)
                    SizedBox(
                      width: itemWidth,
                      child: _BadgeCard(badge: badge),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],

        // Yetenekler
        if (profile.skills.isNotEmpty) ...[
          const _SectionTitle('Yetenekler'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in profile.skills)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ProviaTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ProviaTheme.borderDark),
                  ),
                  child: Text(skill, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // Doğrulanmış portfolyo
        const _SectionTitle('Doğrulanmış Portfolyo'),
        const SizedBox(height: 4),
        const Text(
          'Katkı puanları MVP simülasyonudur; mentor incelemesine açıktır.',
          style: TextStyle(color: ProviaTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        if (profile.portfolio.isEmpty)
          const Text(
            'Henüz doğrulanmış proje yok.',
            style: TextStyle(color: ProviaTheme.textMuted),
          ),
        for (final item in profile.portfolio) _PortfolioCard(item: item),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: ProviaTheme.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final ProfileBadge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final color = badge.earned ? ProviaTheme.warning : ProviaTheme.textMuted;

    return Opacity(
      opacity: badge.earned ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ProviaTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ProviaTheme.borderDark),
        ),
        child: Row(
          children: [
            Icon(
              badge.earned ? badge.icon : LucideIcons.lock,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    badge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 11,
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

class _PortfolioCard extends StatelessWidget {
  final PortfolioItem item;

  const _PortfolioCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.badgeCheck,
                  size: 14,
                  color: ProviaTheme.accent,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Doğrulandı',
                  style: TextStyle(
                    color: ProviaTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${item.company} • ${item.role}',
              style: const TextStyle(
                color: ProviaTheme.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tech in item.technologies)
                        Text(
                          '#$tech',
                          style: const TextStyle(
                            color: ProviaTheme.primary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  'Katkı: ${item.contributionScore}/100',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
