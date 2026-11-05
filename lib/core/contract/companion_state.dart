import 'contract_json.dart';

/// GET /companion/state -> companion.place。
class CompanionPlace {
  const CompanionPlace({required this.name, this.id});

  /// 契约：id 可为空，name 必须有。
  final String name;
  final String? id;

  factory CompanionPlace.fromJson(Map<String, dynamic> json) => CompanionPlace(
    name: contractStringOr(json['name'], ''),
    id: contractId(json['id']),
  );
}

/// GET /companion/state -> companion.transit。
class CompanionTransit {
  const CompanionTransit({this.from, this.to, this.etaMinutes});

  final String? from;
  final String? to;
  final int? etaMinutes;

  factory CompanionTransit.fromJson(Map<String, dynamic> json) =>
      CompanionTransit(
        from: contractString(json['from']),
        to: contractString(json['to']),
        etaMinutes: contractInt(json['etaMinutes']),
      );
}

/// GET /companion/state -> companion。
class CompanionProfile {
  const CompanionProfile({
    required this.id,
    required this.displayName,
    this.day,
    this.place,
    this.status,
    this.condition = '',
    this.awake = true,
    this.energy,
    this.mood,
    this.satiety,
    this.social,
    this.transit,
    this.lastActiveAt,
    this.version,
    this.profile,
    this.syncStatus,
  });

  final String id;
  final String displayName;
  final int? day;
  final CompanionPlace? place;

  /// awake / asleep / transiting / busy / quiet。
  final String? status;
  final String condition;
  final bool awake;
  final double? energy;
  final double? mood;
  final double? satiety;
  final double? social;
  final CompanionTransit? transit;

  /// RFC3339 字符串，按契约原样保存。
  final String? lastActiveAt;
  final int? version;
  final Map<String, dynamic>? profile;
  final String? syncStatus;

  factory CompanionProfile.fromJson(Map<String, dynamic> json) {
    final status = contractString(json['status']);
    final placeJson = contractMap(json['place']);
    final transitJson = contractMap(json['transit']);
    return CompanionProfile(
      id: contractId(json['id']) ?? '',
      displayName: contractStringOr(json['displayName'], ''),
      day: contractInt(json['day']),
      place: placeJson == null ? null : CompanionPlace.fromJson(placeJson),
      status: status,
      condition: contractStringOr(json['condition'], ''),
      // 契约保证 awake；缺字段时由 status 推导，不凭空假设。
      awake: contractBool(json['awake']) ?? status == 'awake',
      energy: contractUnit(json['energy']),
      mood: contractUnit(json['mood']),
      satiety: contractUnit(json['satiety']),
      social: contractUnit(json['social']),
      transit: transitJson == null
          ? null
          : CompanionTransit.fromJson(transitJson),
      lastActiveAt: contractString(json['lastActiveAt']),
      version: contractInt(json['version']),
      profile: contractMap(json['profile']),
      syncStatus: contractString(json['syncStatus']),
    );
  }
}

/// GET /companion/state -> world。
class CompanionWorld {
  const CompanionWorld({
    this.available = false,
    this.clockLabel,
    this.weather,
    this.temperatureC,
    this.season,
    this.dayOfWeek,
  });

  final bool available;
  final String? clockLabel;
  final String? weather;
  final double? temperatureC;
  final String? season;
  final int? dayOfWeek;

  factory CompanionWorld.fromJson(Map<String, dynamic> json) => CompanionWorld(
    available: contractBool(json['available']) ?? false,
    clockLabel: contractString(json['clockLabel']),
    weather: contractString(json['weather']),
    temperatureC: contractDouble(json['temperatureC']),
    season: contractString(json['season']),
    dayOfWeek: contractInt(json['dayOfWeek']),
  );
}

