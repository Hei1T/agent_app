import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../contract/auth_contract.dart';
import '../contract/chat_event.dart';
import '../contract/chat_history.dart';
import '../contract/companion_state.dart';
import '../contract/diary.dart';
import '../contract/moment.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import '../storage/token_storage.dart';

class CreditBalance {
  const CreditBalance({
    required this.balance,
    required this.reserved,
    required this.available,
    this.updatedAt,
  });

  final int balance;
  final int reserved;
  final int available;

  /// RFC3339 字符串；后端补齐前可为 null。
  final String? updatedAt;

  factory CreditBalance.fromJson(Map<String, dynamic> json) => CreditBalance(
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    reserved: (json['reserved'] as num?)?.toInt() ?? 0,
    available: (json['available'] as num?)?.toInt() ?? 0,
    updatedAt: json['updatedAt'] as String?,
  );
}

class ApiClient {
  ApiClient({this.token, TokenStorage? storage})
    : storage = storage ?? TokenStorage(),
      _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 120),
          headers: const {'X-Contract-Version': '1'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null && token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  String? token;
  final TokenStorage storage;
  final Dio _dio;

  /// 任何请求收到 401 时回调，由 AuthController 负责清 token 并回登录。
  void Function()? onUnauthorized;

  static String get baseUrl => ApiEndpoints.baseUrl;

  /// App 的媒体 URL：/media/... -> /api/v1/media/...
  String? resolveMediaUrl(String source) {
    if (source.startsWith('http')) return source;
    if (source.startsWith('/media/')) {
      return (StringBuffer()
            ..write(baseUrl)
            ..write(source))
          .toString();
    }
    return null;
  }

  Map<String, String>? get imageHeaders {
    final value = token;
    if (value == null || value.isEmpty) return null;
    return {'Authorization': 'Bearer $value'};
  }

  Map<String, dynamic> _data(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw const ApiException(500, '响应格式错误');
  }

  Never _fail(DioException error) {
    final status = error.response?.statusCode ?? 0;
    var message = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => '连接超时，请稍后再试',
      DioExceptionType.connectionError => '网络连接失败，请检查网络',
      _ => '请求失败',
    };
    String? code;
    String? requestId;
    final data = error.response?.data;
    if (data is Map) {
      message = data['message']?.toString() ?? message;
      code = data['code']?.toString();
      requestId = data['requestId']?.toString();
    }
    if (status == 401) onUnauthorized?.call();
    throw ApiException(status, message, code: code, requestId: requestId);
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return _data(await _dio.get<dynamic>(path, queryParameters: query));
    } on DioException catch (error) {
      _fail(error);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      return _data(await _dio.post<dynamic>(path, data: body));
    } on DioException catch (error) {
      _fail(error);
    }
  }

  Future<AuthSession> login(String email, String password) async {
    final data = await _post(ApiEndpoints.authLogin, {
      'email': email,
      'password': password,
    });
    final session = _sessionOrThrow(data);
    token = session.accessToken;
    return session;
  }

  Future<AuthSession> register(String email, String password) async {
    final data = await _post(ApiEndpoints.authRegister, {
      'email': email,
      'password': password,
    });
    final session = _sessionOrThrow(data);
    token = session.accessToken;
    return session;
  }

  AuthSession _sessionOrThrow(Map<String, dynamic> data) {
    final session = AuthSession.fromJson(data);
    if (session.accessToken.isEmpty) {
      throw const ApiException(502, '登录响应缺少 accessToken');
    }
    return session;
  }

  /// 启动时校验 token；401 会触发 [onUnauthorized]。
  Future<AuthMe> me() async => AuthMe.fromJson(await _get(ApiEndpoints.authMe));

  /// GET /companion/state，替代旧的 /core/life。
  Future<CompanionState> state() async =>
      CompanionState.fromJson(await _get(ApiEndpoints.companionState));

  /// GET /companion/moments，替代旧的 /core/life/feed。
  Future<MomentsPage> moments({int limit = 20, String? cursor}) async {
    final data = await _get(
      ApiEndpoints.companionMoments,
      query: {'limit': limit, 'cursor': ?cursor},
    );
    return MomentsPage.fromJson(data);
  }

  /// GET /companion/diary（v1 扩展）。
  Future<DiaryPage> diary({int limit = 30, String? cursor}) async {
    final data = await _get(
      ApiEndpoints.companionDiary,
      query: {'limit': limit, 'cursor': ?cursor},
    );
    return DiaryPage.fromJson(data);
  }

  /// POST /companion/moments/:id/like（v1 扩展）。
  Future<MomentLikeResult> likeMoment(String momentId) async {
    final data = await _post(
      ApiEndpoints.momentLike(momentId),
      const <String, dynamic>{},
    );
    return MomentLikeResult.fromJson(data);
  }

  /// POST /companion/moments/:id/comments（v1 扩展）。
  Future<MomentComment> addComment(String momentId, String text) async {
    final data = await _post(ApiEndpoints.momentComments(momentId), {
      'text': text,
    });
    return MomentComment.fromJson(data);
  }

  Future<CreditBalance> credits() async =>
      CreditBalance.fromJson(await _get(ApiEndpoints.creditsBalance));

  /// GET /chat/history：Conversation 初始化时加载真实历史。
  Future<ChatHistoryPage> chatHistory() async =>
      ChatHistoryPage.fromJson(await _get(ApiEndpoints.chatHistory));

  /// POST /chat，解析契约 SSE（JSON data），过渡期兼容旧 core 的裸字符串。
  Stream<ContractChatEvent> streamChat(
    String message, {
    String? clientMessageId,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      ApiEndpoints.chat,
      data: {'message': message, 'clientMessageId': ?clientMessageId},
      options: Options(
        responseType: ResponseType.stream,
        headers: const {'Accept': 'text/event-stream'},
        validateStatus: (status) => status != null,
      ),
    );
    final body = response.data;
    if (body == null) throw const ApiException(502, '上游没有返回流');
    if (response.statusCode != 200) {
      final text = await utf8.decoder.bind(body.stream).join();
      var messageText = '请求失败';
      String? code;
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map) {
          messageText = decoded['message']?.toString() ?? messageText;
          code = decoded['code']?.toString();
        }
      } catch (_) {
        // 非 JSON 错误体，保留默认文案。
      }
      if (response.statusCode == 401) onUnauthorized?.call();
      throw ApiException(response.statusCode ?? 0, messageText, code: code);
    }
    var event = '';
    final data = StringBuffer();
    await for (final line
        in utf8.decoder.bind(body.stream).transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (data.isNotEmpty) {
          yield ContractChatEvent.parse(event, data.toString());
        }
        event = '';
        data.clear();
        continue;
      }
      if (line.startsWith('event:')) event = line.substring(6).trim();
      if (line.startsWith('data:')) {
        if (data.isNotEmpty) data.write('\n');
        data.write(line.substring(5).trimLeft());
      }
    }
    if (data.isNotEmpty) {
      yield ContractChatEvent.parse(event, data.toString());
    }
  }
}

