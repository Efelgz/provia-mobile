import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provia/main.dart';

void main() {
  setUpAll(() {
    // Testlerde font indirmeye çalışmasın.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    // Her test boş bir cihaz kaydıyla başlar.
    SharedPreferences.setMockInitialValues({});
  });

  void usePhoneSize(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width * 3, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// Uygulamayı (yeniden) başlatır. Farklı key, sıfırdan açılışı taklit eder.
  Future<void> startApp(WidgetTester tester, {Key? key}) async {
    await tester.pumpWidget(ProviaApp(key: key));
    await tester.pumpAndSettle();
  }

  Future<void> demoLogin(WidgetTester tester) async {
    final button = find.text('Hızlı Demo Girişi');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  /// Keşfet kartındaki katıl butonu ("Katıl" veya eski "Projeye Katıl").
  Finder joinButton() => find.textContaining(RegExp(r'^(Projeye )?Katıl$'));

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  /// Açık sayfayı en üste kaydırır.
  Future<void> scrollToTop(WidgetTester tester) async {
    final lists = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    await tester.drag(lists.first, const Offset(0, 2000));
    await tester.pumpAndSettle();
  }

  /// Açık bildirimin kapanmasını bekler (alttaki öğeleri örtmesin).
  Future<void> waitSnackBar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('Giriş ekranı açılır, demo girişi 5 sekmeyi gösterir', (
    tester,
  ) async {
    usePhoneSize(tester, 360);
    await startApp(tester);

    expect(find.text('İlk stajından önce deneyim kazan.'), findsOneWidget);
    await demoLogin(tester);

    for (final label in [
      'Ana Sayfa',
      'Keşfet',
      'Alanım',
      'Sıralama',
      'Profil',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Tekrar hoş geldin, Deniz'), findsOneWidget);
    expect(find.text('1450 XP'), findsWidgets);
  });

  for (final width in [360.0, 390.0]) {
    testWidgets('Projeye katıl, projeler arası geçiş ($width px)', (
      tester,
    ) async {
      usePhoneSize(tester, width);
      await startApp(tester);
      await demoLogin(tester);

      // p1 zaten katılınmış görünür.
      await tester.tap(find.text('Keşfet'));
      await tester.pumpAndSettle();
      expect(find.text('Katıldın'), findsOneWidget);

      // İkinci projeye katıl: +50 XP ve aktif proje olur.
      await tapVisible(tester, joinButton().first);
      expect(find.text('1500 XP'), findsWidgets);
      expect(find.text('Katıldın'), findsWidgets);
      await waitSnackBar(tester);

      await tester.tap(find.text('Ana Sayfa'));
      await tester.pumpAndSettle();
      expect(
        find.text('Çalışma Alanında Aç', skipOffstage: false),
        findsNWidgets(2),
      );

      // Alanım (mobil): yeni projenin görevleri sekmelerde görünür.
      await tester.tap(find.text('Alanım'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Yapılacak'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bildirim izinleri ve odak modu ayar ekranı'),
        findsOneWidget,
      );
      await scrollToTop(tester);
      await tester.tap(find.text('KOBİ Aylık Satış Analiz Paneli').first);
      await tester.pumpAndSettle();

      // Görev XP'si yalnızca bir kez verilir; görev sütunlar arasında gezer.
      final task = find.text('Aylık satış grafiği ve filtreleme bileşeni');
      Future<void> openTab(String label) async {
        await tapVisible(tester, find.text(label));
        await tester.pumpAndSettle();
      }

      await openTab('Devam');
      await tapVisible(tester, task); // Devam Ediyor -> Tamamlandı (+120)
      expect(find.text('1620 XP'), findsWidgets);
      expect(task, findsNothing); // Bitti sütununa geçti
      await openTab('Bitti');
      await tapVisible(tester, task); // -> Yapılacak
      await openTab('Yapılacak');
      await tapVisible(tester, task); // -> Devam Ediyor
      await openTab('Devam');
      await tapVisible(tester, task); // -> Tamamlandı (XP yok)
      expect(find.text('1620 XP'), findsWidgets);
    });
  }

  testWidgets('İlerleme uygulama yeniden açılınca korunur', (tester) async {
    usePhoneSize(tester, 390);
    await startApp(tester, key: const ValueKey('ilk-acilis'));
    await demoLogin(tester);

    await tester.tap(find.text('Keşfet'));
    await tester.pumpAndSettle();
    await tapVisible(tester, joinButton().first);
    await waitSnackBar(tester);

    await tester.tap(find.text('Alanım'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KOBİ Aylık Satış Analiz Paneli').first);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Devam'));
    await tester.pumpAndSettle();
    await tapVisible(
      tester,
      find.text('Aylık satış grafiği ve filtreleme bileşeni'),
    );
    expect(find.text('1620 XP'), findsWidgets);
    await waitSnackBar(tester);

    // Uygulamayı sıfırdan aç: oturum, XP, projeler ve görevler yerinde.
    await startApp(tester, key: const ValueKey('ikinci-acilis'));
    expect(find.text('Hızlı Demo Girişi'), findsNothing);
    expect(find.text('1620 XP'), findsWidgets);
    expect(
      find.text('Çalışma Alanında Aç', skipOffstage: false),
      findsNWidgets(2),
    );

    await tester.tap(find.text('Alanım'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Bitti'));
    await tester.pumpAndSettle();
    expect(
      find.text('Aylık satış grafiği ve filtreleme bileşeni'),
      findsOneWidget,
    );
  });

  testWidgets('Kayıt olan yeni kullanıcı boş başlar, çıkış yapabilir', (
    tester,
  ) async {
    usePhoneSize(tester, 390);
    await startApp(tester);

    await tester.tap(find.text('Kayıt Ol'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ad Soyad'),
      'Ece Tunç',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Üniversite'),
      'Ege Üni.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-posta'),
      'ece@ornek.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Şifre'),
      'gizli123',
    );
    await tapVisible(tester, find.text('Hesap Oluştur'));
    await tester.pumpAndSettle();

    expect(find.text('Tekrar hoş geldin, Ece'), findsOneWidget);
    expect(find.text('0 XP'), findsWidgets);
    expect(find.textContaining('Henüz bir projeye katılmadın'), findsOneWidget);

    await tester.tap(find.text('Alanım'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz bir projen yok'), findsOneWidget);

    // Çıkış -> giriş ekranı; aynı e-posta ile tekrar giriş yapılabilir.
    await tester.tap(find.byTooltip('Hesap menüsü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Çıkış Yap'));
    await tester.pumpAndSettle();
    expect(find.text('Hızlı Demo Girişi'), findsOneWidget);

    // Tanıtım sayfasından giriş formunu aç.
    await tester.tap(find.text('Giriş Yap'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-posta'),
      'ECE@ornek.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Şifre'),
      'gizli123',
    );
    await tapVisible(tester, find.text('Giriş Yap').last);
    await tester.pumpAndSettle();
    expect(find.text('Tekrar hoş geldin, Ece'), findsOneWidget);
  });

  testWidgets('Sıralamada öğrenciye dokununca profili açılır', (tester) async {
    usePhoneSize(tester, 390);
    await startApp(tester);
    await demoLogin(tester);

    await tester.tap(find.text('Sıralama'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Selin Demir'));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenci Profili'), findsOneWidget);
    expect(find.text('Takımına Davet Et'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Deniz Aydın (Sen)'));
    await tester.pumpAndSettle();
    expect(find.text('Profilin'), findsOneWidget);
  });

  testWidgets('Masaüstü: sol menü, KPI ızgarası ve 3 sütunlu pano', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await startApp(tester);
    await demoLogin(tester);

    // Alt menü yok, sol menü var.
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Öğrenci'), findsOneWidget);
    expect(find.text('Şirket Paneli'), findsOneWidget);
    expect(find.text('Ortalama AI Skoru'), findsOneWidget);
    expect(find.text('Yaklaşan Teslim Tarihleri'), findsOneWidget);

    await tester.tap(find.text('Proje Çalışma Alanı'));
    await tester.pumpAndSettle();
    for (final column in ['Yapılacak', 'Devam Ediyor', 'Tamamlandı']) {
      expect(find.text(column), findsOneWidget);
    }

    // AI değerlendirmesi: rapor ve katkı tablosu görünür.
    await tapVisible(tester, find.text('Değerlendir'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Bireysel Katkı Tahmini'), findsOneWidget);
    expect(find.textContaining('MVP simülasyonu'), findsWidgets);
    await waitSnackBar(tester);

    await tester.tap(find.text('Ana Sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('88/100'), findsOneWidget);
  });

  testWidgets('Tanıtım sayfası: bölümler ve formlar arası geçiş', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await startApp(tester);

    expect(find.text('Nasıl Çalışır?'), findsOneWidget);
    expect(find.text('Öne Çıkan Gerçek Dünya Projeleri'), findsOneWidget);
    expect(find.text('Şirket Panelini Önizle'), findsOneWidget);

    await tester.tap(find.text('Kayıt Ol'));
    await tester.pumpAndSettle();
    expect(find.text('Hesap Oluştur'), findsOneWidget);
    await tester.tap(find.text('Ana Sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('Nasıl Çalışır?'), findsOneWidget);
  });

  testWidgets('Takımlar, Etkinlikler ve Şirket Paneli (masaüstü)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await startApp(tester, key: const ValueKey('moduller-1'));
    await demoLogin(tester);

    // Takımlar: başvur + takım oluştur
    await tester.tap(find.text('Takımlar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Başvur').first);
    await tester.pumpAndSettle();
    expect(find.text('Başvuruldu'), findsOneWidget);
    await waitSnackBar(tester);

    await tester.tap(find.text('Takım Oluştur').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Kod Kartalları');
    await tester.tap(find.text('Backend').last);
    await tester.tap(find.text('Oluştur'));
    await tester.pumpAndSettle();
    expect(find.text('Kod Kartalları'), findsOneWidget);
    await waitSnackBar(tester);

    // Etkinlikler: kayıt +15 XP, iptal + tekrar kayıt XP vermez, dolu buton
    await tester.tap(find.text('Etkinlikler').first);
    await tester.pumpAndSettle();
    expect(find.text('Dolu'), findsOneWidget);
    await tester.tap(find.text('Kayıt Ol').first);
    await tester.pumpAndSettle();
    expect(find.text('1465 XP'), findsWidgets);
    await tester.tap(find.text('Kayıtlısın'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kayıt Ol').first);
    await tester.pumpAndSettle();
    expect(find.text('1465 XP'), findsWidgets);
    await waitSnackBar(tester);

    // Şirket Paneli: filtre + davet
    await tester.tap(find.text('Şirket Paneli').first);
    await tester.pumpAndSettle();
    expect(find.text('Yetenek Havuzu'), findsOneWidget);
    await tester.tap(find.byTooltip('Min. AI skoru seç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('90+').last);
    await tester.pumpAndSettle();
    expect(find.text('Mülakata Davet Et'), findsNWidgets(2));
    await tapVisible(tester, find.text('Mülakata Davet Et').first);
    await tester.pumpAndSettle();
    expect(find.text('Davet edildi'), findsOneWidget);
    await waitSnackBar(tester);

    // Yeniden açılış: başvuru, takım ve etkinlik kaydı korunur
    await startApp(tester, key: const ValueKey('moduller-2'));
    await tester.tap(find.text('Takımlar').first);
    await tester.pumpAndSettle();
    expect(find.text('Başvuruldu'), findsOneWidget);
    await tester.tap(find.text('Etkinlikler').first);
    await tester.pumpAndSettle();
    expect(find.text('Kayıtlısın'), findsOneWidget);
    expect(find.text('1465 XP'), findsWidgets);
  });

  testWidgets('Mobilde modüller menüden açılır', (tester) async {
    usePhoneSize(tester, 360);
    await startApp(tester);
    await demoLogin(tester);

    for (final label in [
      'Takımlar',
      'Etkinlikler',
      'Şirket Paneli (Önizleme)',
    ]) {
      await tester.tap(find.byTooltip('Hesap menüsü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Şirket Paneli: iş tanımı ve becerilerle görev yayınla', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await startApp(tester);
    await demoLogin(tester);

    await tester.tap(find.text('Şirket Paneli').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Görev Yayınla'));
    await tester.pumpAndSettle();

    // Boş gönderim: hatalar alanların yanında görünür.
    await tester.tap(find.text('Yayınla'));
    await tester.pumpAndSettle();
    expect(find.text('Görev başlığı en az 5 karakter olmalı.'), findsOneWidget);
    expect(find.text('En az bir rol seç.'), findsOneWidget);

    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Sipariş Takip Ekranı');
    await tester.enterText(
      fields.at(1),
      'Siparişleri listeleyen mobil ekranı geliştirecek, durum filtresi '
      'ekleyecek ve REST API ile bağlayacaksın.',
    );
    await tester.tap(find.text('Frontend').last);
    await tester.tap(find.text('Backend').last);
    await tester.tap(find.text('Flutter').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yayınla'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Sipariş Takip Ekranı'), findsOneWidget);
    expect(find.text('Aranan: Frontend  ·  Backend'), findsOneWidget);
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets('Logoya basınca Ana Sayfa açılır ($width px)', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await startApp(tester);
      await demoLogin(tester);

      await tester.tap(
        find.text(width >= 900 ? 'Projeleri Keşfet' : 'Keşfet').first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Tekrar hoş geldin, Deniz'), findsNothing);

      await tester.tap(find.byTooltip('Ana Sayfa').first);
      await tester.pumpAndSettle();
      expect(find.text('Tekrar hoş geldin, Deniz'), findsOneWidget);
    });
  }

  testWidgets('Davet ve başvuru geri alınabilir (profil + takımlar)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await startApp(tester);
    await demoLogin(tester);

    // Profil: davet et -> gönderildi -> iptal -> tekrar "Takımına Davet Et"
    await tester.tap(find.text('Liderlik Tablosu').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zeynep Arslan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Takımına Davet Et'));
    await tester.pumpAndSettle();
    expect(find.text('Davet gönderildi'), findsOneWidget);
    await waitSnackBar(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Takımlar: aynı kişi "Davet gönderildi" görünür (ortak durum)
    await tester.tap(find.text('Takımlar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Takım Arkadaşı Bul'));
    await tester.pumpAndSettle();
    expect(find.text('Davet gönderildi'), findsOneWidget);

    // Davet iptal: kısa süre "Davet iptal edildi", sonra "Davet Et"
    await tester.tap(find.text('Davet gönderildi'));
    await tester.pump();
    expect(find.text('Davet iptal edildi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Davet iptal edildi'), findsNothing);
    expect(find.text('Davet gönderildi'), findsNothing);
    expect(find.text('Davet Et'), findsNWidgets(6));

    // Başvuru: başvur -> başvuruldu -> geri çek -> başvur
    await tester.tap(find.text('Açık Takımlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Başvur').first);
    await tester.pumpAndSettle();
    expect(find.text('Başvuruldu'), findsOneWidget);
    await tester.tap(find.text('Başvuruldu'));
    await tester.pump();
    expect(find.text('Başvuru geri çekildi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Başvuruldu'), findsNothing);
    expect(find.text('Başvur'), findsNWidgets(5));
    await waitSnackBar(tester);
  });
}
