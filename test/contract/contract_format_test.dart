import 'package:benben_app/core/contract/contract_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('date label uses the literal backend date', () {
    expect(contractDateLabel('2026-11-04T15:32:00+08:00'), '11月4日');
    expect(contractDateLabel('第 5 天'), '第 5 天');
    expect(contractDateLabel(null), isNull);
  });

  test('weekday and clock labels', () {
    expect(contractWeekdayLabel('2026-11-04T15:32:00+08:00'), '周三');
    expect(contractWeekdayLabel('not-a-date'), isNull);
    expect(contractClockLabel('2026-11-04T15:32:00+08:00'), '15:32');
    expect(contractClockLabel(null), isNull);
  });

  test('temperature / percent / paragraphs', () {
    expect(contractTemperatureLabel(1.7), '1.7°C');
    expect(contractTemperatureLabel(2), '2°C');
    expect(contractPercentLabel(0.39), '39%');
    expect(contractPercentLabel(null), isNull);
    expect(contractParagraphs('第一段\n\n第二段'), ['第一段', '第二段']);
    expect(contractParagraphs(''), isEmpty);
  });
}
