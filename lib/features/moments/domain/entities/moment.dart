class MomentComment {
  const MomentComment({
    required this.author,
    required this.text,
    required this.time,
  });

  final String author;
  final String text;
  final String time;
}

class Moment {
  const Moment({
    required this.id,
    required this.author,
    required this.time,
    required this.place,
    required this.text,
    required this.photos,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String author;
  final String time;
  final String place;
  final String text;
  final List<String> photos;
  final List<String> likes;
  final List<MomentComment> comments;
}
