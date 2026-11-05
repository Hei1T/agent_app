import 'package:benben_app/core/contract/companion_state.dart';
import 'package:benben_app/features/profile/data/profile_mapper.dart';
import 'package:benben_app/features/today/data/companion_state_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support.dart';

void main() {
  final state = CompanionState.fromJson(fakeStateJson);

  test('companionOf maps contract fields once', () {
    final companion = companionOf(state);
    expect(companion.name, '笨笨');
    expect(companion.day, 5);
    expect(companion.place, '旧书店');
    expect(companion.action, '醒着');
    expect(companion.weather, '小雪');
    expect(companion.temperature, '1.7°C');
    expect(companion.energy, 72);
    expect(companion.mood, '61%');
    expect(companion.satiety, 45);
    expect(companion.awake, isTrue);
    expect(companion.lastSeen, '15:32');
    expect(companion.quote, '把晒了一下午的旧书收回来。');
    expect(companion.quoteMeta, '15:32 · 旧书店');
  });

  test('timelineOf uses contract event fields, no fabricated photos', () {
    final entries = timelineOf(state);
    expect(entries, hasLength(1));
    expect(entries.single.id, 'evt_1');
    expect(entries.single.time, '15:32');
    expect(entries.single.title, '笨笨 · 收书');
    expect(entries.single.detail, '把晒了一下午的旧书收回来。');
    expect(entries.single.feeling, '安静');
    expect(entries.single.photo, isNull);
    expect(entries.single.unread, 0);
  });

  test('status labels handle enums, transit and unknown values', () {
    expect(companionStatusLabel('awake'), '醒着');
    expect(companionStatusLabel('asleep'), '睡着');
    expect(companionStatusLabel('busy'), '忙着');
    expect(companionStatusLabel('quiet'), '安静');
    expect(companionStatusLabel('brand_new_status'), 'brand_new_status');
    expect(
      companionStatusLabel(
        'awake',
        transit: const CompanionTransit(from: '旧书店', to: '河堤'),
      ),
      '在路上',
    );
    expect(
      transitLabel(
        const CompanionTransit(from: '旧书店', to: '河堤', etaMinutes: 12),
      ),
      '旧书店 → 河堤 · 还有 12 分钟',
    );
    expect(transitLabel(null), '');
  });

  test('todaySubtitle prefers contract clockLabel/weather', () {
    expect(todaySubtitle(state), '15:32 · 小雪');
    expect(todaySubtitle(null), '正在连到栖湾…');
    final offline = CompanionState.fromJson({
      'companion': {'id': 'cmp_1', 'displayName': '笨笨'},
      'world': {'available': false},
    });
    expect(todaySubtitle(offline), '他的世界暂时没连上');
  });

  test('profileOf maps people and items', () {
    final profile = profileOf(state);
    expect(profile.people.single.name, '林叔');
    expect(profile.people.single.role, '旧书店掌柜');
    expect(profile.people.single.note, '今天见过');
    expect(profile.things.single.name, '厚毛衣');
    expect(profile.things.single.detail, '衣物 · home');
    expect(itemKindLabel('clothing'), '衣物');
    expect(itemKindLabel(null), '物件');
  });
}
