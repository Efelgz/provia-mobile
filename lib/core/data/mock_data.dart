import '../../models/provia_models.dart';

class ProviaMockData {
  static const List<ProviaProject> projects = [
    ProviaProject(
      id: 'p1',
      title: 'KOBİ Aylık Satış Analiz Paneli',
      company: 'TrendTech Yazılım',
      isCompanySponsored: true,
      difficulty: 'Orta',
      description:
          'Küçük işletmelerin aylık gelir, gider ve stok devir hızlarını tek ekranda takip edebileceği responsive analiz paneli.',
      technologies: ['Flutter', 'REST API', 'PostgreSQL'],
      openRoles: ['Frontend', 'Backend', 'UI/UX'],
      deadline: '12 Gün Kaldı',
      xpReward: 450,
    ),
    ProviaProject(
      id: 'p2',
      title: 'Akıllı Bildirim Filtreleme Uygulaması',
      company: 'PROVIA Topluluk',
      isCompanySponsored: false,
      difficulty: 'Başlangıç',
      description:
          'Odaklanma modundayken acil ve önemsiz bildirimleri anahtar kelime skorlamasıyla ayıran mobil uygulama.',
      technologies: ['Flutter', 'Dart', 'Local Storage'],
      openRoles: ['Mobile', 'UI/UX'],
      deadline: '18 Gün Kaldı',
      xpReward: 300,
    ),
    ProviaProject(
      id: 'p3',
      title: 'Kampüs Etkinlik & Kulüp Yönetim Sistemi',
      company: 'FinPay Teknoloji',
      isCompanySponsored: true,
      difficulty: 'İleri',
      description:
          'Üniversite kulüplerinin kontenjanlı etkinlik açabileceği, QR kod ile yoklama alabileceği tam yığın platform.',
      technologies: ['Spring Boot', 'Flutter', 'PostgreSQL'],
      openRoles: ['Backend', 'Mobile', 'Database'],
      deadline: '25 Gün Kaldı',
      xpReward: 600,
    ),
    ProviaProject(
      id: 'p4',
      title: 'Klinik Randevu & Hatırlatma Platformu',
      company: 'PROVIA Topluluk',
      isCompanySponsored: false,
      difficulty: 'Başlangıç',
      description:
          'Küçük klinikler için doktor takvimi yönetimi, randevu oluşturma ve çakışma önleme modülü.',
      technologies: ['Flutter', 'Firebase', 'Figma'],
      openRoles: ['Mobile', 'Project Manager'],
      deadline: '10 Gün Kaldı',
      xpReward: 320,
    ),
  ];

  /// Uygulamayı kullanan (demo) öğrencinin adı.
  static const String currentUserName = 'Deniz Aydın';

  static ProviaProject projectById(String id) =>
      projects.firstWhere((p) => p.id == id);

  /// Her projenin demo GitHub deposu (Alanım > GitHub Teslimi alanı).
  static const Map<String, String> demoRepoUrls = {
    'p1': 'https://github.com/provia-demo/kobi-satis-paneli',
    'p2': 'https://github.com/provia-demo/akilli-bildirim-filtresi',
    'p3': 'https://github.com/provia-demo/kampus-etkinlik-sistemi',
    'p4': 'https://github.com/provia-demo/klinik-randevu-platformu',
  };

