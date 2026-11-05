import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../contract/companion_state.dart';
import '../contract/diary.dart';
import '../contract/moment.dart';

/// 全局唯一的 ApiClient；登录态由 AuthController 写入 token。
final apiProvider = Provider<ApiClient>((ref) => ApiClient());

/// GET /companion/state：Today / Profile / 平板场景共用。
final companionStateProvider = FutureProvider.autoDispose<CompanionState>(
  (ref) => ref.read(apiProvider).state(),
);

/// GET /companion/moments：朋友圈列表。
final momentsProvider = FutureProvider.autoDispose<MomentsPage>(
  (ref) => ref.read(apiProvider).moments(),
);

/// GET /companion/diary：日记列表（空列表是合法状态）。
final diaryProvider = FutureProvider.autoDispose<DiaryPage>(
  (ref) => ref.read(apiProvider).diary(),
);

final creditsProvider = FutureProvider.autoDispose<CreditBalance>(
  (ref) => ref.read(apiProvider).credits(),
);
