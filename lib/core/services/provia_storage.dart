import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/provia_models.dart';

/// Cihazda saklanan öğrenci hesabı (MVP: backend yok, şifre saklanmaz).
class ProviaAccount {
  final String id;
  final String name;
  final String university;
  final String email;
  final bool isDemo;

  const ProviaAccount({
    required this.id,
    required this.name,
    required this.university,
    required this.email,
    this.isDemo = false,
  });

  static const demo = ProviaAccount(
    id: 'demo',
    name: 'Deniz Aydın',
    university: 'Marmara Üni. • Yazılım Müh.',
    email: 'demo@provia.app',
    isDemo: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'university': university,
    'email': email,
    'isDemo': isDemo,
  };

  factory ProviaAccount.fromJson(Map<String, dynamic> json) => ProviaAccount(
    id: json['id'] as String,
    name: json['name'] as String,
    university: json['university'] as String,
    email: json['email'] as String,
    isDemo: json['isDemo'] as bool? ?? false,
  );
}

/// Bir görevin kaydedilen durumu.
class TaskState {
  final String status;
  final bool xpAwarded;

  const TaskState(this.status, this.xpAwarded);
}

/// Hesabın uygulama içindeki ilerlemesi.
class ProviaProgress {
  final int xp;
  final List<String> joinedProjectIds;
  final String? activeProjectId;
  final Set<String> evaluatedProjectIds;
  final Map<String, TaskState> taskStates;

  // Takımlar ve Etkinlikler modülleri
  final Set<String> appliedTeamIds;
  final List<CreatedTeam> createdTeams;
  final Set<String> registeredEventIds;

  /// XP'si verilmiş etkinlikler (kayıt iptal edip yeniden olunca tekrar XP yok).
  final Set<String> awardedEventIds;

  const ProviaProgress({
    required this.xp,
    required this.joinedProjectIds,
    required this.activeProjectId,
    required this.evaluatedProjectIds,
    required this.taskStates,
    this.appliedTeamIds = const {},
    this.createdTeams = const [],
    this.registeredEventIds = const {},
    this.awardedEventIds = const {},
  });

  /// Demo hesabı hazır verilerle başlar; yeni hesaplar sıfırdan başlar.
  factory ProviaProgress.initialFor(ProviaAccount account) => account.isDemo
      ? const ProviaProgress(
          xp: 1450,
          joinedProjectIds: ['p1'],
          activeProjectId: 'p1',
          evaluatedProjectIds: {},
          taskStates: {},
        )
      : const ProviaProgress(
          xp: 0,
          joinedProjectIds: [],
          activeProjectId: null,
          evaluatedProjectIds: {},
          taskStates: {},
        );

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'joinedProjectIds': joinedProjectIds,
    'activeProjectId': activeProjectId,
    'evaluatedProjectIds': evaluatedProjectIds.toList(),
    'taskStates': {
      for (final e in taskStates.entries)
        e.key: {'status': e.value.status, 'xpAwarded': e.value.xpAwarded},
    },
    'appliedTeamIds': appliedTeamIds.toList(),
    'createdTeams': [for (final t in createdTeams) t.toJson()],
    'registeredEventIds': registeredEventIds.toList(),
    'awardedEventIds': awardedEventIds.toList(),
  };

  factory ProviaProgress.fromJson(Map<String, dynamic> json) {
    final tasks = (json['taskStates'] as Map<String, dynamic>? ?? {});
    return ProviaProgress(
      xp: json['xp'] as int? ?? 0,
      joinedProjectIds: List<String>.from(
        json['joinedProjectIds'] as List? ?? const [],
      ),
      activeProjectId: json['activeProjectId'] as String?,
      evaluatedProjectIds: Set<String>.from(
        json['evaluatedProjectIds'] as List? ?? const [],
      ),
      taskStates: {
        for (final e in tasks.entries)
          e.key: TaskState(
            (e.value as Map<String, dynamic>)['status'] as String,
            (e.value as Map<String, dynamic>)['xpAwarded'] as bool? ?? false,
          ),
      },
      appliedTeamIds: Set<String>.from(
        json['appliedTeamIds'] as List? ?? const [],
      ),
      createdTeams: [
        for (final t in json['createdTeams'] as List? ?? const [])
          CreatedTeam.fromJson(t as Map<String, dynamic>),
      ],
      registeredEventIds: Set<String>.from(
        json['registeredEventIds'] as List? ?? const [],
      ),
      awardedEventIds: Set<String>.from(
        json['awardedEventIds'] as List? ?? const [],
      ),
    );
  }
}

/// shared_preferences üzerinde hesap ve ilerleme kaydı.
/// Faz 3'te aynı arayüz Supabase ile değiştirilebilir.
class ProviaStorage {
  static const _currentAccountKey = 'provia.currentAccountId';
  static String _accountKey(String id) => 'provia.account.$id';
  static String _progressKey(String id) => 'provia.progress.$id';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('ProviaStorage.init() çağrılmadan kullanıldı.');
    }
    return prefs;
  }

  /// Hesap kimliği olarak küçük harfli e-posta kullanılır.
  static String accountIdForEmail(String email) => email.trim().toLowerCase();

  // --- Oturum ---

  static ProviaAccount? loadCurrentAccount() {
    final id = _p.getString(_currentAccountKey);
    if (id == null) return null;
    if (id == ProviaAccount.demo.id) return ProviaAccount.demo;
    return loadAccount(id);
  }

  static Future<void> setCurrentAccount(ProviaAccount? account) async {
    if (account == null) {
      await _p.remove(_currentAccountKey);
    } else {
      await _p.setString(_currentAccountKey, account.id);
    }
  }

  // --- Hesaplar ---

  static ProviaAccount? loadAccount(String id) {
    final raw = _p.getString(_accountKey(id));
    if (raw == null) return null;
    return ProviaAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveAccount(ProviaAccount account) =>
      _p.setString(_accountKey(account.id), jsonEncode(account.toJson()));

  // --- İlerleme ---

  static ProviaProgress loadProgress(ProviaAccount account) {
    final raw = _p.getString(_progressKey(account.id));
    if (raw == null) return ProviaProgress.initialFor(account);
    try {
      return ProviaProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return ProviaProgress.initialFor(account);
    }
  }

  static Future<void> saveProgress(
    ProviaAccount account,
    ProviaProgress progress,
  ) => _p.setString(_progressKey(account.id), jsonEncode(progress.toJson()));

  static Future<void> clearProgress(ProviaAccount account) =>
      _p.remove(_progressKey(account.id));
}
