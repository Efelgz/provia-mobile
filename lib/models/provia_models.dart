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

/// Kullanıcının oluşturduğu takım (Takımlar modülü).
class CreatedTeam {
  final String id;
  final String name;
  final String projectId;
  final List<String> openRoles;

  const CreatedTeam({
    required this.id,
    required this.name,
    required this.projectId,
    required this.openRoles,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'projectId': projectId,
    'openRoles': openRoles,
  };

  factory CreatedTeam.fromJson(Map<String, dynamic> json) => CreatedTeam(
    id: json['id'] as String,
    name: json['name'] as String,
    projectId: json['projectId'] as String,
    openRoles: List<String>.from(json['openRoles'] as List? ?? const []),
  );
}
