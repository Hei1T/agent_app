import '../../../core/contract/companion_state.dart';
import '../domain/entities/profile_data.dart';

/// GET /companion/state -> Profile 页面展示模型。
///
/// TODO(app-contract): 契约暂无 people[].photo / items[].photo，头像暂用设计稿
/// 本地占位图；media 代理接入后换成后端 URL。
ProfileData profileOf(CompanionState state) {
  final people = [
    for (var i = 0; i < state.people.length; i++)
      Person(
        name: state.people[i].name,
        role: state.people[i].role,
        note: _personNote(state.people[i]),
        photo: _personPhoto(i),
      ),
  ];
  final things = [
    for (final item in state.items)
      Thing(name: item.name, detail: _itemDetail(item)),
  ];
  return ProfileData(people: people, things: things);
}

String itemKindLabel(String? kind) => switch (kind) {
  'clothing' => '衣物',
  'book' => '书',
  'food' => '食物',
  'tool' => '工具',
  'furniture' => '家具',
  'other' => '其他',
  null || '' => '物件',
  _ => kind,
};

String _personNote(CompanionPerson person) {
  if (person.note.isNotEmpty) return person.note;
  return person.place ?? '';
}

String _itemDetail(CompanionItem item) {
  final parts = [
    itemKindLabel(item.kind),
    item.place ?? '',
    item.note,
  ].where((part) => part.isNotEmpty);
  return parts.join(' · ');
}

String _personPhoto(int index) {
  const photos = [
    'assets/media/book2.jpg',
    'assets/media/book3.jpg',
    'assets/media/book1.jpg',
  ];
  return photos[index % photos.length];
}