  /// Proje bazlı takım görevleri. Görev durumları oturum boyunca
  /// burada tutulur (kalıcı kayıt Faz 2'de shared_preferences ile gelecek).
  static final Map<String, List<ProviaTask>> projectTasks = {
    'p1': [
      ProviaTask(
        id: 'p1-t1',
        title: 'Veritabanı ER diyagramı ve tablo tasarımı',
        assignee: 'Sen',
        role: 'Backend',
        status: 'Tamamlandı',
        xp: 80,
      ),
      ProviaTask(
        id: 'p1-t2',
        title: 'Aylık satış grafiği ve filtreleme bileşeni',
        assignee: 'Sen',
        role: 'Mobile',
        status: 'Devam Ediyor',
        xp: 120,
      ),
      ProviaTask(
        id: 'p1-t3',
        title: 'Giriş ekranı ve karanlık tema arayüzü',
        assignee: 'Zeynep A.',
        role: 'UI/UX',
        status: 'Tamamlandı',
        xp: 90,
      ),
      ProviaTask(
        id: 'p1-t4',
        title: 'JWT kimlik doğrulama ve yetki kontrolü',
        assignee: 'Mert K.',
        role: 'Backend',
        status: 'Yapılacak',
        xp: 110,
      ),
    ],
    'p2': [
      ProviaTask(
        id: 'p2-t1',
        title: 'Bildirim izinleri ve odak modu ayar ekranı',
        assignee: 'Sen',
        role: 'Mobile',
        status: 'Yapılacak',
        xp: 70,
      ),
      ProviaTask(
        id: 'p2-t2',
        title: 'Anahtar kelime skorlama algoritması',
        assignee: 'Burak K.',
        role: 'Mobile',
        status: 'Devam Ediyor',
        xp: 100,
      ),
      ProviaTask(
        id: 'p2-t3',
        title: 'Acil / önemsiz bildirim kart tasarımları',
        assignee: 'Ece T.',
        role: 'UI/UX',
        status: 'Yapılacak',
        xp: 60,
      ),
    ],
    'p3': [
      ProviaTask(
        id: 'p3-t1',
        title: 'Etkinlik ve kontenjan REST API uç noktaları',
        assignee: 'Sen',
        role: 'Backend',
        status: 'Yapılacak',
        xp: 130,
      ),
      ProviaTask(
        id: 'p3-t2',
        title: 'QR kod ile yoklama akışı',
        assignee: 'Kaan Y.',
        role: 'Mobile',
        status: 'Devam Ediyor',
        xp: 120,
      ),
      ProviaTask(
        id: 'p3-t3',
        title: 'Kulüp, etkinlik ve katılımcı tablo şeması',
        assignee: 'Selin D.',
        role: 'Database',
        status: 'Tamamlandı',
        xp: 90,
      ),
    ],
    'p4': [
      ProviaTask(
        id: 'p4-t1',
        title: 'Doktor takvimi ve randevu oluşturma ekranı',
        assignee: 'Sen',
        role: 'Mobile',
        status: 'Yapılacak',
        xp: 90,
      ),
      ProviaTask(
        id: 'p4-t2',
        title: 'Randevu çakışma kontrolü',
        assignee: 'Mert K.',
        role: 'Mobile',
        status: 'Yapılacak',
        xp: 80,
      ),
      ProviaTask(
        id: 'p4-t3',
        title: 'Sprint planı ve görev dağılımı',
        assignee: 'Ece T.',
        role: 'Project Manager',
        status: 'Devam Ediyor',
        xp: 50,
      ),
    ],
  };

  static List<ProviaTask> tasksFor(String projectId) =>
      projectTasks[projectId] ?? const [];

  static const List<LeaderboardUser> monthlyLeaderboard = [
    LeaderboardUser(
      rank: 1,
      name: 'Selin Demir',
      university: 'İTÜ • Bilgisayar Müh.',
      xp: 2840,
      level: 7,
      completedProjects: 6,
    ),
    LeaderboardUser(
      rank: 2,
      name: 'Kaan Yılmaz',
      university: 'ODTÜ • Yazılım Müh.',
      xp: 2510,
      level: 6,
      completedProjects: 5,
    ),
    LeaderboardUser(
      rank: 3,
      name: 'Zeynep Arslan',
      university: 'Yıldız Teknik • YBS',
      xp: 2190,
      level: 5,
      completedProjects: 4,
    ),
    LeaderboardUser(
      rank: 4,
      name: 'Deniz Aydın (Sen)',
      university: 'Marmara Üni. • Yazılım Müh.',
      xp: 1450,
      level: 4,
      completedProjects: 3,
    ),
    LeaderboardUser(
      rank: 5,
      name: 'Burak Kaya',
      university: 'Ege Üni. • Bilgisayar Müh.',
      xp: 1320,
      level: 3,
      completedProjects: 2,
    ),
  ];

  static bool isCurrentUser(LeaderboardUser user) =>
      user.name.contains('(Sen)');

  /// "Sen" kaydının XP'sini canlı değerle değiştirip listeyi yeniden sıralar.
  /// Sıralama ve Panel ekranları aynı sonucu göstersin diye burada.
  static List<LeaderboardUser> rankedLeaderboard(int userXp) {
    final users = monthlyLeaderboard.map((u) {
      if (!isCurrentUser(u)) return u;
      return LeaderboardUser(
        rank: u.rank,
        name: u.name,
        university: u.university,
        xp: userXp,
        level: (userXp ~/ 400) + 1,
        completedProjects: u.completedProjects,
      );
    }).toList()..sort((a, b) => b.xp.compareTo(a.xp));

    return [
      for (var i = 0; i < users.length; i++)
        LeaderboardUser(
          rank: i + 1,
          name: users[i].name,
          university: users[i].university,
          xp: users[i].xp,
          level: users[i].level,
          completedProjects: users[i].completedProjects,
        ),
    ];
  }
}
