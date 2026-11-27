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
import '../../core/services/provia_session.dart';
import '../../core/widgets/provia_components.dart';
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

  /// GitHub kullanıcı adı; boşsa addan üretilir ("Ece Tunç" -> "ece-tunc").
  static String handleFor(StudentProfile profile) =>
      profile.githubHandle.isNotEmpty
      ? profile.githubHandle
      : foldForSearch(profile.name).trim().replaceAll(RegExp(r'\s+'), '-');

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _share(BuildContext context, String handle) async {
    await Clipboard.setData(
      ClipboardData(text: 'provia.app/portfolyo/$handle'),
    );
    if (!context.mounted) return;
    _showMessage(context, 'Portfolyo bağlantısı kopyalandı (demo bağlantı).');
  }

  @override
  Widget build(BuildContext context) {
    final profile = profileFor(user.name);
    final handle = handleFor(profile);

    final action = isMe
        ? OutlinedButton.icon(
            onPressed: () => _share(context, handle),
            icon: const Icon(LucideIcons.share2, size: 13),
            label: const Text('Portfolyoyu Paylaş'),
          )
        // Davet durumu Takımlar ekranıyla ortak; tekrar dokununca iptal olur.
        : ValueListenableBuilder<Set<String>>(
            valueListenable: ProviaSession.invitedStudents,
            builder: (context, _, _) => ToggleActionButton(
              primary: true,
              icon: LucideIcons.userPlus,
              active: ProviaSession.isInvited(profile.name),
              label: 'Takımına Davet Et',
              activeLabel: 'Davet gönderildi',
              undoneLabel: 'Davet iptal edildi',
              onActivate: () {
                ProviaSession.toggleInvite(profile.name);
                _showMessage(
                  context,
                  '${profile.name} adlı öğrenciye takım daveti gönderildi (demo).',
                );
              },
              onUndo: () {
                ProviaSession.toggleInvite(profile.name);
                _showMessage(
                  context,
                  '${profile.name} için davet iptal edildi.',
                );
              },
            ),
          );

    return ProviaPageView(
      maxWidth: 880,
      children: [
        _Header(
          profile: profile,
          user: user,
          handle: handle,
          isMe: isMe,
          action: action,
        ),
        const SizedBox(height: 24),
        const Divider(),
        if (profile.skills.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _Label('Yetenekler'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [for (final s in profile.skills) TechChip(s)],
          ),
        ],
        if (profile.badges.isNotEmpty) ...[
          const SizedBox(height: 24),
          _Label(
            'Rozetler',
            trailing:
                '${profile.badges.where((b) => b.earned).length}/${profile.badges.length}',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [for (final b in profile.badges) _BadgeItem(badge: b)],
          ),
        ],
        const SizedBox(height: 28),
        const _Label('Doğrulanmış Projeler'),
        const SizedBox(height: 10),
        if (profile.portfolio.isEmpty)
          const Text(
            'Henüz doğrulanmış proje yok. İlk projeni teslim ettiğinde burada '
            'görünecek.',
            style: TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
          )
        else
          ProviaPanel(
            children: [
              for (final item in profile.portfolio) _PortfolioRow(item: item),
            ],
          ),
        const SizedBox(height: 10),
        const Text(
          'Katkı puanları MVP simülasyonudur; mentor incelemesine açıktır.',
          style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 11),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final String? trailing;

  const _Label(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: ProviaTheme.mono(size: 11, color: ProviaTheme.textSubtle),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final StudentProfile profile;
  final LeaderboardUser user;
  final String handle;
  final bool isMe;
  final Widget action;

  const _Header({
    required this.profile,
    required this.user,
    required this.handle,
    required this.isMe,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ProviaTheme.heading(size: 20),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              const Text(
                'Sen',
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          metaLine([user.university, profile.classYear, '@$handle']),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              _stat('#${user.rank}', 'sıra'),
              _sep,
              _stat('Sv. ${user.level}', 'seviye'),
              _sep,
              _stat('${user.completedProjects}', 'proje'),
              _sep,
              TextSpan(
                text: '${user.xp} XP',
                style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
              ),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final avatar = ProviaAvatar(name: profile.name, size: 64);
        if (constraints.maxWidth >= 560) {
          return Row(
            children: [
              avatar,
              const SizedBox(width: 18),
              Expanded(child: info),
              const SizedBox(width: 16),
              action,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                avatar,
                const SizedBox(width: 14),
                Expanded(child: info),
              ],
            ),
            const SizedBox(height: 14),
            action,
          ],
        );
      },
    );
  }

  static TextSpan _stat(String value, String label) => TextSpan(
    children: [
      TextSpan(text: value, style: ProviaTheme.mono(size: 12)),
      TextSpan(
        text: ' $label',
        style: const TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
      ),
    ],
  );

  static const _sep = TextSpan(
    text: '   ·   ',
    style: TextStyle(color: ProviaTheme.borderStrong, fontSize: 12),
  );
}

class _BadgeItem extends StatelessWidget {
  final ProfileBadge badge;

  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    return Tooltip(
      message: badge.description,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            earned ? badge.icon : LucideIcons.lock,
            size: 14,
            color: earned ? ProviaTheme.textPrimary : ProviaTheme.textSubtle,
          ),
          const SizedBox(width: 6),
          Text(
            badge.title,
            style: TextStyle(
              fontSize: 13,
              color: earned ? ProviaTheme.textPrimary : ProviaTheme.textSubtle,
              decoration: earned ? null : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioRow extends StatelessWidget {
  final PortfolioItem item;

  const _PortfolioRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final good = item.contributionScore >= 85;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
                      style: TextStyle(color: ProviaTheme.accent, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  metaLine([item.company, item.role]),
                  style: const TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [for (final t in item.technologies) TechChip(t)],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.contributionScore}',
                      style: ProviaTheme.mono(
                        size: 16,
                        weight: FontWeight.w600,
                        color: good
                            ? ProviaTheme.textPrimary
                            : ProviaTheme.warning,
                      ),
                    ),
                    TextSpan(
                      text: '/100',
                      style: ProviaTheme.mono(
                        size: 11,
                        color: ProviaTheme.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'katkı',
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
