class Person {
  const Person({
    required this.name,
    required this.role,
    required this.note,
    required this.photo,
  });

  final String name;
  final String role;
  final String note;
  final String photo;
}

class Thing {
  const Thing({required this.name, required this.detail});

  final String name;
  final String detail;
}

class ProfileData {
  const ProfileData({required this.people, required this.things});

  final List<Person> people;
  final List<Thing> things;
}
