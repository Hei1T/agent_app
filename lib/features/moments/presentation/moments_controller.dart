import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/contract/moment.dart';
import '../../../core/providers/app_providers.dart';

/// 单条动态的本地覆盖：点赞 / 留言先乐观更新，失败回滚到 [before]。
class MomentInteraction {
  const MomentInteraction({
    this.liked,
    this.likeCount,
    this.comments = const [],
  });

  final bool? liked;
  final int? likeCount;
  final List<MomentComment> comments;

  bool get isEmpty => liked == null && likeCount == null && comments.isEmpty;

  MomentInteraction copyWith({
    bool? liked,
    int? likeCount,
    List<MomentComment>? comments,
  }) {
    return MomentInteraction(
      liked: liked ?? this.liked,
      likeCount: likeCount ?? this.likeCount,
      comments: comments ?? this.comments,
    );
  }
}

class MomentsInteractionState {
  const MomentsInteractionState({this.overrides = const {}});

  final Map<String, MomentInteraction> overrides;

  MomentInteraction of(String momentId) =>
      overrides[momentId] ?? const MomentInteraction();
}

/// 点赞 / 留言的状态机。
///
/// 服务端有接口就优先走后端；失败回滚并返回 false，由页面提示用户。
class MomentsController extends StateNotifier<MomentsInteractionState> {
  MomentsController(this._api) : super(const MomentsInteractionState());

  final ApiClient _api;

  bool isLiked(Moment moment) =>
      state.of(moment.id).liked ?? _serverLiked(moment);

  int likeCount(Moment moment) =>
      state.of(moment.id).likeCount ?? moment.likes.length;

  List<MomentComment> commentsFor(Moment moment) => [
    ...moment.comments,
    ...state.of(moment.id).comments,
  ];

  Future<bool> toggleLike(Moment moment) async {
    final before = state.of(moment.id);
    final desired = !isLiked(moment);
    final nextCount = (likeCount(moment) + (desired ? 1 : -1))
        .clamp(0, 1 << 31)
        .toInt();
    _write(moment.id, before.copyWith(liked: desired, likeCount: nextCount));
    try {
      final result = await _api.likeMoment(moment.id);
      final current = state.of(moment.id);
      // likeCount 可能还没补齐（null），此时保留本地计数。
      _write(
        moment.id,
        current.copyWith(liked: result.liked, likeCount: result.likeCount),
      );
      return true;
    } catch (_) {
      _restore(moment.id, before);
      return false;
    }
  }

  Future<MomentComment?> addComment(Moment moment, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final before = state.of(moment.id);
    final temp = MomentComment(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      author: const MomentAuthor(type: 'player', name: '你'),
      text: trimmed,
      timeLabel: '刚刚',
    );
    _write(moment.id, before.copyWith(comments: [...before.comments, temp]));
    try {
      final saved = await _api.addComment(moment.id, trimmed);
      final current = state.of(moment.id);
      _write(
        moment.id,
        current.copyWith(
          comments: [
            for (final comment in current.comments)
              if (comment.id == temp.id) saved else comment,
          ],
        ),
      );
      return saved;
    } catch (_) {
      final current = state.of(moment.id);
      _write(
        moment.id,
        current.copyWith(
          comments: [
            for (final comment in current.comments)
              if (comment.id != temp.id) comment,
          ],
        ),
      );
      return null;
    }
  }

  bool _serverLiked(Moment moment) =>
      moment.likes.any((like) => like.actorType == 'player');

  void _write(String momentId, MomentInteraction interaction) {
    state = MomentsInteractionState(
      overrides: {...state.overrides, momentId: interaction},
    );
  }

  void _restore(String momentId, MomentInteraction before) {
    if (before.isEmpty) {
      final next = {...state.overrides}..remove(momentId);
      state = MomentsInteractionState(overrides: next);
      return;
    }
    _write(momentId, before);
  }
}

final momentsControllerProvider =
    StateNotifierProvider.autoDispose<
      MomentsController,
      MomentsInteractionState
    >((ref) => MomentsController(ref.read(apiProvider)));
