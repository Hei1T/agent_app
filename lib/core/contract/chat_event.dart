import 'dart:convert';

import 'contract_json.dart';

/// done 事件里的 usage；现在可以为 null 或全零（契约第 6 节）。
class ContractChatUsage {
  const ContractChatUsage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  });

  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  factory ContractChatUsage.fromJson(Map<String, dynamic> json) =>
      ContractChatUsage(
        promptTokens: contractInt(json['promptTokens']),
        completionTokens: contractInt(json['completionTokens']),
        totalTokens: contractInt(json['totalTokens']),
      );
}

/// 聊天 SSE 事件。
///
/// 契约要求 data 为 JSON（meta / delta / tool / done / error）；迁移期可能
/// 仍收到裸字符串（旧 core），[rawData] 保留原文，[text] 给出可展示文本。
class ContractChatEvent {
  const ContractChatEvent({
    required this.event,
    required this.rawData,
    this.text,
    this.code,
    this.message,
    this.requestId,
    this.sessionId,
    this.turnId,
    this.callId,
    this.tool,
    this.preview,
    this.usage,
  });

  final String event;
  final String rawData;
  final String? text;
  final String? code;
  final String? message;
  final String? requestId;
  final String? sessionId;
  final String? turnId;
  final String? callId;
  final String? tool;
  final String? preview;
  final ContractChatUsage? usage;

  bool get isMeta => event == 'meta';
  bool get isDelta => event == 'delta';
  bool get isDone => event == 'done';
  bool get isTool => event == 'tool';
  bool get isError => event == 'error';

  /// 可直接拼到气泡里的文本；error 取 message。
  String get displayText => text ?? message ?? rawData;

  factory ContractChatEvent.parse(String eventName, String data) {
    final event = eventName.isEmpty ? 'message' : eventName;
    final json = _tryDecodeMap(data);
    if (json == null) {
      // 旧 core：data 是裸字符串。过渡期按事件类型兜底，新版本只认 JSON。
      return ContractChatEvent(
        event: event,
        rawData: data,
        text: event == 'delta' || event == 'done' || event == 'message'
            ? data
            : null,
        message: event == 'error' ? data : null,
      );
    }
    final usageJson = contractMap(json['usage']);
    return ContractChatEvent(
      event: event,
      rawData: data,
      text: contractString(json['text']) ?? json['text']?.toString(),
      code: contractString(json['code']),
      message: contractString(json['message']),
      requestId: contractString(json['requestId']),
      sessionId: contractString(json['sessionId']),
      turnId: contractString(json['turnId']),
      callId: contractString(json['callId']),
      tool: contractString(json['tool']),
      preview: contractString(json['preview']),
      usage: usageJson == null ? null : ContractChatUsage.fromJson(usageJson),
    );
  }

  static Map<String, dynamic>? _tryDecodeMap(String data) {
    if (data.isEmpty) return null;
    try {
      final decoded = jsonDecode(data);
      return contractMap(decoded);
    } on FormatException {
      return null;
    }
  }
}
