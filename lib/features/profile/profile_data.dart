// SAHİBİ: Kişi 2 — Öğrenci profillerinin örnek verileri.
// Sıralama ekranındaki her öğrencinin profil sayfası buradan beslenir.
import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileBadge {
  final IconData icon;
  final String title;
  final String description;
  final bool earned;

  const ProfileBadge(
    this.icon,
    this.title,
    this.description, {
    this.earned = true,
  });
}

class PortfolioItem {
  final String title;
  final String company;
  final String role;
  final int contributionScore;
  final List<String> technologies;

  const PortfolioItem({
    required this.title,
    required this.company,
    required this.role,
    required this.contributionScore,
    required this.technologies,
  });
}

class StudentProfile {
  final String name;
  final String classYear;
  final String focus;
  final String githubHandle;
  final List<ProfileBadge> badges;
  final List<String> skills;
  final List<PortfolioItem> portfolio;

  const StudentProfile({
    required this.name,
    required this.classYear,
    required this.focus,
    required this.githubHandle,
    required this.badges,
    required this.skills,
    required this.portfolio,
  });

  String get initials => name
      .split(' ')
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0])
      .join();
}

const _ilkTeslim = ProfileBadge(
  LucideIcons.rocket,
  'İlk Teslim',
  'İlk projeni teslim ettin',
);
const _takimOyuncusu = ProfileBadge(
  LucideIcons.users,
  'Takım Oyuncusu',
  '3 farklı ekipte çalıştın',
);
const _temizKod = ProfileBadge(
  LucideIcons.gitBranch,
  'Temiz Kod',
  'AI kod puanı 85+',
);
const _sirketProjesi = ProfileBadge(
  LucideIcons.building2,
  'Şirket Projesi',
  'Şirket destekli proje tamamladın',
);

/// Henüz kazanılmamış rozet: kilitli görünür, açıklama hedefi anlatır.
ProfileBadge _locked(ProfileBadge b, String goal) =>
    ProfileBadge(b.icon, b.title, goal, earned: false);

