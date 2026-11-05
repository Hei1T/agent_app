import 'package:benben_app/core/contract/auth_contract.dart';
import 'package:benben_app/core/contract/chat_event.dart';
import 'package:benben_app/core/contract/companion_state.dart';
import 'package:benben_app/core/contract/diary.dart';
import 'package:benben_app/core/contract/moment.dart';
import 'package:flutter_test/flutter_test.dart';

const _stateJson = <String, dynamic>{
  'contractVersion': 1,
  'companion': {
    'id': 'cmp_123',
    'displayName': '笨笨',
    'day': 1,
    'place': {'id': 'bookstore', 'name': '旧书店'},
    'status': 'awake',
    'condition': '',
    'awake': true,
    'energy': 0.8,
    'mood': 0.6,
    'satiety': 0.39,
    'social': 0.7,
    'transit': null,
    'lastActiveAt': '2026-11-04T15:32:00+08:00',
  },
  'world': {
    'available': true,
    'clockLabel': '15:32',
    'weather': '小雪',
    'temperatureC': 1.7,
    'season': 'autumn',
    'dayOfWeek': 3,
  },
  'events': [
    {
      'id': 'evt_1',
      'occurredAt': '2026-11-04T15:32:00+08:00',
      'timeLabel': '15:32',
      'title': '收书',
      'detail': '把晒了一下午的旧书收回来。',
      'feeling': '安静',
      'sourceEventId': 'core_evt_1',
      'unknownField': 'ignored',
    },
  ],
  'people': [
    {
      'id': 'npc_lin',
      'name': '林叔',
      'role': '旧书店掌柜',
      'note': '今天见过',
      'place': '旧书店',
      'lastSeenDay': '2026-11-04',
    },
  ],
  'items': [
    {
      'id': 'item_1',
      'kind': 'clothing',
      'name': '厚毛衣',
      'note': '',
      'place': 'home',
    },
  ],
  'diary': null,
  'unknownTopLevel': true,
};

