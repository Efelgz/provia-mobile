// SAHİBİ: Kişi 2 — Sıralama ekranının yıllık ve takım örnek verileri.
// Aylık bireysel sıralama core/data/mock_data.dart'tan gelir.
import '../../core/data/mock_data.dart';
import '../../models/provia_models.dart';

class TeamEntry {
  final int rank;
  final String name;
  final List<String> members;
  final String project;
  final int xp;
  final int completedProjects;
  final bool isMine;

  const TeamEntry({
    required this.rank,
    required this.name,
    required this.members,
    required this.project,
    required this.xp,
    required this.completedProjects,
    this.isMine = false,
  });
}

/// Diğer öğrencilerin 2026 yılı toplam XP'leri.
const List<LeaderboardUser> _yearlyOthers = [
  LeaderboardUser(
    rank: 0,
    name: 'Selin Demir',
    university: 'İTÜ • Bilgisayar Müh.',
    xp: 9420,
    level: 7,
    completedProjects: 14,
  ),
  LeaderboardUser(
    rank: 0,
    name: 'Kaan Yılmaz',
    university: 'ODTÜ • Yazılım Müh.',
    xp: 8760,
    level: 6,
    completedProjects: 12,
  ),
  LeaderboardUser(
    rank: 0,
    name: 'Ece Tunç',
    university: 'Ege Üni. • YBS',
    xp: 7310,
    level: 6,
    completedProjects: 10,
  ),
  LeaderboardUser(
    rank: 0,
    name: 'Zeynep Arslan',
    university: 'Yıldız Teknik • YBS',
    xp: 6980,
    level: 5,
    completedProjects: 9,
  ),
  LeaderboardUser(
    rank: 0,
    name: 'Burak Kaya',
    university: 'Ege Üni. • Bilgisayar Müh.',
    xp: 4150,
    level: 3,
    completedProjects: 5,
  ),
];

List<LeaderboardUser> _ranked(List<LeaderboardUser> users) {
  final sorted = [...users]..sort((a, b) => b.xp.compareTo(a.xp));
  return [
    for (var i = 0; i < sorted.length; i++)
      LeaderboardUser(
        rank: i + 1,
        name: sorted[i].name,
        university: sorted[i].university,
        xp: sorted[i].xp,
        level: sorted[i].level,
        completedProjects: sorted[i].completedProjects,
      ),
  ];
}

/// Yıllık bireysel sıralama. Kullanıcının yıllık XP'si: bu ayki XP +
/// önceki aylarda tamamladığı projelerden gelen XP (demo varsayımı).
List<LeaderboardUser> yearlyIndividual(int userXp) {
  final pastXp = ProviaMockData.currentUserCompletedProjects * 1050;
  final yearlyXp = userXp + pastXp;
  return _ranked([
    ..._yearlyOthers,
    LeaderboardUser(
      rank: 0,
      name: '${ProviaMockData.currentUserName} (Sen)',
      university: ProviaMockData.currentUserUniversity,
      xp: yearlyXp,
      level: (userXp ~/ 400) + 1,
      completedProjects: ProviaMockData.currentUserCompletedProjects,
    ),
  ]);
}

/// Takım sıralaması. Kullanıcının takımının XP'si canlı XP ile artar.
List<TeamEntry> teamRanking({required bool yearly, required int userXp}) {
  final me = ProviaMockData.currentUserName;
  final scale = yearly ? 3 : 1;
  final teams = [
    (
      'Veri Kaşifleri',
      ['Selin Demir', 'Kaan Yılmaz', 'Ece Tunç'],
      'Kampüs Etkinlik & Kulüp Yönetim Sistemi',
      6120 * scale,
      yearly ? 9 : 3,
      false,
    ),
    (
      'Sinyal Takımı',
      [me, 'Zeynep Arslan', 'Mert Kılıç'],
      'KOBİ Aylık Satış Analiz Paneli',
      2930 * scale + userXp,
      yearly ? 7 : 2,
      true,
    ),
    (
      'Pixel Sprint',
      ['Burak Kaya', 'Ada Şen', 'Can Erdem'],
      'Akıllı Bildirim Filtreleme Uygulaması',
      3950 * scale,
      yearly ? 6 : 2,
      false,
    ),
    (
      'Null Pointers',
      ['Arda Kara', 'Ali Vural', 'İpek Sarı', 'Oğuz Tan'],
      'Klinik Randevu & Hatırlatma Platformu',
      3320 * scale,
      yearly ? 5 : 2,
      false,
    ),
    (
      'Async Avcıları',
      ['Melis Ak', 'Emre Uçar'],
      'Kampüs Etkinlik & Kulüp Yönetim Sistemi',
      2780 * scale,
      yearly ? 4 : 1,
      false,
    ),
  ]..sort((a, b) => b.$4.compareTo(a.$4));

  return [
    for (var i = 0; i < teams.length; i++)
      TeamEntry(
        rank: i + 1,
        name: teams[i].$1,
        members: teams[i].$2,
        project: teams[i].$3,
        xp: teams[i].$4,
        completedProjects: teams[i].$5,
        isMine: teams[i].$6,
      ),
  ];
}