final Map<String, StudentProfile> _profiles = {
  'Deniz Aydın': StudentProfile(
    name: 'Deniz Aydın',
    classYear: '2. Sınıf',
    focus: 'Mobile & Frontend odaklı',
    githubHandle: 'deniz-aydin',
    badges: [
      _ilkTeslim,
      _takimOyuncusu,
      _temizKod,
      _locked(_sirketProjesi, 'Şirket destekli proje tamamla'),
    ],
    skills: const [
      'Flutter',
      'Dart',
      'REST API',
      'PostgreSQL',
      'Git & GitHub',
      'Figma',
    ],
    portfolio: const [
      PortfolioItem(
        title: 'KOBİ Aylık Satış Analiz Paneli',
        company: 'TrendTech Yazılım',
        role: 'Mobile Geliştirici',
        contributionScore: 88,
        technologies: ['Flutter', 'REST API'],
      ),
      PortfolioItem(
        title: 'Akıllı Bildirim Filtreleme Uygulaması',
        company: 'PROVIA Topluluk',
        role: 'UI/UX & Mobile',
        contributionScore: 82,
        technologies: ['Flutter', 'Local Storage'],
      ),
      PortfolioItem(
        title: 'Klinik Randevu & Hatırlatma Platformu',
        company: 'PROVIA Topluluk',
        role: 'Proje Yöneticisi',
        contributionScore: 79,
        technologies: ['Firebase', 'Figma'],
      ),
    ],
  ),
  'Selin Demir': const StudentProfile(
    name: 'Selin Demir',
    classYear: '2. Sınıf',
    focus: 'Backend & Veritabanı odaklı',
    githubHandle: 'selindemir',
    badges: [_ilkTeslim, _takimOyuncusu, _temizKod, _sirketProjesi],
    skills: ['Spring Boot', 'Java', 'PostgreSQL', 'Docker', 'REST API'],
    portfolio: [
      PortfolioItem(
        title: 'Kampüs Etkinlik & Kulüp Yönetim Sistemi',
        company: 'FinPay Teknoloji',
        role: 'Backend Geliştirici',
        contributionScore: 94,
        technologies: ['Spring Boot', 'PostgreSQL'],
      ),
      PortfolioItem(
        title: 'KOBİ Aylık Satış Analiz Paneli',
        company: 'TrendTech Yazılım',
        role: 'Veritabanı Tasarımı',
        contributionScore: 91,
        technologies: ['PostgreSQL', 'REST API'],
      ),
    ],
  ),
  'Kaan Yılmaz': const StudentProfile(
    name: 'Kaan Yılmaz',
    classYear: '2. Sınıf',
    focus: 'Mobile & Full-Stack odaklı',
    githubHandle: 'kaanyilmaz',
    badges: [_ilkTeslim, _takimOyuncusu, _temizKod, _sirketProjesi],
    skills: ['Flutter', 'Firebase', 'Node.js', 'Git & GitHub'],
    portfolio: [
      PortfolioItem(
        title: 'Kampüs Etkinlik & Kulüp Yönetim Sistemi',
        company: 'FinPay Teknoloji',
        role: 'Mobile Geliştirici',
        contributionScore: 90,
        technologies: ['Flutter', 'QR'],
      ),
      PortfolioItem(
        title: 'Klinik Randevu & Hatırlatma Platformu',
        company: 'PROVIA Topluluk',
        role: 'Mobile Geliştirici',
        contributionScore: 86,
        technologies: ['Flutter', 'Firebase'],
      ),
    ],
  ),
  'Zeynep Arslan': StudentProfile(
    name: 'Zeynep Arslan',
    classYear: '1. Sınıf',
    focus: 'UI/UX & Ürün odaklı',
    githubHandle: 'zeyneparslan',
    badges: [
      _ilkTeslim,
      _takimOyuncusu,
      _locked(_temizKod, 'AI kod puanı 85+ al'),
      _sirketProjesi,
    ],
    skills: const ['Figma', 'UI/UX', 'Flutter', 'Kullanıcı Araştırması'],
    portfolio: const [
      PortfolioItem(
        title: 'KOBİ Aylık Satış Analiz Paneli',
        company: 'TrendTech Yazılım',
        role: 'UI/UX Tasarımcı',
        contributionScore: 89,
        technologies: ['Figma', 'Flutter'],
      ),
      PortfolioItem(
        title: 'Akıllı Bildirim Filtreleme Uygulaması',
        company: 'PROVIA Topluluk',
        role: 'UI/UX Tasarımcı',
        contributionScore: 84,
        technologies: ['Figma'],
      ),
    ],
  ),
  'Burak Kaya': StudentProfile(
    name: 'Burak Kaya',
    classYear: '1. Sınıf',
    focus: 'Mobile odaklı',
    githubHandle: 'burakkaya',
    badges: [
      _ilkTeslim,
      _locked(_takimOyuncusu, '3 farklı ekipte çalış'),
      _locked(_temizKod, 'AI kod puanı 85+ al'),
      _locked(_sirketProjesi, 'Şirket destekli proje tamamla'),
    ],
    skills: const ['Flutter', 'Dart', 'Local Storage'],
    portfolio: const [
      PortfolioItem(
        title: 'Akıllı Bildirim Filtreleme Uygulaması',
        company: 'PROVIA Topluluk',
        role: 'Mobile Geliştirici',
        contributionScore: 77,
        technologies: ['Flutter', 'Dart'],
      ),
    ],
  ),
};

/// Sıralamadaki ada göre profil verisi döner ("(Sen)" eki yok sayılır).
StudentProfile profileFor(String leaderboardName) {
  final name = leaderboardName.replaceAll('(Sen)', '').trim();
  return _profiles[name] ??
      StudentProfile(
        name: name,
        classYear: '',
        focus: 'Yazılım öğrencisi',
        githubHandle: '',
        badges: const [],
        skills: const [],
        portfolio: const [],
      );
}
