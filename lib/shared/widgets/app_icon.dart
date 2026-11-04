import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AppIconName {
  sun,
  moments,
  diary,
  person,
  chat,
  search,
  camera,
  more,
  grid,
  settings,
  book,
  calendar,
  heart,
  chevron,
  back,
  plus,
  send,
  thumb,
  close,
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    required this.size,
    this.color = Colors.white,
    this.strokeWidth,
  });

  final AppIconName name;
  final double size;
  final Color color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _IconPainter(
        name: name,
        color: color,
        strokeWidth: strokeWidth ?? size * 0.075,
      ),
      isComplex: true,
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter({
    required this.name,
    required this.color,
    required this.strokeWidth,
  });

  final AppIconName name;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    switch (name) {
      case AppIconName.sun:
        canvas.drawCircle(const Offset(12, 12), 4, paint);
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          canvas.drawLine(
            Offset(12 + math.cos(angle) * 7.2, 12 + math.sin(angle) * 7.2),
            Offset(12 + math.cos(angle) * 9.6, 12 + math.sin(angle) * 9.6),
            paint,
          );
        }
      case AppIconName.moments:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 3, 18, 18),
            const Radius.circular(4),
          ),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(3, 16)
            ..lineTo(8, 10.5)
            ..lineTo(12.5, 15)
            ..lineTo(16, 12)
            ..lineTo(21, 17),
          paint,
        );
        canvas.drawCircle(const Offset(16, 8), 1.4, fill);
      case AppIconName.diary:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4, 3, 16, 18),
            const Radius.circular(3),
          ),
          paint,
        );
        canvas.drawLine(const Offset(4, 9), const Offset(20, 9), paint);
        canvas.drawLine(const Offset(8, 2.5), const Offset(8, 5.5), paint);
        canvas.drawLine(const Offset(16, 2.5), const Offset(16, 5.5), paint);
        canvas.drawLine(const Offset(8, 13), const Offset(16, 13), paint);
      case AppIconName.person:
        canvas.drawCircle(const Offset(12, 8), 3.5, paint);
        canvas.drawPath(
          Path()
            ..moveTo(4.5, 20)
            ..cubicTo(5.2, 16.3, 8.2, 14.3, 12, 14.3)
            ..cubicTo(15.8, 14.3, 18.8, 16.3, 19.5, 20),
          paint,
        );
      case AppIconName.chat:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 4, 18, 13),
            const Radius.circular(5),
          ),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(8, 16)
            ..lineTo(6.5, 20.5)
            ..lineTo(11.5, 17),
          paint,
        );
      case AppIconName.search:
        canvas.drawCircle(const Offset(10.5, 10.5), 6, paint);
        canvas.drawLine(const Offset(15.5, 15.5), const Offset(21, 21), paint);
      case AppIconName.camera:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 6, 18, 13),
            const Radius.circular(3),
          ),
          paint,
        );
        canvas.drawCircle(const Offset(12, 12.5), 3.5, paint);
        canvas.drawLine(const Offset(8, 6), const Offset(9.2, 4), paint);
        canvas.drawLine(const Offset(9.2, 4), const Offset(14.8, 4), paint);
        canvas.drawLine(const Offset(14.8, 4), const Offset(16, 6), paint);
      case AppIconName.more:
        for (final x in <double>[3.5, 12, 20.5]) {
          canvas.drawCircle(Offset(x, 12), 1.5, fill);
        }
      case AppIconName.grid:
        for (final rect in [
          const Rect.fromLTWH(3.5, 3.5, 7, 7),
          const Rect.fromLTWH(13.5, 3.5, 7, 7),
          const Rect.fromLTWH(3.5, 13.5, 7, 7),
          const Rect.fromLTWH(13.5, 13.5, 7, 7),
        ]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            paint,
          );
        }
      case AppIconName.settings:
        for (var i = 0; i < 3; i++) {
          final y = 6.0 + i * 6;
          canvas.drawLine(Offset(3, y), Offset(21, y), paint);
          canvas.drawCircle(Offset(i == 1 ? 14 : 8, y), 2, fill);
        }
      case AppIconName.book:
        canvas.drawPath(
          Path()
            ..moveTo(4, 5)
            ..cubicTo(7, 3.5, 10, 4.5, 12, 6)
            ..cubicTo(14, 4.5, 17, 3.5, 20, 5)
            ..lineTo(20, 19)
            ..cubicTo(17, 17.5, 14, 18.5, 12, 20)
            ..cubicTo(10, 18.5, 7, 17.5, 4, 19)
            ..close(),
          paint,
        );
        canvas.drawLine(const Offset(12, 6), const Offset(12, 20), paint);
      case AppIconName.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4, 5, 16, 16),
            const Radius.circular(3),
          ),
          paint,
        );
        canvas.drawLine(const Offset(4, 10), const Offset(20, 10), paint);
        canvas.drawLine(const Offset(8, 2.5), const Offset(8, 6), paint);
        canvas.drawLine(const Offset(16, 2.5), const Offset(16, 6), paint);
      case AppIconName.heart:
        canvas.drawPath(
          Path()
            ..moveTo(12, 20)
            ..cubicTo(10.5, 18.5, 4, 14, 4, 8.7)
            ..cubicTo(4, 5.6, 7.2, 3.7, 9.7, 5.8)
            ..lineTo(12, 7.8)
            ..lineTo(14.3, 5.8)
            ..cubicTo(16.8, 3.7, 20, 5.6, 20, 8.7)
            ..cubicTo(20, 14, 13.5, 18.5, 12, 20)
            ..close(),
          paint,
        );
      case AppIconName.chevron:
        canvas.drawPath(
          Path()
            ..moveTo(9, 5)
            ..lineTo(16, 12)
            ..lineTo(9, 19),
          paint,
        );
      case AppIconName.back:
        canvas.drawPath(
          Path()
            ..moveTo(15, 5)
            ..lineTo(8, 12)
            ..lineTo(15, 19),
          paint,
        );
      case AppIconName.plus:
        canvas.drawLine(const Offset(12, 4), const Offset(12, 20), paint);
        canvas.drawLine(const Offset(4, 12), const Offset(20, 12), paint);
      case AppIconName.send:
        canvas.drawPath(
          Path()
            ..moveTo(4, 12)
            ..lineTo(20, 4)
            ..lineTo(14, 20)
            ..lineTo(11.5, 13.5)
            ..close(),
          paint,
        );
      case AppIconName.close:
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), paint);
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), paint);
      case AppIconName.thumb:
        canvas.drawPath(
          Path()
            ..moveTo(7, 10)
            ..lineTo(7, 20)
            ..lineTo(3, 20)
            ..lineTo(3, 10)
            ..close(),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(7, 10)
            ..lineTo(11, 3)
            ..cubicTo(13, 3, 14, 5, 13, 8)
            ..lineTo(20, 8)
            ..cubicTo(21.5, 8, 21.5, 11, 19.5, 11)
            ..lineTo(17, 11)
            ..lineTo(20, 18)
            ..cubicTo(20.5, 20, 18, 21, 16, 20)
            ..lineTo(10, 18),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) =>
      oldDelegate.name != name ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
