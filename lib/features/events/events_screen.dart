// SAHİBİ: Kişi 2 — Etkinlikler modülü (atölye, hackathon, kariyer günü;
// kontenjan takibi ve kayıt). Kayıt durumu main.dart'ta tutulur ve
// kaydedilir; XP her etkinlik için yalnızca ilk kayıtta verilir.
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/provia_components.dart';

class ProviaEvent {
  final String id;
  final String title;
  final String type; // Atölye, Hackathon, Kariyer
  final String organizer;
  final String day;
  final String month;
  final String dateLabel;
  final String time;
  final String location;
  final int capacity;
  final int registeredBase;
  final int xpReward;

  const ProviaEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.organizer,
    required this.day,
    required this.month,
    required this.dateLabel,
    required this.time,
    required this.location,
    required this.capacity,
    required this.registeredBase,
    required this.xpReward,
  });
}

const proviaEvents = [
  ProviaEvent(
    id: 'e1',
    title: 'Temiz Mimari & PR İnceleme Atölyesi',
    type: 'Atölye',
    organizer: 'TrendTech Yazılım',
    day: '03',
    month: 'ARA',
    dateLabel: '3 Aralık 2026',
    time: '19:00',
    location: 'Online',
    capacity: 60,
    registeredBase: 41,
    xpReward: 15,
  ),
  ProviaEvent(
    id: 'e2',
    title: 'Flutter ile Hızlı Prototipleme',
    type: 'Atölye',
    organizer: 'PROVIA Topluluk',
    day: '06',
    month: 'ARA',
    dateLabel: '6 Aralık 2026',
    time: '14:00',
    location: 'İTÜ Ayazağa',
    capacity: 40,
    registeredBase: 40,
    xpReward: 15,
  ),
  ProviaEvent(
    id: 'e3',
    title: 'Git & GitHub Akışları 101',
    type: 'Atölye',
    organizer: 'PROVIA Topluluk',
    day: '10',
    month: 'ARA',
    dateLabel: '10 Aralık 2026',
    time: '20:00',
    location: 'Online',
    capacity: 80,
    registeredBase: 23,
    xpReward: 15,
  ),
  ProviaEvent(
    id: 'e4',
    title: 'FinPay Kampüs Hackathonu',
    type: 'Hackathon',
    organizer: 'FinPay Teknoloji',
    day: '13',
    month: 'ARA',
    dateLabel: '13–14 Aralık 2026',
    time: '10:00',
    location: 'Kampüs + Online',
    capacity: 120,
    registeredBase: 87,
    xpReward: 40,
  ),
  ProviaEvent(
    id: 'e5',
    title: 'Yazılım Stajı Kariyer Günü',
    type: 'Kariyer',
    organizer: 'PROVIA & Partner Şirketler',
    day: '18',
    month: 'ARA',
    dateLabel: '18 Aralık 2026',
    time: '13:00',
    location: 'Online',
    capacity: 200,
    registeredBase: 152,
    xpReward: 10,
  ),
  ProviaEvent(
    id: 'e6',
    title: 'Sağlık Teknolojileri Mini Hackathon',
    type: 'Hackathon',
    organizer: 'MedCore Sağlık Teknolojileri',
    day: '09',
    month: 'OCA',
    dateLabel: '9–10 Ocak 2027',
    time: '09:30',
    location: 'Ankara',
    capacity: 60,
    registeredBase: 58,
    xpReward: 40,
  ),
];

/// Kayıt değişikliği: etkinlik kimliği + verilecek XP.
typedef EventToggle = void Function(String eventId, int xpReward);

class EventsScreen extends StatefulWidget {
  final Set<String> registeredEventIds;
  final EventToggle onToggleRegistration;

