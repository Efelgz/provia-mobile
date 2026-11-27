// SAHİBİ: Kişi 2 — Takımlar modülü (takım kur, açık takımlara başvur,
// takım arkadaşı bul). Durum main.dart'ta tutulur ve kaydedilir.
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/provia_session.dart';
import '../../core/widgets/provia_components.dart';
import '../../models/provia_models.dart';

// --- Örnek veriler ----------------------------------------------------------

class _OpenTeam {
  final String id;
  final String name;
  final String projectId;
  final List<String> members;
  final int capacity;
  final List<String> openRoles;

  const _OpenTeam(
    this.id,
    this.name,
    this.projectId,
    this.members,
    this.capacity,
    this.openRoles,
  );
}

const _openTeams = [
  _OpenTeam(
    't1',
    'Veri Kaşifleri',
    'p3',
    ['Selin Demir', 'Kaan Yılmaz'],
    4,
    ['Mobile', 'Database'],
  ),
  _OpenTeam(
    't2',
    'Pixel Sprint',
    'p2',
    ['Burak Kaya', 'Ada Şen'],
    4,
    ['UI/UX'],
  ),
  _OpenTeam(
    't3',
    'Null Pointers',
    'p4',
    ['Arda Kara', 'Ali Vural', 'İpek Sarı'],
    5,
    ['Mobile', 'Project Manager'],
  ),
  _OpenTeam(
    't4',
    'Async Avcıları',
    'p5',
    ['Melis Ak'],
    4,
    ['Backend', 'Mobile'],
  ),
  _OpenTeam(
    't5',
    'Stack Overflowers',
    'p6',
    ['Emre Uçar', 'Can Erdem'],
    5,
    ['Frontend', 'Data'],
  ),
];

class _Teammate {
  final String name;
  final String school;
  final String role;
  final List<String> skills;

  const _Teammate(this.name, this.school, this.role, this.skills);
}

const _teammates = [
  _Teammate('Ece Tunç', 'Ege Üni. • YBS', 'UI/UX', ['Figma', 'Flutter']),
  _Teammate('Mert Kılıç', 'Hacettepe • Bilgisayar Müh.', 'Backend', [
    'Node.js',
    'PostgreSQL',
  ]),
  _Teammate('Can Erdem', 'Dokuz Eylül • Yazılım Müh.', 'Mobile', [
    'Flutter',
    'Firebase',
  ]),
  _Teammate('Ada Şen', 'Bilkent • Bilgisayar Müh.', 'Data', ['Python', 'SQL']),
  _Teammate('Zeynep Arslan', 'Yıldız Teknik • YBS', 'UI/UX', [
    'Figma',
    'Kullanıcı Araştırması',
  ]),
  _Teammate('İpek Sarı', 'Gazi Üni. • Yazılım Müh.', 'Frontend', [
    'React',
    'TypeScript',
  ]),
];

const teamRoles = [
  'Frontend',
  'Backend',
  'Mobile',
  'UI/UX',
  'Data',
  'Project Manager',
];

// ---------------------------------------------------------------------------

enum _Tab { open, mine, people }

class TeamsScreen extends StatefulWidget {
  final List<ProviaProject> joinedProjects;
  final Set<String> appliedTeamIds;
  final List<CreatedTeam> createdTeams;
  final ValueChanged<String> onApply;
  final ValueChanged<String> onWithdraw;
  final ValueChanged<CreatedTeam> onCreateTeam;

  const TeamsScreen({
    super.key,
    required this.joinedProjects,
    required this.appliedTeamIds,
    required this.createdTeams,
    required this.onApply,
    required this.onWithdraw,
    required this.onCreateTeam,
  });

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  _Tab _tab = _Tab.open;
  String _roleFilter = 'Tümü';

  // Mobilde ayrı sayfa olarak açıldığında da güncel kalsın diye yerel kopya.
  late Set<String> _applied = {...widget.appliedTeamIds};
  late List<CreatedTeam> _created = [...widget.createdTeams];

