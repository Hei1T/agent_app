import 'package:benben_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('phone shell golden', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: BenbenApp()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BenbenApp),
      matchesGoldenFile('goldens/phone_shell.png'),
    );
  });

  testWidgets('tablet shell golden', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: BenbenApp()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BenbenApp),
      matchesGoldenFile('goldens/tablet_shell.png'),
    );
  });
}
