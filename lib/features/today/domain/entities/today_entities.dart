class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.time,
    required this.title,
    required this.detail,
    this.photo,
    this.feeling = '',
    this.unread = 0,
  });

  final String id;
  final String time;
  final String title;
  final String detail;
  final String? photo;
  final String feeling;
  final int unread;
}
