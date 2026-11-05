import 'package:benben_app/core/contract/diary.dart';
import 'package:benben_app/core/contract/moment.dart';
import 'package:benben_app/core/providers/app_providers.dart';
import 'package:benben_app/core/theme/app_theme.dart';
import 'package:benben_app/features/diary/presentation/diary_view.dart';
import 'package:benben_app/features/moments/presentation/moments_view.dart';
import 'package:benben_app/features/today/presentation/today_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  FakeApiClient? api,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiProvider.overrideWithValue(api ?? FakeApiClient())],
      child: MaterialApp(theme: buildAppTheme(), home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('today renders CompanionState through the mapper', (
    tester,
  ) async {
    await _pump(tester, const TodayView());
    expect(find.byKey(const Key('today_view')), findsOneWidget);
    expect(find.text('在旧书店 · 醒着'), findsOneWidget);
    expect(find.text('15:32 · 小雪'), findsWidgets);
  });

  testWidgets('moments empty state is legal', (tester) async {
    await _pump(tester, const MomentsView(), api: FakeApiClient());
    expect(find.text('还没有动态'), findsOneWidget);
  });

  testWidgets('moments renders contract moment', (tester) async {
    final page = MomentsPage.fromJson({
      'items': [
        {
          'id': 'post_1',
          'author': {'type': 'companion', 'name': '笨笨'},
          'timeLabel': '15:32',
          'place': '旧书店',
          'text': '今天把后院的旧书搬出来晒。',
          'likes': [
            {'actorType': 'npc', 'name': '林叔'},
          ],
        },
      ],
      'nextCursor': null,
    });
    await _pump(
      tester,
      const MomentsView(),
      api: FakeApiClient(momentsPage: page),
    );
    expect(find.text('今天把后院的旧书搬出来晒。'), findsOneWidget);
    expect(find.text('笨笨'), findsWidgets);
  });

  testWidgets('diary empty state is legal', (tester) async {
    await _pump(tester, const DiaryView(), api: FakeApiClient());
    expect(find.text('他还没有写过日记。'), findsOneWidget);
  });

  testWidgets('diary renders contract entry', (tester) async {
    final page = DiaryPage.fromJson({
      'items': [
        {
          'day': '2026-11-04',
          'text': '十一月的头一天。\n\n夜里的雨一阵一阵的。',
          'createdAt': '2026-11-04T22:40:00+08:00',
        },
      ],
      'nextCursor': null,
    });
    await _pump(tester, const DiaryView(), api: FakeApiClient(diaryPage: page));
    expect(find.text('11月4日'), findsWidgets);
    expect(find.text('周三'), findsWidgets);
  });
}