/// GET /companion/state -> events[]。
class CompanionEvent {
  const CompanionEvent({
    this.id,
    this.occurredAt,
    this.timeLabel,
    this.title = '',
    this.detail = '',
    this.feeling = '',
    this.sourceEventId,
  });

  final String? id;

  /// RFC3339 字符串；展示用 timeLabel，业务判断用 occurredAt。
  final String? occurredAt;
  final String? timeLabel;
  final String title;
  final String detail;
  final String feeling;
  final String? sourceEventId;

  factory CompanionEvent.fromJson(Map<String, dynamic> json) => CompanionEvent(
    id: contractId(json['id']),
    occurredAt: contractString(json['occurredAt']),
    timeLabel: contractString(json['timeLabel']),
    title: contractStringOr(json['title'], ''),
    detail: contractStringOr(json['detail'], ''),
    feeling: contractStringOr(json['feeling'], ''),
    sourceEventId: contractString(json['sourceEventId']),
  );
}

/// GET /companion/state -> people[]。
class CompanionPerson {
  const CompanionPerson({
    this.id,
    this.name = '',
    this.role = '',
    this.note = '',
    this.place,
    this.lastSeenDay,
  });

  final String? id;
  final String name;
  final String role;
  final String note;
  final String? place;
  final String? lastSeenDay;

  factory CompanionPerson.fromJson(Map<String, dynamic> json) =>
      CompanionPerson(
        id: contractId(json['id']),
        name: contractStringOr(json['name'], ''),
        role: contractStringOr(json['role'], ''),
        note: contractStringOr(json['note'], ''),
        place: contractString(json['place']),
        lastSeenDay: contractString(json['lastSeenDay']),
      );
}

/// GET /companion/state -> items[]。
class CompanionItem {
  const CompanionItem({
    this.id,
    this.kind,
    this.name = '',
    this.note = '',
    this.place,
  });

  final String? id;
  final String? kind;
  final String name;
  final String note;
  final String? place;

  factory CompanionItem.fromJson(Map<String, dynamic> json) => CompanionItem(
    id: contractId(json['id']),
    kind: contractString(json['kind']),
    name: contractStringOr(json['name'], ''),
    note: contractStringOr(json['note'], ''),
    place: contractString(json['place']),
  );
}

/// GET /companion/state -> diary（可为 null）。
class CompanionDiary {
  const CompanionDiary({this.day, this.text});

  final String? day;
  final String? text;

  factory CompanionDiary.fromJson(Map<String, dynamic> json) => CompanionDiary(
    day: contractString(json['day']),
    text: contractString(json['text']),
  );
}

/// GET /companion/state 契约响应。
class CompanionState {
  const CompanionState({
    required this.companion,
    required this.world,
    this.contractVersion,
    this.events = const [],
    this.people = const [],
    this.items = const [],
    this.diary,
  });

  final int? contractVersion;
  final CompanionProfile companion;
  final CompanionWorld world;
  final List<CompanionEvent> events;
  final List<CompanionPerson> people;
  final List<CompanionItem> items;
  final CompanionDiary? diary;

  factory CompanionState.fromJson(Map<String, dynamic> json) {
    final companionJson = contractMap(json['companion']);
    final worldJson = contractMap(json['world']);
    final diaryJson = contractMap(json['diary']);
    return CompanionState(
      contractVersion: contractInt(json['contractVersion']),
      companion: CompanionProfile.fromJson(
        companionJson ?? const <String, dynamic>{},
      ),
      world: CompanionWorld.fromJson(worldJson ?? const <String, dynamic>{}),
      events: [
        for (final item in contractMapList(json['events']))
          CompanionEvent.fromJson(item),
      ],
      people: [
        for (final item in contractMapList(json['people']))
          CompanionPerson.fromJson(item),
      ],
      items: [
        for (final item in contractMapList(json['items']))
          CompanionItem.fromJson(item),
      ],
      diary: diaryJson == null ? null : CompanionDiary.fromJson(diaryJson),
    );
  }
}
