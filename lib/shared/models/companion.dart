/// Today / Profile / 平板场景共用的展示模型。
///
/// 由 CompanionState 映射而来（见 features/today/data/companion_state_mapper.dart），
/// 页面不再直接解析 /core 原始字段。
class Companion {
  const Companion({
    required this.name,
    required this.day,
    required this.place,
    required this.action,
    required this.weather,
    required this.temperature,
    required this.energy,
    required this.mood,
    required this.satiety,
    required this.awake,
    required this.lastSeen,
    this.quote = '',
    this.quoteMeta = '',
  });

  final String name;

  /// 契约 companion.day；后端未给时为 null。
  final int? day;
  final String place;

  /// 状态文案（醒着 / 睡着 / 在路上 ...）。
  final String action;
  final String weather;
  final String temperature;

  /// 0..100；契约缺字段时为 null，UI 显示「—」。
  final int? energy;

  /// 心情展示值（契约只给 0..1，展示时转成百分比）。
  final String mood;

  /// 0..100；契约缺字段时为 null。
  final int? satiety;
  final bool awake;

  /// world.clockLabel。
  final String lastSeen;

  /// 最新事件 detail，仅用于展示；没有事件时为空。
  final String quote;
  final String quoteMeta;
}