// ---------------------------------------------------------------------------
// 旧 core 透传 DTO：仅为过渡期兼容保留，App 新代码禁止使用。
// 契约 v1 迁移完成后（API_CONTRACT_V1.md §11）随旧 /core 路径一起删除。
// ---------------------------------------------------------------------------

@Deprecated('旧 core 透传结构；改用 CompanionState')
class LifeEvent {
  const LifeEvent({
    required this.time,
    required this.detail,
    this.feeling = '',
  });

  final String time;
  final String detail;
  final String feeling;
}

@Deprecated('旧 core 透传结构；改用 CompanionPerson')
class LifePerson {
  const LifePerson({
    required this.name,
    required this.role,
    required this.note,
    required this.place,
  });

  final String name;
  final String role;
  final String note;
  final String place;
}

@Deprecated('旧 core 透传结构；改用 CompanionState')
class LifeSnapshot {
  const LifeSnapshot({
    required this.available,
    required this.place,
    required this.condition,
    required this.energy,
    required this.mood,
    required this.satiety,
    required this.social,
    required this.awake,
    required this.transit,
    required this.clock,
    required this.weather,
    required this.day,
    required this.events,
    required this.people,
    required this.items,
    this.diary,
  });

  final bool available;
  final String place;
  final String condition;
  final double energy;
  final double mood;
  final double satiety;
  final double social;
  final bool awake;
  final Map<String, dynamic>? transit;
  final String clock;
  final String weather;
  final String day;
  final List<LifeEvent> events;
  final List<LifePerson> people;
  final List<Map<String, dynamic>> items;
  final String? diary;

