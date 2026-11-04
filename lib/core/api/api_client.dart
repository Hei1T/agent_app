import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import '../storage/token_storage.dart';

class AuthResult {
  const AuthResult({required this.token, required this.email});
  final String token;
  final String email;
}

class CreditBalance {
  const CreditBalance({required this.balance, required this.reserved, required this.available});
  final int balance;
  final int reserved;
  final int available;
  factory CreditBalance.fromJson(Map<String, dynamic> json) => CreditBalance(
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    reserved: (json['reserved'] as num?)?.toInt() ?? 0,
    available: (json['available'] as num?)?.toInt() ?? 0,
  );
}

class LifeEvent {
  const LifeEvent({required this.time, required this.detail, this.feeling = ''});
  final String time;
  final String detail;
  final String feeling;
}

class LifePerson {
  const LifePerson({required this.name, required this.role, required this.note, required this.place});
  final String name;
  final String role;
  final String note;
  final String place;
}

class LifeSnapshot {
  const LifeSnapshot({
    required this.available, required this.place, required this.condition,
    required this.energy, required this.mood, required this.satiety,
    required this.social, required this.awake, required this.transit,
    required this.clock, required this.weather, required this.events,
    required this.people, required this.items, this.diary,
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
  final List<LifeEvent> events;
  final List<LifePerson> people;
  final List<Map<String, dynamic>> items;
  final String? diary;
  factory LifeSnapshot.fromJson(Map<String, dynamic> json) {
    final world = (json['world'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
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
      clock: (world['clock_label'] as String?) ?? '',
      weather: (world['weather'] as String?) ?? '',
      events: rawEvents.map((e) {
        final m = e as Map<String, dynamic>;
        final clock = (m['clock_min'] as num?)?.toInt() ?? 0;
        return LifeEvent(
          time: '${(clock ~/ 60).toString().padLeft(2, '0')}:${(clock % 60).toString().padLeft(2, '0')}',
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

class RemoteMoment {
  const RemoteMoment({required this.id, required this.author, required this.time, required this.place, required this.text, required this.photos});
  final String id;
  final String author;
  final String time;
  final String place;
  final String text;
  final List<String> photos;
}

class ChatEvent {
  const ChatEvent(this.event, this.data);
  final String event;
  final String data;
}

class ApiClient {
  ApiClient({this.token, TokenStorage? storage})
      : storage = storage ?? TokenStorage(),
        _dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl, connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 120))) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (token != null && token!.isNotEmpty) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }));
  }

  String? token;
  final TokenStorage storage;
  final Dio _dio;

  static String get baseUrl => ApiEndpoints.baseUrl;

  Map<String, dynamic> _data(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw const ApiException(500, '响应格式错误');
  }

  Never _fail(DioException error) {
    final status = error.response?.statusCode ?? 0;
    var message = '请求失败';
    String? code;
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? message;
      code = data['code'] as String?;
    }
    throw ApiException(status, message, code: code);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      return _data(await _dio.get<dynamic>(path));
    } on DioException catch (error) {
      _fail(error);
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      return _data(await _dio.post<dynamic>(path, data: body));
    } on DioException catch (error) {
      _fail(error);
    }
  }

  Future<AuthResult> login(String email, String password) async {
    final data = await _post(ApiEndpoints.login, {'email': email, 'password': password});
    final result = AuthResult(token: data['accessToken'] as String, email: (data['account']?['email'] as String?) ?? email);
    token = result.token;
    return result;
  }

  Future<AuthResult> register(String email, String password) async {
    final data = await _post(ApiEndpoints.register, {'email': email, 'password': password});
    final result = AuthResult(token: data['accessToken'] as String, email: (data['account']?['email'] as String?) ?? email);
    token = result.token;
    return result;
  }

  Future<LifeSnapshot> life() async => LifeSnapshot.fromJson(await _get(ApiEndpoints.life));

  Future<List<RemoteMoment>> feed() async {
    final data = await _get('${ApiEndpoints.feed}?limit=30');
    final raw = (data['posts'] as List<dynamic>?) ?? const [];
    return raw.map((e) {
      final m = e as Map<String, dynamic>;
      final photos = <String>[];
      final rawPhotos = m['photos'];
      if (rawPhotos is List) photos.addAll(rawPhotos.whereType<String>());
      if (photos.isEmpty && m['photo_url'] is String) photos.add(m['photo_url'] as String);
      final ts = (m['ts'] as String?) ?? '';
      return RemoteMoment(
        id: (m['id'] as num?)?.toString() ?? 'post-${DateTime.now().microsecondsSinceEpoch}',
        author: '笨笨',
        time: ts.length >= 16 ? ts.substring(11, 16) : '',
        place: (m['place'] as String?) ?? '',
        text: (m['text'] as String?) ?? '',
        photos: photos,
      );
    }).toList();
  }

  Future<CreditBalance> credits() async => CreditBalance.fromJson(await _get(ApiEndpoints.credits));

  Stream<ChatEvent> streamChat(String message) async* {
    final response = await _dio.post<ResponseBody>(
      ApiEndpoints.chat,
      data: {'message': message},
      options: Options(responseType: ResponseType.stream, validateStatus: (status) => status != null),
    );
    final body = response.data;
    if (body == null) throw const ApiException(502, '上游没有返回流');
    if (response.statusCode != 200) {
      final text = await utf8.decoder.bind(body.stream).join();
      var messageText = '请求失败';
      String? code;
      try {
        final data = jsonDecode(text) as Map<String, dynamic>;
        messageText = (data['message'] as String?) ?? messageText;
        code = data['code'] as String?;
      } catch (_) {}
      throw ApiException(response.statusCode ?? 0, messageText, code: code);
    }
    var event = '';
    final data = StringBuffer();
    await for (final line in utf8.decoder.bind(body.stream).transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (data.isNotEmpty) yield ChatEvent(event.isEmpty ? 'message' : event, data.toString());
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
    if (data.isNotEmpty) yield ChatEvent(event.isEmpty ? 'message' : event, data.toString());
  }
}
