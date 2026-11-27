import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provia/main.dart';

void main() {
  setUpAll(() {
    // Testlerde font indirmeye çalışmasın.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void usePhoneSize(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width * 3, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('Uygulama açılır ve 5 sekme görünür', (tester) async {
    usePhoneSize(tester, 390);
    await tester.pumpWidget(const ProviaApp());

    for (final label in ['Panel', 'Keşfet', 'Alanım', 'Sıralama', 'Profil']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Hoş geldin, Deniz 👋'), findsOneWidget);
  });

  // Görev verileri statik olduğundan akış testi tek sefer, en dar
  // telefon genişliğinde çalışır.
  for (final width in [360.0]) {
    testWidgets('Projeye katıl, projeler arası geçiş ($width px)', (
      tester,
    ) async {
      usePhoneSize(tester, width);
      await tester.pumpWidget(const ProviaApp());

      // p1 zaten katılınmış görünür.
      await tester.tap(find.text('Keşfet'));
      await tester.pumpAndSettle();
      expect(find.text('Katıldın'), findsOneWidget);

      // İkinci projeye katıl -> +50 XP ve aktif proje olur.
      final joinButton = find.text('Projeye Katıl').first;
      await tester.ensureVisible(joinButton);
      await tester.pumpAndSettle();
      await tester.tap(joinButton);
      await tester.pump();
      expect(find.text('1500 XP'), findsWidgets);
      expect(find.text('Katıldın'), findsNWidgets(2));
      // Bildirim kapansın ki alttaki öğeleri örtmesin.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Panel'));
      await tester.pumpAndSettle();
      expect(find.text('Projelerin (2)'), findsOneWidget);
      expect(find.text('2 Proje'), findsOneWidget);

      // Alanım: yeni projenin görevleri açılır, geri geçiş yapılabilir.
      await tester.tap(find.text('Alanım'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bildirim izinleri ve odak modu ayar ekranı'),
        findsOneWidget,
      );
      await tester.tap(find.text('KOBİ Aylık Satış Analiz Paneli').first);
      await tester.pumpAndSettle();
      expect(
        find.text('Aylık satış grafiği ve filtreleme bileşeni'),
        findsOneWidget,
      );

      // Görev XP'si yalnızca bir kez verilir.
      final task = find.text('Aylık satış grafiği ve filtreleme bileşeni');
      await tester.ensureVisible(task);
      await tester.pumpAndSettle();
      await tester.tap(task); // Devam Ediyor -> Tamamlandı (+120)
      await tester.pump();
      expect(find.text('1620 XP'), findsWidgets);
      await tester.tap(task); // -> Yapılacak
      await tester.pump();
      await tester.tap(task); // -> Devam Ediyor
      await tester.pump();
      await tester.tap(task); // -> Tamamlandı (XP yok)
      await tester.pump();
      expect(find.text('1620 XP'), findsWidgets);
    });
  }

  testWidgets('Sıralamada öğrenciye dokununca profili açılır', (tester) async {
    usePhoneSize(tester, 390);
    await tester.pumpWidget(const ProviaApp());

    await tester.tap(find.text('Sıralama'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selin Demir'));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenci Profili'), findsOneWidget);
    expect(find.text('Takımına Davet Et'), findsOneWidget);
    expect(find.text('Backend & Veritabanı odaklı'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deniz Aydın (Sen)'));
    await tester.pumpAndSettle();
    expect(find.text('Profilin'), findsOneWidget);
    expect(find.text('Portfolyoyu Paylaş'), findsOneWidget);
  });
}
