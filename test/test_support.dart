import 'package:benben_app/app.dart';
import 'package:benben_app/core/api/api_client.dart';
import 'package:benben_app/core/auth/auth_controller.dart';
import 'package:benben_app/core/contract/auth_contract.dart';
import 'package:benben_app/core/contract/companion_state.dart';
import 'package:benben_app/core/contract/diary.dart';
import 'package:benben_app/core/contract/moment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 测试用 ApiClient：只提供契约对象，不发起请求。
class FakeApiClient extends ApiClient {
  FakeApiClient({
    this.stateJson = fakeStateJson,
    this.momentsPage,
    this.diaryPage,
  });

  final Map<String, dynamic> stateJson;
  final MomentsPage? momentsPage;
  final DiaryPage? diaryPage;

  @override
  Future<CompanionState> state() async => CompanionState.fromJson(stateJson);

  @override
  Future<MomentsPage> moments({int limit = 20, String? cursor}) async =>
      momentsPage ?? const MomentsPage();

  @override
  Future<DiaryPage> diary({int limit = 30, String? cursor}) async =>
      diaryPage ?? const DiaryPage();

  @override
  Future<CreditBalance> credits() async =>
      const CreditBalance(balance: 5, reserved: 0, available: 5);

  @override
  Future<AuthMe> me() async => AuthMe.fromJson({
    'account': {
      'id': 'acc_1',
      'email': 'demo@benben.local',
      'status': 'active',
    },
    'companion': {'id': 'cmp_1', 'displayName': '笨笨'},
  });
}

const fakeStateJson = <String, dynamic>{
  'contractVersion': 1,
  'companion': {
    'id': 'cmp_123',
    'displayName': '笨笨',
    'day': 5,
    'place': {'id': 'bookstore', 'name': '旧书店'},
    'status': 'awake',
    'condition': '',
    'awake': true,
    'energy': 0.72,
    'mood': 0.61,
    'satiety': 0.45,
    'social': 0.7,
    'transit': null,
    'lastActiveAt': '2026-11-02T15:32:00+08:00',
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
      'occurredAt': '2026-11-02T15:32:00+08:00',
      'timeLabel': '15:32',
      'title': '收书',
      'detail': '把晒了一下午的旧书收回来。',
      'feeling': '安静',
      'sourceEventId': 'core_evt_1',
    },
  ],
  'people': [
    {
      'id': 'npc_lin',
      'name': '林叔',
      'role': '旧书店掌柜',
      'note': '今天见过',
      'place': '旧书店',
      'lastSeenDay': '2026-11-02',
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
};

class FakeAuthController extends AuthController {
  FakeAuthController(super.api)
    : super(
        initial: const AuthState(
          loading: false,
          token: 'test-token',
          email: 'demo@benben.local',
        ),
        restore: false,
      );
}

Future<void> pumpBenben(WidgetTester tester, {FakeApiClient? apiClient}) async {
  final api = apiClient ?? FakeApiClient();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiProvider.overrideWithValue(api),
        authProvider.overrideWith((ref) => FakeAuthController(api)),
      ],
      child: const BenbenApp(),
    ),
  );
  await tester.pumpAndSettle();
}
