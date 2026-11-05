import 'contract_json.dart';

/// GET /companion/diary -> items[]（v1 扩展，TODO(app-contract) 后端未定型）。
class DiaryEntry {
  const DiaryEntry({this.id, this.day, this.text = '', this.createdAt});

  /// 契约扩展暂未给出 id；后端补齐前允许 null。
  final String? id;

  /// 后端可能给 RFC3339 日期，也可能给展示文案（如「第 5 天」）。
  final String? day;
  final String text;

  /// RFC3339 字符串，按契约原样保存。
  final String? createdAt;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: contractId(json['id']),
    day: contractString(json['day']),
    text: contractStringOr(json['text'], ''),
    createdAt: contractString(json['createdAt']),
  );
}

/// GET /companion/diary 列表响应。空日记是合法状态（items: []）。
class DiaryPage {
  const DiaryPage({this.items = const [], this.nextCursor});

  final List<DiaryEntry> items;

  /// 不透明游标，App 不拆解。
  final String? nextCursor;

  factory DiaryPage.fromJson(Map<String, dynamic> json) => DiaryPage(
    items: [
      for (final item in contractMapList(json['items']))
        DiaryEntry.fromJson(item),
    ],
    nextCursor: contractString(json['nextCursor']),
  );
}
