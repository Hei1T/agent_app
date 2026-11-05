/// 防御式 JSON 读取工具，供 API Contract v1 DTO 共用。
///
/// 契约保证 camelCase、id 为字符串；这里的兜底只用于「后端尚未完全上线」
/// 的过渡期，避免整页崩掉。它不会编造业务数据：缺字段就返回 null / 空。
library;

Map<String, dynamic>? contractMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, item) => MapEntry(key.toString(), item));
}

List<Map<String, dynamic>> contractMapList(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map)
        item.map((key, value) => MapEntry(key.toString(), value)),
  ];
}

String? contractString(Object? value) {
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

String contractStringOr(Object? value, String fallback) =>
    contractString(value) ?? fallback;

/// 契约要求 id 全为字符串。旧 core 可能给数字 id，这里只做类型收敛，不解析格式。
String? contractId(Object? value) => contractString(value);

int? contractInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? contractDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool? contractBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value == 'true') return true;
    if (value == 'false') return false;
  }
  return null;
}

/// 0..1 的比例字段（energy / mood / satiety / social）。
double? contractUnit(Object? value) {
  final parsed = contractDouble(value);
  if (parsed == null) return null;
  return parsed.clamp(0, 1).toDouble();
}
