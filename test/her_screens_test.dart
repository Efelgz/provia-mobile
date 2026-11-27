import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provia/main.dart';
import 'package:provia/core/widgets/provia_components.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> start(WidgetTester tester, Size logical) async {
    tester.view.physicalSize = logical * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviaApp());
    await tester.pumpAndSettle();
    final demo = find.text('Hızlı Demo Girişi');
    await tester.ensureVisible(demo);
    await tester.pumpAndSettle();
    await tester.tap(demo);
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, Size size, int index) async {
    const mobile = ['Ana Sayfa', 'Keşfet', 'Alanım', 'Sıralama', 'Profil'];
    const desktop = [
      'Ana Sayfa',
      'Projeleri Keşfet',
      'Proje Çalışma Alanı',
      'Liderlik Tablosu',
      'Profil & Portfolyo',
    ];
    final label = size.width >= 900 ? desktop[index] : mobile[index];
    await tester.tap(find.text(label).first);
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(360, 800), const Size(1440, 1000)]) {
    testWidgets('Keşfet arama, sekme filtresi ve detay (${size.width})', (
      tester,
    ) async {
      await start(tester, size);
      await openTab(tester, size, 1);

      expect(find.text('6 proje'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'kobi');
      await tester.pumpAndSettle();
      expect(find.text('1 proje'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();
      Finder tab(String label) => find.descendant(
        of: find.byType(UnderlineTabs<String>),
        matching: find.text(label),
      );
      await tester.ensureVisible(tab('İleri'));
      await tester.pumpAndSettle();
      await tester.tap(tab('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('2 proje', skipOffstage: false), findsOneWidget);
      await tester.ensureVisible(tab('Tümü'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Tümü'));
      await tester.pumpAndSettle();

      final detail = find.text('Detay').first;
      await tester.ensureVisible(detail);
      await tester.pumpAndSettle();
      await tester.tap(detail);
      await tester.pumpAndSettle();
      expect(find.text('Açık roller'), findsOneWidget);
      await tester.tap(find.byTooltip('Kapat'));
      await tester.pumpAndSettle();
    });

    testWidgets('Sıralama tablosu + Yıllık/Takım (${size.width})', (
      tester,
    ) async {
      await start(tester, size);
      await openTab(tester, size, 3);
      expect(find.textContaining('Senin sıran: #4'), findsOneWidget);
      expect(find.text('Deniz Aydın (Sen)'), findsOneWidget);

      await tester.tap(find.text('Yıllık'));
      await tester.pumpAndSettle();
      expect(find.text('Selin Demir'), findsOneWidget);

      await tester.tap(find.text('Takım'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Takımının sırası'), findsOneWidget);
      expect(find.text('Veri Kaşifleri'), findsOneWidget);
    });

    testWidgets('Profil sekmesi (${size.width})', (tester) async {
      await start(tester, size);
      await openTab(tester, size, 4);
      expect(find.text('Deniz Aydın'), findsWidgets);
      expect(find.textContaining('@deniz-aydin'), findsOneWidget);
      expect(find.text('Portfolyoyu Paylaş'), findsOneWidget);
      expect(find.text('Doğrulanmış Projeler'), findsOneWidget);
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
      await tester.pumpAndSettle();
    });
  }
}
