class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.date,
    required this.weekday,
    required this.weather,
    required this.temperature,
    required this.mood,
    required this.dayCount,
    required this.writtenAt,
    required this.paragraphs,
    required this.photos,
    required this.quote,
  });

  final String id;
  final String date;
  final String weekday;
  final String weather;
  final String temperature;
  final String mood;
  final String dayCount;
  final String writtenAt;
  final List<String> paragraphs;
  final List<String> photos;
  final String quote;
}
