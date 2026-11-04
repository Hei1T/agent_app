import '../domain/entities/chat_message.dart';

const demoChat = [
  ChatMessage(id: 'c1', text: '你那边忙不忙啊？', fromCompanion: false, read: true),
  ChatMessage(
    id: 'c2',
    text: '这会儿还好，就是手上一股子太阳晒过的纸味儿，暖烘烘的。你闻不着，可惜。',
    fromCompanion: true,
  ),
  ChatMessage(id: 'c3', text: '笨笨注意休息，别生病了。', fromCompanion: false, read: true),
  ChatMessage(id: 'c4', text: '知道了知道了，你别老操心我，你自己也注意点。', fromCompanion: true),
  ChatMessage(id: 'c5', text: '今天收了几本？', fromCompanion: false, read: true),
  ChatMessage(id: 'c6', text: '收了九本，三本还能卖，剩下六本我自己留着翻。', fromCompanion: true),
  ChatMessage(id: 'c7', text: '后院那堆都晒完了吗？', fromCompanion: false, read: true),
  ChatMessage(
    id: 'c8',
    text: '晒到下午三点，翻了两回。有一本夹着张旧车票，1987 年的。',
    fromCompanion: true,
  ),
];