  const EventsScreen({
    super.key,
    required this.registeredEventIds,
    required this.onToggleRegistration,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const _tabs = ['Tümü', 'Atölye', 'Hackathon', 'Kariyer', 'Kayıtlı'];
  String _tab = 'Tümü';

  // Mobilde ayrı sayfa olarak açıldığında da güncel kalsın diye yerel kopya.
  late Set<String> _registered = {...widget.registeredEventIds};

  @override
  void didUpdateWidget(covariant EventsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registered = {...widget.registeredEventIds};
  }

  bool _matches(ProviaEvent e, String tab) => switch (tab) {
    'Tümü' => true,
    'Kayıtlı' => _registered.contains(e.id),
    _ => e.type == tab,
  };

  void _toggle(ProviaEvent e) {
    final wasRegistered = _registered.contains(e.id);
    setState(() {
      wasRegistered ? _registered.remove(e.id) : _registered.add(e.id);
    });
    widget.onToggleRegistration(e.id, e.xpReward);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasRegistered
                ? '"${e.title}" kaydın iptal edildi.'
                : '"${e.title}" etkinliğine kayıt oldun.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final events = proviaEvents.where((e) => _matches(e, _tab)).toList();

    return ProviaPageView(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Etkinlikler', style: ProviaTheme.heading(size: 20)),
                  const SizedBox(height: 4),
                  const Text(
                    'Atölye, hackathon ve kariyer günlerine katıl; kontenjan '
                    'dolmadan yerini ayırt.',
                    style: TextStyle(
                      color: ProviaTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_registered.length} kayıt',
              style: ProviaTheme.mono(size: 12, color: ProviaTheme.textSubtle),
            ),
          ],
        ),
        const SizedBox(height: 16),
        UnderlineTabs<String>(
          value: _tab,
          onChanged: (v) => setState(() => _tab = v),
          tabs: [
            for (final t in _tabs)
              ProviaSegment(
                t,
                t,
                count: proviaEvents.where((e) => _matches(e, t)).length,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Henüz kayıtlı olduğun bir etkinlik yok.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 13),
            ),
          )
        else
          ProviaPanel(
            children: [
              for (final e in events)
                _EventRow(
                  event: e,
                  registered: _registered.contains(e.id),
                  onToggle: () => _toggle(e),
                ),
            ],
          ),
        const SizedBox(height: 10),
        const Text(
          'Etkinlik kaydı ilk seferde XP kazandırır; iptal edip yeniden kayıt '
          'olmak tekrar XP vermez.',
          style: TextStyle(color: ProviaTheme.textSubtle, fontSize: 11),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final ProviaEvent event;
  final bool registered;
  final VoidCallback onToggle;

  const _EventRow({
    required this.event,
    required this.registered,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final count = event.registeredBase + (registered ? 1 : 0);
    final full = !registered && event.registeredBase >= event.capacity;
    final fill = count / event.capacity;
    final fillColor = fill >= 0.9 ? ProviaTheme.warning : ProviaTheme.textMuted;

    final dateBox = Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: Column(
        children: [
          Text(
            event.day,
            style: ProviaTheme.mono(size: 15, weight: FontWeight.w600),
          ),
          Text(
            event.month,
            style: ProviaTheme.mono(size: 10, color: ProviaTheme.textSubtle),
          ),
        ],
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          metaLine([event.type, event.organizer]),
          style: const TextStyle(color: ProviaTheme.textSubtle, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          metaLine([event.dateLabel, event.time, event.location]),
          style: ProviaTheme.mono(size: 11, color: ProviaTheme.textMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 120,
              child: ProviaProgressBar(
                value: fill,
                color: fillColor,
                height: 3,
              ),
            ),
            Text(
              '$count/${event.capacity}',
              style: ProviaTheme.mono(size: 11, color: ProviaTheme.textSubtle),
            ),
            Text(
              '+${event.xpReward} XP',
              style: ProviaTheme.mono(size: 11, color: ProviaTheme.xp),
            ),
          ],
        ),
      ],
    );

    final Widget action;
    if (registered) {
      action = OutlinedButton.icon(
        onPressed: onToggle,
        style: OutlinedButton.styleFrom(foregroundColor: ProviaTheme.accent),
        icon: const Icon(LucideIcons.check, size: 13),
        label: const Text('Kayıtlısın'),
      );
    } else if (full) {
      action = const OutlinedButton(onPressed: null, child: Text('Dolu'));
    } else {
      action = ElevatedButton(
        onPressed: onToggle,
        child: const Text('Kayıt Ol'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final body = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateBox,
              const SizedBox(width: 14),
              Expanded(child: info),
            ],
          );
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                body,
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: action,
                ),
              ],
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