  @override
  void didUpdateWidget(covariant TeamsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applied = {...widget.appliedTeamIds};
    _created = [...widget.createdTeams];
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _withdraw(_OpenTeam team) {
    if (!_applied.contains(team.id)) return;
    setState(() => _applied.remove(team.id));
    widget.onWithdraw(team.id);
    _message('"${team.name}" takımına başvurun geri çekildi.');
  }

  void _toggleInvite(_Teammate p) {
    final invited = ProviaSession.toggleInvite(p.name);
    _message(
      invited
          ? '${p.name} adlı öğrenciye takım daveti gönderildi (demo).'
          : '${p.name} için davet iptal edildi.',
    );
  }

  void _apply(_OpenTeam team) {
    if (_applied.contains(team.id)) return;
    setState(() => _applied.add(team.id));
    widget.onApply(team.id);
    _message('"${team.name}" takımına başvurun gönderildi.');
  }

  Future<void> _createTeam() async {
    final team = await showDialog<CreatedTeam>(
      context: context,
      builder: (_) => _CreateTeamDialog(joinedProjects: widget.joinedProjects),
    );
    if (team == null || !mounted) return;
    setState(() {
      _created.add(team);
      _tab = _Tab.mine;
    });
    widget.onCreateTeam(team);
    _message('"${team.name}" takımı oluşturuldu.');
  }

  @override
  Widget build(BuildContext context) {
    final myCount =
        _created.length +
        _openTeams.where((t) => _applied.contains(t.id)).length;

    return ProviaPageView(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Takımlar', style: ProviaTheme.heading(size: 20)),
                  const SizedBox(height: 4),
                  const Text(
                    'Projen için takım kur, açık takımlara başvur veya takım '
                    'arkadaşı bul.',
                    style: TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _createTeam,
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Takım Oluştur'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        UnderlineTabs<_Tab>(
          value: _tab,
          onChanged: (v) => setState(() => _tab = v),
          tabs: [
            ProviaSegment(_Tab.open, 'Açık Takımlar', count: _openTeams.length),
            ProviaSegment(_Tab.mine, 'Takımlarım', count: myCount),
            ProviaSegment(
              _Tab.people,
              'Takım Arkadaşı Bul',
              count: _teammates.length,
            ),
          ],
        ),
        const SizedBox(height: 16),
        switch (_tab) {
          _Tab.open => ProviaPanel(
            children: [
              for (final t in _openTeams)
                _OpenTeamRow(
                  team: t,
                  applied: _applied.contains(t.id),
                  onApply: () => _apply(t),
                  onWithdraw: () => _withdraw(t),
                ),
            ],
          ),
          _Tab.mine => _MyTeams(
            created: _created,
            applied: _openTeams.where((t) => _applied.contains(t.id)).toList(),
            onCreate: _createTeam,
            onWithdraw: _withdraw,
          ),
          _Tab.people => _People(
            roleFilter: _roleFilter,
            onFilter: (v) => setState(() => _roleFilter = v),
            onToggleInvite: _toggleInvite,
          ),
        },
      ],
    );
  }
}

/// Satır: solda bilgi, sağda aksiyon; dar ekranda aksiyon alta iner.
class _Row extends StatelessWidget {
  final Widget leading;
  final Widget info;
  final Widget action;