  factory LifeSnapshot.fromJson(Map<String, dynamic> json) {
    final world =
        (json['world'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final rawEvents = (json['events'] as List<dynamic>?) ?? const [];
    final rawPeople = (json['people'] as List<dynamic>?) ?? const [];
    final rawItems = (json['items'] as List<dynamic>?) ?? const [];
    return LifeSnapshot(
      available: json['available'] == true,
      place: (json['place'] as String?) ?? '未知',
      condition: (json['condition'] as String?) ?? '',
      energy: (json['energy'] as num?)?.toDouble() ?? 0,
      mood: (json['mood'] as num?)?.toDouble() ?? 0,
      satiety: (json['satiety'] as num?)?.toDouble() ?? 0,
      social: (json['social'] as num?)?.toDouble() ?? 0,
      awake: json['awake'] != false,
      transit: json['transit'] as Map<String, dynamic>?,
      clock: _dayLabel(json['day'] as String?),
      weather: _weatherLabel(world['weather']),
      day: (json['day'] as String?) ?? '',
      events: rawEvents.map((e) {
        final m = e as Map<String, dynamic>;
        final clock = (m['clock_min'] as num?)?.toInt() ?? 0;
        return LifeEvent(
          time:
              '${(clock ~/ 60).toString().padLeft(2, '0')}:${(clock % 60).toString().padLeft(2, '0')}',
          detail: (m['detail'] as String?) ?? '',
          feeling: (m['feeling'] as String?) ?? '',
        );
      }).toList(),
      people: rawPeople.map((e) {
        final m = e as Map<String, dynamic>;
        return LifePerson(
          name: (m['name'] as String?) ?? '某人',
          role: (m['role'] as String?) ?? '',
          note: (m['note'] as String?) ?? '',
          place: (m['place'] as String?) ?? '',
        );
      }).toList(),
      items: rawItems.map((e) => e as Map<String, dynamic>).toList(),
      diary: json['diary'] as String?,
    );
  }
}

@Deprecated('旧 core feed 透传结构；改用 MomentsPage / Moment')
class RemoteMoment {
  const RemoteMoment({
    required this.id,
    required this.author,
    required this.time,
    required this.place,
    required this.text,
    required this.photos,
  });

  final String id;
  final String author;
  final String time;
  final String place;
  final String text;
  final List<String> photos;
}

@Deprecated('旧裸 SSE 事件；改用 ContractChatEvent')
class ChatEvent {
  const ChatEvent(this.event, this.data);

  final String event;
  final String data;
}

String _dayLabel(String? isoDay) {
  if (isoDay == null || isoDay.isEmpty) return '';
  final date = DateTime.tryParse(isoDay);
  if (date == null) return isoDay;
  const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return '${date.month}月${date.day}日 ${weekdays[date.weekday - 1]}';
}

String _weatherLabel(Object? raw) {
  if (raw is String) return raw;
  if (raw is! Map) return '';
  final condition = raw['condition']?.toString() ?? '';
  final rain = raw['rain'] == true;
  final temp = (raw['temp_c'] as num?)?.toDouble();
  final label = switch (condition) {
    'clear' => '晴',
    'cloudy' => '阴',
    'overcast' => '阴',
    'rain' || 'rainy' => '雨',
    'snow' || 'snowy' => '雪',
    'fog' || 'foggy' => '雾',
    _ => rain ? '雨' : condition,
  };
  if (temp == null) return label;
  final value = temp == temp.roundToDouble()
      ? temp.toStringAsFixed(0)
      : temp.toStringAsFixed(1);
  return '$label $value°C';
}
