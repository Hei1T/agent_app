import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/moment.dart';

/// Shell 内第二层：朋友圈详情弹窗。
final momentOverlayProvider = StateProvider<Moment?>((ref) => null);

/// 列表与详情共享的点赞状态。
final likedMomentsProvider = StateProvider<Set<String>>((ref) => <String>{});

/// 列表与详情共享的留言。
final momentCommentsProvider = StateProvider<Map<String, List<MomentComment>>>((ref) => {});