  const _Row({required this.leading, required this.info, required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final body = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(child: info),
            ],
          );
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [body, const SizedBox(height: 10), action],
            );
          }
          return Row(
            children: [
              Expanded(child: body),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _OpenTeamRow extends StatelessWidget {
  final _OpenTeam team;
  final bool applied;
  final VoidCallback onApply;
  final VoidCallback onWithdraw;

  const _OpenTeamRow({
    required this.team,
    required this.applied,
    required this.onApply,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final project = ProviaMockData.projectById(team.projectId);
    return _Row(
      leading: AvatarStack(names: team.members, size: 26),
      info: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            metaLine([
              project.title,
              '${team.members.length}/${team.capacity} üye',
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Aranan: ${metaLine(team.openRoles)}',
            style: ProviaTheme.mono(size: 11, color: ProviaTheme.textMuted),
          ),
        ],
      ),
      // Başvuruldu'ya tekrar dokununca başvuru geri çekilir.
      action: ToggleActionButton(
        active: applied,
        label: 'Başvur',
        activeLabel: 'Başvuruldu',
        undoneLabel: 'Başvuru geri çekildi',
        onActivate: onApply,
        onUndo: onWithdraw,
      ),
    );
  }
}

class _MyTeams extends StatelessWidget {
  final List<CreatedTeam> created;
  final List<_OpenTeam> applied;
  final VoidCallback onCreate;
  final ValueChanged<_OpenTeam> onWithdraw;

  const _MyTeams({
    required this.created,
    required this.applied,
    required this.onCreate,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    if (created.isEmpty && applied.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Text(
              'Henüz bir takımın yok.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kendi takımını kur veya açık takımlara başvur.',
              style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 13),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onCreate,
              child: const Text('Takım Oluştur'),
            ),
          ],
        ),
      );
    }
    return ProviaPanel(
      children: [
        for (final t in created)
          _Row(
            leading: AvatarStack(
              names: [ProviaMockData.currentUserName],
              size: 26,
            ),
            info: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metaLine([
                    ProviaMockData.projectById(t.projectId).title,
                    'Kurucu: sen',
                  ]),
                  style: const TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 12,
                  ),
                ),
                if (t.openRoles.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Aranan: ${metaLine(t.openRoles)}',
                    style: ProviaTheme.mono(
                      size: 11,
                      color: ProviaTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            action: const Text(
              'Yeni üye bekleniyor',
              style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
            ),
          ),
        for (final t in applied)
          _Row(
            leading: AvatarStack(names: t.members, size: 26),
            info: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ProviaMockData.projectById(t.projectId).title,
                  style: const TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            action: Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusDot(ProviaTheme.warning),
                    SizedBox(width: 8),
                    Text(
                      'Başvuru değerlendiriliyor',
                      style: TextStyle(
                        color: ProviaTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => onWithdraw(t),
                  child: const Text('Geri çek'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _People extends StatelessWidget {
  final String roleFilter;
  final ValueChanged<String> onFilter;
  final ValueChanged<_Teammate> onToggleInvite;

  const _People({
    required this.roleFilter,
    required this.onFilter,
    required this.onToggleInvite,
  });

  @override
  Widget build(BuildContext context) {
    final people = _teammates
        .where((p) => roleFilter == 'Tümü' || p.role == roleFilter)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 220,
            child: ProviaSelect<String>(
              label: 'Rol',
              value: roleFilter,
              options: [('Tümü', 'Tümü'), for (final r in teamRoles) (r, r)],
              onChanged: onFilter,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (people.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Bu rolde müsait öğrenci yok.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 13),
            ),
          )
        else
          ProviaPanel(
            children: [
              for (final p in people)
                _Row(
                  leading: ProviaAvatar(name: p.name, size: 28),
                  info: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        metaLine([p.role, p.school]),
                        style: const TextStyle(
                          color: ProviaTheme.textSubtle,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [for (final s in p.skills) TechChip(s)],
                      ),
                    ],
                  ),
                  // Davet durumu Profil ekranıyla ortak.
                  action: ValueListenableBuilder<Set<String>>(
                    valueListenable: ProviaSession.invitedStudents,
                    builder: (context, _, _) => ToggleActionButton(
                      active: ProviaSession.isInvited(p.name),
                      label: 'Davet Et',
                      activeLabel: 'Davet gönderildi',
                      undoneLabel: 'Davet iptal edildi',
                      onActivate: () => onToggleInvite(p),
                      onUndo: () => onToggleInvite(p),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _CreateTeamDialog extends StatefulWidget {
  final List<ProviaProject> joinedProjects;

  const _CreateTeamDialog({required this.joinedProjects});

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final _nameController = TextEditingController();
  late String _projectId = widget.joinedProjects.isNotEmpty
      ? widget.joinedProjects.first.id
      : ProviaMockData.projects.first.id;
  final Set<String> _roles = {};
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Takım adı en az 3 karakter olmalı.');
      return;
    }
    Navigator.of(context).pop(
      CreatedTeam(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        projectId: _projectId,
        openRoles: _roles.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Takım Oluştur', style: ProviaTheme.heading(size: 18)),
              const SizedBox(height: 4),
              const Text(
                'Takımın bir projeye bağlıdır; aradığın rolleri seç.',
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _nameController,
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Takım adı',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _projectId,
                isExpanded: true,
                dropdownColor: ProviaTheme.surfaceElevated,
                decoration: const InputDecoration(labelText: 'Proje'),
                items: [
                  for (final p in ProviaMockData.projects)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        p.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _projectId = v ?? _projectId),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aranan roller',
                style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final r in teamRoles)
                    FilterPill(
                      label: r,
                      selected: _roles.contains(r),
                      onTap: () => setState(
                        () => _roles.contains(r)
                            ? _roles.remove(r)
                            : _roles.add(r),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Vazgeç'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Oluştur'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
