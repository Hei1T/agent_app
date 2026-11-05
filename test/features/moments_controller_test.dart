import 'package:benben_app/core/api/api_client.dart';
import 'package:benben_app/core/contract/moment.dart';
import 'package:benben_app/core/network/api_exception.dart';
import 'package:benben_app/features/moments/presentation/moments_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApi extends ApiClient {
  _FakeApi({this.failLike = false, this.failComment = false});

  bool failLike;
  bool failComment;
  int likeCalls = 0;
  int commentCalls = 0;

  @override
  Future<MomentLikeResult> likeMoment(String momentId) async {
    likeCalls += 1;
    if (failLike) throw const ApiException(500, 'like failed');
    return const MomentLikeResult(liked: true, likeCount: 4);
  }

  @override
  Future<MomentComment> addComment(String momentId, String text) async {
    commentCalls += 1;
    if (failComment) throw const ApiException(500, 'comment failed');
    return MomentComment(
      id: 'comment_server',
      author: const MomentAuthor(type: 'player', name: '你'),
      text: text,
      timeLabel: '15:40',
    );
  }
}

Moment _moment() => Moment.fromJson({
  'id': 'post_1',
  'author': {'type': 'companion', 'name': '笨笨'},
  'timeLabel': '15:32',
  'text': '今天把后院的旧书搬出来晒。',
  'likes': [
    {'actorType': 'npc', 'name': '林叔'},
    {'actorType': 'npc', 'name': '张姨'},
    {'actorType': 'npc', 'name': '老赵'},
  ],
  'comments': [
    {
      'id': 'comment_1',
      'author': {'type': 'npc', 'name': '林叔'},
      'text': '晒书记得翻面。',
      'timeLabel': '15:40',
    },
  ],
});

void main() {
  test('like succeeds and adopts server likeCount', () async {
    final api = _FakeApi();
    final controller = MomentsController(api);
    final moment = _moment();
    expect(controller.isLiked(moment), isFalse);
    expect(controller.likeCount(moment), 3);

    final ok = await controller.toggleLike(moment);
    expect(ok, isTrue);
    expect(api.likeCalls, 1);
    expect(controller.isLiked(moment), isTrue);
    expect(controller.likeCount(moment), 4);
  });

  test('like failure rolls back optimistic state', () async {
    final api = _FakeApi(failLike: true);
    final controller = MomentsController(api);
    final moment = _moment();

    final ok = await controller.toggleLike(moment);
    expect(ok, isFalse);
    expect(controller.isLiked(moment), isFalse);
    expect(controller.likeCount(moment), 3);
  });

  test('comment succeeds and replaces the optimistic comment', () async {
    final api = _FakeApi();
    final controller = MomentsController(api);
    final moment = _moment();

    final saved = await controller.addComment(moment, '我下午带个灯泡过去。');
    expect(saved?.id, 'comment_server');
    final comments = controller.commentsFor(moment);
    expect(comments, hasLength(2));
    expect(comments.last.id, 'comment_server');
    expect(comments.last.text, '我下午带个灯泡过去。');
  });

  test('comment failure removes the optimistic comment', () async {
    final api = _FakeApi(failComment: true);
    final controller = MomentsController(api);
    final moment = _moment();

    final saved = await controller.addComment(moment, '发不出去');
    expect(saved, isNull);
    expect(controller.commentsFor(moment), hasLength(1));
  });

  test('empty comment is ignored', () async {
    final api = _FakeApi();
    final controller = MomentsController(api);
    final moment = _moment();
    expect(await controller.addComment(moment, '   '), isNull);
    expect(api.commentCalls, 0);
  });
}
