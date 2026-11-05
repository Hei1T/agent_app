import 'contract_json.dart';

/// moments[].author / comments[].author。
class MomentAuthor {
  const MomentAuthor({this.type = '', this.name = '', this.id});

  /// companion / player / npc。
  final String type;
  final String name;
  final String? id;

  factory MomentAuthor.fromJson(Map<String, dynamic> json) => MomentAuthor(
    type: contractStringOr(json['type'], ''),
    name: contractStringOr(json['name'], ''),
    id: contractId(json['id']),
  );
}

/// moments[].photos[]。
class MomentPhoto {
  const MomentPhoto({required this.url, this.width, this.height, this.alt});

  /// 契约要求为后端可访问的业务 URL。
  final String url;
  final int? width;
  final int? height;
  final String? alt;

  factory MomentPhoto.fromJson(Map<String, dynamic> json) => MomentPhoto(
    url: contractStringOr(json['url'], ''),
    width: contractInt(json['width']),
    height: contractInt(json['height']),
    alt: contractString(json['alt']),
  );
}

/// moments[].likes[]。
class MomentLike {
  const MomentLike({this.actorType = '', this.name});

  final String actorType;
  final String? name;

  factory MomentLike.fromJson(Map<String, dynamic> json) => MomentLike(
    actorType: contractStringOr(json['actorType'], ''),
    name: contractString(json['name']),
  );
}

/// moments[].comments[] 与 POST .../comments 响应。
class MomentComment {
  const MomentComment({
    this.id,
    this.author = const MomentAuthor(),
    this.text = '',
    this.createdAt,
    this.timeLabel,
  });

  final String? id;
  final MomentAuthor author;
  final String text;

  /// RFC3339 字符串，按契约原样保存。
  final String? createdAt;
  final String? timeLabel;

  factory MomentComment.fromJson(Map<String, dynamic> json) => MomentComment(
    id: contractId(json['id']),
    author: MomentAuthor.fromJson(
      contractMap(json['author']) ?? const <String, dynamic>{},
    ),
    text: contractStringOr(json['text'], ''),
    createdAt: contractString(json['createdAt']),
    timeLabel: contractString(json['timeLabel']),
  );
}

/// GET /companion/moments -> items[]。
class Moment {
  const Moment({
    required this.id,
    this.author = const MomentAuthor(),
    this.createdAt,
    this.timeLabel,
    this.place,
    this.text = '',
    this.photos = const [],
    this.likes = const [],
    this.comments = const [],
    this.visibility,
    this.sourceEventId,
  });

  final String id;
  final MomentAuthor author;
  final String? createdAt;
  final String? timeLabel;
  final String? place;
  final String text;
  final List<MomentPhoto> photos;
  final List<MomentLike> likes;
  final List<MomentComment> comments;

  /// public / player_only / self_only。
  final String? visibility;
  final String? sourceEventId;

  factory Moment.fromJson(Map<String, dynamic> json) => Moment(
    id: contractId(json['id']) ?? '',
    author: MomentAuthor.fromJson(
      contractMap(json['author']) ?? const <String, dynamic>{},
    ),
    createdAt: contractString(json['createdAt']),
    timeLabel: contractString(json['timeLabel']),
    place: contractString(json['place']),
    text: contractStringOr(json['text'], ''),
    photos: [
      for (final item in contractMapList(json['photos']))
        MomentPhoto.fromJson(item),
    ],
    likes: [
      for (final item in contractMapList(json['likes']))
        MomentLike.fromJson(item),
    ],
    comments: [
      for (final item in contractMapList(json['comments']))
        MomentComment.fromJson(item),
    ],
    visibility: contractString(json['visibility']),
    sourceEventId: contractString(json['sourceEventId']),
  );

  /// 列表页使用的展示时间，优先 timeLabel，其次从 createdAt 取。
  String get displayTimeLabel => timeLabel ?? _clockFrom(createdAt) ?? '';
}

String? _clockFrom(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final match = RegExp(r'T(\d{2}):(\d{2})').firstMatch(iso);
  if (match == null) return null;
  return '${match.group(1)}:${match.group(2)}';
}

/// GET /companion/moments 列表响应。
class MomentsPage {
  const MomentsPage({this.items = const [], this.nextCursor});

  final List<Moment> items;

  /// 不透明游标，App 不拆解；null 表示没有下一页。
  final String? nextCursor;

  factory MomentsPage.fromJson(Map<String, dynamic> json) => MomentsPage(
    items: [
      for (final item in contractMapList(json['items'])) Moment.fromJson(item),
    ],
    nextCursor: contractString(json['nextCursor']),
  );
}

/// POST /companion/moments/:id/like 响应（v1 扩展）。
class MomentLikeResult {
  const MomentLikeResult({required this.liked, this.likeCount});

  final bool liked;

  /// 后端未补齐时可为 null，UI 用本地计数兜底。
  final int? likeCount;

  factory MomentLikeResult.fromJson(Map<String, dynamic> json) =>
      MomentLikeResult(
        liked: contractBool(json['liked']) ?? false,
        likeCount: contractInt(json['likeCount']),
      );
}
