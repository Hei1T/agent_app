class Companion {
  const Companion({
    required this.name,
    required this.day,
    required this.place,
    required this.action,
    required this.weather,
    required this.temperature,
    required this.energy,
    required this.mood,
    required this.awake,
    required this.lastSeen,
  });

  final String name;
  final int day;
  final String place;
  final String action;
  final String weather;
  final String temperature;
  final int energy;
  final String mood;
  final bool awake;
  final String lastSeen;
}

const demoCompanion = Companion(
  name: '笨笨',
  day: 5,
  place: '旧书店',
  action: '收书',
  weather: '雨',
  temperature: '1.7°C',
  energy: 62,
  mood: '安静',
  awake: true,
  lastSeen: '15:32',
);
