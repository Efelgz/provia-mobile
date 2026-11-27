// SAHİBİ: Kişi 2 — Sıralama (Liderlik Tablosu) ekranı.
// Constructor imzası main.dart ile anlaşmadır, değiştirme:
//   LeaderboardScreen({required int userXp})
// userXp: kullanıcının canlı XP değeri. "Sen" satırı bu değerle güncellenir.
// Bireysel modda bir satıra dokununca öğrencinin profil sayfası açılır.
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/provia_components.dart';
import '../../models/provia_models.dart';
import '../profile/profile_screen.dart';
import 'leaderboard_data.dart';

enum _Period { monthly, yearly }

enum _Mode { individual, team }

/// Bireysel ve takım satırları için ortak tablo satırı modeli.
class _Row {
  final int rank;
  final String name;
  final String school;
  final String project;
  final String level;
  final int xp;
  final bool isMe;
  final LeaderboardUser? user;

  const _Row({
    required this.rank,
    required this.name,
    required this.school,
    required this.project,
    required this.level,
    required this.xp,
    required this.isMe,
    this.user,
  });
}

class LeaderboardScreen extends StatefulWidget {
  final int userXp;

  const LeaderboardScreen({super.key, required this.userXp});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  _Period _period = _Period.monthly;
  _Mode _mode = _Mode.individual;

  List<_Row> get _rows {
    if (_mode == _Mode.individual) {
      final users = _period == _Period.monthly
          ? ProviaMockData.rankedLeaderboard(widget.userXp)
          : yearlyIndividual(widget.userXp);
      return [
        for (final u in users)
          _Row(
            rank: u.rank,
            name: u.name,
            school: u.university,
            project: '${u.completedProjects}',
            level: '${u.level}',
            xp: u.xp,
            isMe: ProviaMockData.isCurrentUser(u),
            user: u,
          ),
      ];
    }
    final teams = teamRanking(
      yearly: _period == _Period.yearly,
      userXp: widget.userXp,
    );
    return [
      for (final t in teams)
        _Row(
          rank: t.rank,
          name: t.isMine ? '${t.name} (Takımın)' : t.name,
          school: t.project,
          project: '${t.completedProjects}',
          level: '${t.members.length}',
          xp: t.xp,
          isMe: t.isMine,
        ),
    ];
  }

  void _openProfile(_Row row) {
    final user = row.user;
    if (user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentProfileScreen(user: user, isMe: row.isMe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final me = rows.where((r) => r.isMe).firstOrNull;
    final above = me != null && me.rank > 1 ? rows[me.rank - 2] : null;
    final individual = _mode == _Mode.individual;

    final toggles = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ProviaSegmented<_Period>(
          value: _period,
          onChanged: (v) => setState(() => _period = v),
          segments: const [
            ProviaSegment(_Period.monthly, 'Aylık'),
            ProviaSegment(_Period.yearly, 'Yıllık'),
          ],
        ),
        ProviaSegmented<_Mode>(
          value: _mode,
          onChanged: (v) => setState(() => _mode = v),
          segments: const [
            ProviaSegment(_Mode.individual, 'Bireysel'),
            ProviaSegment(_Mode.team, 'Takım'),
          ],
        ),
      ],
    );

    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _period == _Period.monthly ? 'Kasım 2026' : '2026 Yılı',
          style: ProviaTheme.heading(size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          me == null
              ? 'Görev ve teslimlerden kazanılan XP'
              : above == null
              ? '${individual ? 'Senin sıran' : 'Takımının sırası'}: '
                    '#${me.rank}  ·  zirvedesin'
              : '${individual ? 'Senin sıran' : 'Takımının sırası'}: '
                    '#${me.rank}  ·  ${above.name.replaceAll(' (Sen)', '')} '
                    'ile fark ${above.xp - me.xp + 1} XP',
          style: const TextStyle(color: ProviaTheme.textMuted, fontSize: 13),
        ),
      ],
    );

    return ProviaPageView(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 16),
                  toggles,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [summary, const SizedBox(height: 12), toggles],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            return ProviaPanel(
              children: [
                _HeaderRow(wide: wide, individual: individual),
                for (final r in rows)
                  _DataRow(
                    row: r,
                    wide: wide,
                    individual: individual,
                    onTap: individual ? () => _openProfile(r) : null,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

const _rankWidth = 48.0;
const _xpWidth = 76.0;

class _HeaderRow extends StatelessWidget {
  final bool wide;
  final bool individual;

  const _HeaderRow({required this.wide, required this.individual});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: ProviaTheme.textSubtle,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    return Container(
      color: ProviaTheme.bgDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          const SizedBox(
            width: _rankWidth,
            child: Text('Sıra', style: style),
          ),
          Expanded(
            flex: 3,
            child: Text(individual ? 'Geliştirici' : 'Takım', style: style),
          ),
          if (wide) ...[
            Expanded(
              flex: 3,
              child: Text(individual ? 'Üniversite' : 'Proje', style: style),
            ),
            const SizedBox(
              width: 64,
              child: Text('Proje', textAlign: TextAlign.right, style: style),
            ),
            SizedBox(
              width: 64,
              child: Text(
                individual ? 'Seviye' : 'Üye',
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
          ],
          const SizedBox(
            width: _xpWidth,
            child: Text('XP', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final _Row row;
  final bool wide;
  final bool individual;
  final VoidCallback? onTap;

  const _DataRow({
    required this.row,
    required this.wide,
    required this.individual,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: row.isMe ? ProviaTheme.surfaceElevated : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: row.isMe ? ProviaTheme.textPrimary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 11, 16, 11),
          child: Row(
            children: [
              SizedBox(
                width: _rankWidth,
                child: Text(
                  '${row.rank}',
                  style: ProviaTheme.mono(
                    size: 12,
                    color: row.isMe
                        ? ProviaTheme.textPrimary
                        : ProviaTheme.textSubtle,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    if (individual) ...[
                      ProviaAvatar(name: row.name, size: 22),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: row.isMe
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (!wide)
                            Text(
                              row.school,
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
                  ],
                ),
              ),
              if (wide) ...[
                Expanded(
                  flex: 3,
                  child: Text(
                    row.school,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    row.project,
                    textAlign: TextAlign.right,
                    style: ProviaTheme.mono(
                      size: 12,
                      color: ProviaTheme.textMuted,
                    ),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    row.level,
                    textAlign: TextAlign.right,
                    style: ProviaTheme.mono(
                      size: 12,
                      color: ProviaTheme.textMuted,
                    ),
                  ),
                ),
              ],
              SizedBox(
                width: _xpWidth,
                child: Text(
                  '${row.xp}',
                  textAlign: TextAlign.right,
                  style: ProviaTheme.mono(size: 12, color: ProviaTheme.xp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
