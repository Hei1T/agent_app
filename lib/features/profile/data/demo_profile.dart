import '../domain/entities/profile_data.dart';

const demoProfile = ProfileData(
  people: [
    Person(
      name: '林叔',
      role: '旧书店掌柜',
      note: '今天见过',
      photo: 'assets/media/book2.jpg',
    ),
    Person(
      name: '张姨',
      role: '巷口裁缝',
      note: '昨天',
      photo: 'assets/media/book3.jpg',
    ),
    Person(
      name: '老赵',
      role: '旧货摊',
      note: '前天',
      photo: 'assets/media/book1.jpg',
    ),
  ],
  things: [
    Thing(name: '那堆旧书', detail: '后院 · 九本 · 今天'),
    Thing(name: '生火的灶', detail: '厨房 · 用了 3 天'),
    Thing(name: '旧外套', detail: '旧货市场 · 八十块'),
  ],
);
