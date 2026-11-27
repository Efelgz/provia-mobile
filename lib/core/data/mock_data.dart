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

  static List<ProviaTask> workspaceTasks = [
    ProviaTask(
      id: 't1',
      title: 'Veritabanı ER diyagramı ve tablo tasarımı',
      assignee: 'Sen',
      role: 'Backend',
      status: 'Tamamlandı',
      xp: 80,
    ),
    ProviaTask(
      id: 't2',
      title: 'Aylık satış grafiği ve filtreleme bileşeni',
      assignee: 'Sen',
      role: 'Mobile',
      status: 'Devam Ediyor',
      xp: 120,
    ),
    ProviaTask(
      id: 't3',
      title: 'Giriş ekranı ve karanlık tema arayüzü',
      assignee: 'Zeynep A.',
      role: 'UI/UX',
      status: 'Tamamlandı',
      xp: 90,
    ),
    ProviaTask(
      id: 't4',
      title: 'JWT kimlik doğrulama ve yetki kontrolü',
      assignee: 'Mert K.',
      role: 'Backend',
      status: 'Yapılacak',
      xp: 110,
    ),
  ];

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
      name: 'Efe Köksal (Sen)',
      university: 'İAÜ • Yazılım Geliştirme',
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
}
