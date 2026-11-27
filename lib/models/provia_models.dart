class ProviaProject {
  final String id;
  final String title;
  final String company;
  final bool isCompanySponsored;
  final String difficulty; // Başlangıç, Orta, İleri
  final String description;
  final List<String> technologies;
  final List<String> openRoles;
  final String deadline;
  final int xpReward;

  const ProviaProject({
    required this.id,
    required this.title,
    required this.company,
    required this.isCompanySponsored,
    required this.difficulty,
    required this.description,
    required this.technologies,
    required this.openRoles,
    required this.deadline,
    required this.xpReward,
  });
}

class ProviaTask {
  final String id;
  final String title;
  final String assignee;
  final String role;
  String status; // 'Yapılacak', 'Devam Ediyor', 'Tamamlandı'
  final int xp;

  /// Bu görevin XP'si verildi mi? Aynı görevden tekrar tekrar XP
  /// kazanılmasını engeller.
  bool xpAwarded;

  ProviaTask({
    required this.id,
    required this.title,
    required this.assignee,
    required this.role,
    required this.status,
    required this.xp,
    bool? xpAwarded,
  }) : xpAwarded = xpAwarded ?? status == 'Tamamlandı';
}

class LeaderboardUser {
  final int rank;
  final String name;
  final String university;
  final int xp;
  final int level;
  final int completedProjects;

  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.university,
    required this.xp,
    required this.level,
    required this.completedProjects,
  });
}