void main() {
  group('CompanionState', () {
    test('parses API Contract v1 companion/state', () {
      final state = CompanionState.fromJson(_stateJson);
      expect(state.contractVersion, 1);
      expect(state.companion.id, 'cmp_123');
      expect(state.companion.displayName, '笨笨');
      expect(state.companion.day, 1);
      expect(state.companion.place?.id, 'bookstore');
      expect(state.companion.place?.name, '旧书店');
      expect(state.companion.status, 'awake');
      expect(state.companion.awake, isTrue);
      expect(state.companion.energy, 0.8);
      expect(state.companion.mood, 0.6);
      expect(state.companion.satiety, 0.39);
      expect(state.companion.social, 0.7);
      expect(state.companion.transit, isNull);
      expect(state.companion.lastActiveAt, '2026-11-04T15:32:00+08:00');
      expect(state.world.available, isTrue);
      expect(state.world.clockLabel, '15:32');
      expect(state.world.weather, '小雪');
      expect(state.world.temperatureC, 1.7);
      expect(state.events.single.id, 'evt_1');
      expect(state.events.single.occurredAt, '2026-11-04T15:32:00+08:00');
      expect(state.events.single.timeLabel, '15:32');
      expect(state.events.single.title, '收书');
      expect(state.people.single.name, '林叔');
      expect(state.items.single.kind, 'clothing');
      expect(state.diary, isNull);
    });

    test('missing optional fields stay null instead of throwing', () {
      final state = CompanionState.fromJson({
        'companion': {'id': 'cmp_1', 'displayName': '笨笨'},
      });
      expect(state.companion.day, isNull);
      expect(state.companion.place, isNull);
      expect(state.companion.energy, isNull);
      expect(state.world.available, isFalse);
      expect(state.events, isEmpty);
      expect(state.people, isEmpty);
      expect(state.items, isEmpty);
      expect(state.diary, isNull);
    });

    test('numeric legacy ids are coerced to string', () {
      final state = CompanionState.fromJson({
        'companion': {
          'id': 123,
          'displayName': '笨笨',
          'place': {'name': '旧书店'},
        },
        'people': [
          {'id': 7, 'name': '林叔'},
        ],
      });
      expect(state.companion.id, '123');
      expect(state.people.single.id, '7');
    });

    test('transit parses from/to/etaMinutes', () {
      final transit = CompanionTransit.fromJson({
        'from': '旧书店',
        'to': '河堤',
        'etaMinutes': 12,
      });
      expect(transit.from, '旧书店');
      expect(transit.to, '河堤');
      expect(transit.etaMinutes, 12);
    });
  });

  group('Moments', () {
    test('parses items/photos/likes/comments and nextCursor', () {
      final page = MomentsPage.fromJson({
        'items': [
          {
            'id': 'post_1',
            'author': {'type': 'companion', 'id': 'cmp_123', 'name': '笨笨'},
            'createdAt': '2026-11-04T15:32:00+08:00',
            'timeLabel': '15:32',
            'place': '旧书店',
            'text': '今天把后院的旧书搬出来晒。',
            'photos': [
              {
                'url': 'https://api.example.com/media/post_1/1.jpg',
                'width': 1080,
                'height': 1440,
                'alt': '旧书',
              },
            ],
            'likes': [
              {'actorType': 'npc', 'name': '林叔'},
            ],
            'comments': [
              {
                'id': 'comment_1',
                'author': {'type': 'npc', 'name': '林叔'},
                'text': '晒书记得翻面。',
                'createdAt': '2026-11-04T15:40:00+08:00',
                'timeLabel': '15:40',
              },
            ],
            'visibility': 'public',
            'sourceEventId': 'evt_1',
          },
        ],
        'nextCursor': 'opaque_cursor',
      });
      final moment = page.items.single;
      expect(moment.id, 'post_1');
      expect(moment.author.type, 'companion');
      expect(moment.author.name, '笨笨');
      expect(moment.timeLabel, '15:32');
      expect(moment.displayTimeLabel, '15:32');
      expect(moment.photos.single.url, contains('/media/post_1/1.jpg'));
      expect(moment.photos.single.width, 1080);
      expect(moment.likes.single.actorType, 'npc');
      expect(moment.likes.single.name, '林叔');
      expect(moment.comments.single.id, 'comment_1');
      expect(moment.comments.single.author.name, '林叔');
      expect(moment.comments.single.timeLabel, '15:40');
      expect(moment.visibility, 'public');
      expect(page.nextCursor, 'opaque_cursor');
    });

    test('empty feed is a legal state', () {
      final page = MomentsPage.fromJson({'items': [], 'nextCursor': null});
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('derives display time from createdAt when timeLabel is absent', () {
      final moment = Moment.fromJson({
        'id': 'post_2',
        'createdAt': '2026-11-04T15:32:00+08:00',
      });
      expect(moment.displayTimeLabel, '15:32');
      expect(moment.photos, isEmpty);
      expect(moment.author.name, '');
    });

    test('like result keeps optional likeCount nullable', () {
      final withCount = MomentLikeResult.fromJson({
        'liked': true,
        'likeCount': 4,
      });
      expect(withCount.liked, isTrue);
      expect(withCount.likeCount, 4);
      final withoutCount = MomentLikeResult.fromJson({'liked': false});
      expect(withoutCount.liked, isFalse);
      expect(withoutCount.likeCount, isNull);
    });
  });

  group('Diary', () {
    test('parses optional id and raw day label', () {
      final page = DiaryPage.fromJson({
        'items': [
          {
            'day': '2026-11-01',
            'text': '十一月的头一天。',
            'createdAt': '2026-11-01T22:40:00+08:00',
          },
          {'day': '第 5 天', 'text': '', 'createdAt': null},
        ],
        'nextCursor': null,
      });
      expect(page.items, hasLength(2));
      expect(page.items.first.id, isNull);
      expect(page.items.first.day, '2026-11-01');
      expect(page.items.first.createdAt, '2026-11-01T22:40:00+08:00');
      expect(page.items.last.day, '第 5 天');
      expect(page.items.last.text, '');
      expect(page.nextCursor, isNull);
    });

    test('empty diary is a legal state', () {
      final page = DiaryPage.fromJson({'items': [], 'nextCursor': null});
      expect(page.items, isEmpty);
    });
  });

  group('ContractChatEvent', () {
    test('parses JSON delta / done / error / meta / tool', () {
      final delta = ContractChatEvent.parse('delta', '{"text":"嗯"}');
      expect(delta.isDelta, isTrue);
      expect(delta.text, '嗯');
      expect(delta.displayText, '嗯');

      final done = ContractChatEvent.parse(
        'done',
        '{"text":"完整回复","requestId":"req_1","usage":{"promptTokens":0,"completionTokens":0,"totalTokens":0}}',
      );
      expect(done.isDone, isTrue);
      expect(done.text, '完整回复');
      expect(done.requestId, 'req_1');
      expect(done.usage?.totalTokens, 0);

      final error = ContractChatEvent.parse(
        'error',
        '{"code":"INSUFFICIENT_CREDITS","message":"积分不足","requestId":"req_1"}',
      );
      expect(error.isError, isTrue);
      expect(error.code, 'INSUFFICIENT_CREDITS');
      expect(error.message, '积分不足');

      final meta = ContractChatEvent.parse(
        'meta',
        '{"requestId":"req_1","sessionId":"sess_1","turnId":null}',
      );
      expect(meta.isMeta, isTrue);
      expect(meta.sessionId, 'sess_1');
      expect(meta.turnId, isNull);

      final tool = ContractChatEvent.parse(
        'tool',
        '{"callId":"call_1","tool":"life","preview":"..."}',
      );
      expect(tool.isTool, isTrue);
      expect(tool.tool, 'life');
      expect(tool.preview, '...');
    });

    test('legacy raw strings still parse during migration', () {
      final delta = ContractChatEvent.parse('delta', '嗯');
      expect(delta.text, '嗯');
      expect(delta.rawData, '嗯');

      final done = ContractChatEvent.parse('done', '完整回复');
      expect(done.text, '完整回复');

      final error = ContractChatEvent.parse('error', '上游失败');
      expect(error.message, '上游失败');
      expect(error.displayText, '上游失败');
    });

    test('unknown JSON events keep raw payload', () {
      final event = ContractChatEvent.parse('approval', '{"id":"a1"}');
      expect(event.event, 'approval');
      expect(event.text, isNull);
      expect(event.rawData, '{"id":"a1"}');
    });
  });

  group('Auth', () {
    test(
      'login accepts contract shape and legacy missing companion/expiresIn',
      () {
        final full = AuthSession.fromJson({
          'accessToken': 'jwt...',
          'expiresIn': 604800,
          'account': {'id': 'acc_123', 'email': 'demo@benben.local'},
          'companion': {'id': 'cmp_123', 'displayName': '笨笨'},
        });
        expect(full.accessToken, 'jwt...');
        expect(full.expiresIn, 604800);
        expect(full.account.id, 'acc_123');
        expect(full.companion?.displayName, '笨笨');

        final legacy = AuthSession.fromJson({
          'accessToken': 'jwt...',
          'account': {'id': 'acc_123', 'email': 'demo@benben.local'},
        });
        expect(legacy.expiresIn, isNull);
        expect(legacy.companion, isNull);
      },
    );

    test('auth/me accepts both account wrapper and legacy flat shape', () {
      final contract = AuthMe.fromJson({
        'account': {
          'id': 'acc_123',
          'email': 'demo@benben.local',
          'status': 'active',
        },
        'companion': {
          'id': 'cmp_123',
          'displayName': '笨笨',
          'version': 3,
          'profile': <String, dynamic>{},
          'syncStatus': 'pending',
        },
      });
      expect(contract.account.email, 'demo@benben.local');
      expect(contract.companion?.version, 3);
      expect(contract.companion?.syncStatus, 'pending');

      final legacy = AuthMe.fromJson({
        'id': 'acc_123',
        'email': 'demo@benben.local',
        'status': 'active',
        'companion': {'id': 'cmp_123', 'displayName': '笨笨'},
      });
      expect(legacy.account.id, 'acc_123');
      expect(legacy.account.status, 'active');
      expect(legacy.companion?.displayName, '笨笨');
    });
  });
}
