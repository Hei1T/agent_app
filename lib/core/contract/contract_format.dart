/// 契约时间 / 展示格式工具。
///
/// 契约要求 App 保存后端返回的 RFC3339 字符串，展示时才格式化。
/// 这里按 ISO 字符串里的字面日期时间取，避免设备时区把 Asia/Shanghai 写歪。
library;

const _weekdayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');
final _clockPattern = RegExp(r'T(\d{2}):(\d{2})');

/// '2026-11-04T...' -> '11月4日'；无法解析时原样返回（如后端给 '第 5 天'）。
String? contractDateLabel(String? value) {
  if (value == null || value.isEmpty) return null;
  final match = _datePattern.firstMatch(value);
  if (match == null) return value;
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  return '$month月$day日';
}

/// '2026-11-04T...' -> '周三'。
String? contractWeekdayLabel(String? value) {
  final date = contractDate(value);
  if (date == null) return null;
  return _weekdayLabels[date.weekday - 1];
}

/// '2026-11-04T15:32:00+08:00' -> '15:32'（展示用，不做时区换算）。
String? contractClockLabel(String? value) {
  if (value == null || value.isEmpty) return null;
  final match = _clockPattern.firstMatch(value);
  if (match == null) return null;
  return '${match.group(1)}:${match.group(2)}';
}

/// 仅用于展示的日期对象（年/月/日按后端字符串字面值）。
DateTime? contractDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final match = _datePattern.firstMatch(value);
  if (match == null) return null;
  return DateTime.utc(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

String? contractTemperatureLabel(double? celsius) {
  if (celsius == null) return null;
  final text = celsius == celsius.roundToDouble()
      ? celsius.toStringAsFixed(0)
      : celsius.toStringAsFixed(1);
  return '$text°C';
}

/// 0..1 -> '72%'。
String? contractPercentLabel(double? unit) {
  if (unit == null) return null;
  return '${(unit * 100).round()}%';
}

/// 日记正文按空行拆段；没有正文时返回空列表。
List<String> contractParagraphs(String? text) {
  if (text == null || text.trim().isEmpty) return const [];
  return [
    for (final part in text.split(RegExp(r'\n\s*\n')))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}
