import 'package:flutter/foundation.dart';

/// Oturum boyunca ekranlar arasında paylaşılan küçük durumlar.
/// main.dart bunları kayıtlı ilerlemeden yükler ve değişince kaydeder.
class ProviaSession {
  /// Takım daveti gönderilen öğrenciler (Profil ve Takımlar ekranı ortak).
  static final ValueNotifier<Set<String>> invitedStudents =
      ValueNotifier<Set<String>>(<String>{});

  /// "Deniz Aydın (Sen)" gibi ekleri yok sayar.
  static String _key(String name) => name.replaceAll('(Sen)', '').trim();

  static bool isInvited(String name) =>
      invitedStudents.value.contains(_key(name));

  /// Daveti gönderir veya geri alır; yeni durumu döner (true = davetli).
  static bool toggleInvite(String name) {
    final key = _key(name);
    final next = {...invitedStudents.value};
    final invited = !next.remove(key);
    if (invited) next.add(key);
    invitedStudents.value = next;
    return invited;
  }
}
