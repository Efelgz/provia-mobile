import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provia/main.dart';

void main() {
  setUpAll(() {
    // Testlerde font indirmeye çalışmasın.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Uygulama açılır ve 5 sekme görünür', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviaApp());

    for (final label in ['Panel', 'Keşfet', 'Alanım', 'Sıralama', 'Profil']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('Sıralama'));
    await tester.pumpAndSettle();
    expect(find.text('Liderlik Tablosu'), findsWidgets);
  });
}
