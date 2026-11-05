import '../../../core/contract/companion_state.dart';
import '../../../core/contract/contract_format.dart';
import '../../../shared/models/companion.dart';
import '../domain/entities/today_entities.dart';

/// GET /companion/state -> Today 页面展示模型。
///
/// 页面只依赖这里的映射结果，不直接读 world.weather / events[].clock_min
/// 等 core 原始字段。

String todaySubtitle(CompanionState? state) {
  if (state == null) return '正在连到栖湾…';
  if (!state.world.available) return '他的世界暂时没连上';
  final clock = state.world.clockLabel ?? '';
  final weather = state.world.weather ?? '';
  final parts = [clock, weather].where((part) => part.isNotEmpty);
  return parts.isEmpty ? '栖湾' : parts.join(' · ');
}

Companion companionOf(CompanionState state) {
  final companion = state.companion;
  final world = state.world;
  final latest = state.events.isEmpty ? null : state.events.first;
  return Companion(
    name: companion.displayName,
    day: companion.day,
    place: companion.place?.name ?? '',
    action: companionStatusLabel(companion.status, transit: companion.transit),
    weather: world.weather ?? '',
    temperature: contractTemperatureLabel(world.temperatureC) ?? '',
    energy: _percent(companion.energy),
    mood:
        contractPercentLabel(companion.mood) ??
        companionStatusLabel(companion.status, transit: companion.transit),
    satiety: _percent(companion.satiety),
    awake: companion.awake,
    lastSeen:
        world.clockLabel ?? contractClockLabel(companion.lastActiveAt) ?? '',
    quote: latest?.detail ?? '',
    quoteMeta: _quoteMeta(latest, companion.place?.name ?? ''),
  );
}

/// 事件 -> 时间线。契约事件没有照片 / 未读字段，这里留空，不编造。
List<TimelineEntry> timelineOf(CompanionState state) {
  final name = state.companion.displayName;
  return [
    for (var i = 0; i < state.events.length; i++)
      TimelineEntry(
        // TODO(app-contract): core 事件 id 由后端 mapper 补齐；缺省时用序号兜底。
        id: state.events[i].id ?? 'event-$i',
        time:
            state.events[i].timeLabel ??
            contractClockLabel(state.events[i].occurredAt) ??
            '',
        title: _timelineTitle(
          name,
          state.events[i].title.isEmpty
              ? state.events[i].feeling
              : state.events[i].title,
        ),
        detail: state.events[i].detail,
        feeling: state.events[i].feeling,
      ),
  ];
}

/// 契约枚举 -> 中文展示文案。未知枚举原样返回（契约允许加字段/加枚举）。
String companionStatusLabel(String? status, {CompanionTransit? transit}) {
  if (transit != null) return '在路上';
  return switch (status) {
    'awake' => '醒着',
    'asleep' => '睡着',
    'transiting' => '在路上',
    'busy' => '忙着',
    'quiet' => '安静',
    null || '' => '',
    _ => status,
  };
}

String _timelineTitle(String name, String label) {
  if (label.isEmpty) return name;
  if (name.isEmpty) return label;
  return '$name · $label';
}

/// 行程描述：transit 为 null 时返回空。
String transitLabel(CompanionTransit? transit) {
  if (transit == null) return '';
  final from = transit.from ?? '';
  final to = transit.to ?? '';
  final eta = transit.etaMinutes;
  final route = [from, to].where((part) => part.isNotEmpty).join(' → ');
  if (route.isEmpty) return '在路上';
  return eta == null ? route : '$route · 还有 $eta 分钟';
}

int? _percent(double? unit) => unit == null ? null : (unit * 100).round();

String _quoteMeta(CompanionEvent? event, String place) {
  if (event == null) return '';
  final time = event.timeLabel ?? contractClockLabel(event.occurredAt) ?? '';
  final parts = [time, place].where((part) => part.isNotEmpty);
  return parts.join(' · ');
}
