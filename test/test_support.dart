import 'package:benben_app/app.dart';
import 'package:benben_app/core/api/api_client.dart';
import 'package:benben_app/core/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApiClient extends ApiClient {
  @override
  Future<LifeSnapshot> life() async => const LifeSnapshot(
    available: true,
    place: '旧书店',
    condition: '',
    energy: 0.72,
    mood: 0.61,
    satiety: 0.45,
    social: 0.7,
    awake: true,
    transit: null,
    clock: '11月2日 周日',
    weather: '小雪',
    day: '2026-11-02',
    events: [LifeEvent(time: '15:32', detail: '把晒了一下午的旧书收回来。', feeling: '安静')],
    people: [LifePerson(name: '林叔', role: '旧书店掌柜', note: '今天见过', place: '旧书店')],
    items: [],
    diary: null,
  );

  @override
  Future<List<RemoteMoment>> feed() async => const [];

  @override
  Future<CreditBalance> credits() async =>
      const CreditBalance(balance: 5, reserved: 0, available: 5);
}

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

Future<void> pumpBenben(WidgetTester tester) async {
  final api = FakeApiClient();
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
