import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/diary_entry.dart';

class DiaryEntryCard extends StatelessWidget {
  const DiaryEntryCard({super.key, required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xCC2B211B), Color(0xD11A100C)],
        ),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 34,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.r(18),
          context.r(17),
          context.r(18),
          context.r(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Head(entry: entry),
            SizedBox(height: context.r(8)),
            _Meta(entry: entry),
            SizedBox(height: context.r(12)),
            _Body(paragraphs: entry.paragraphs),
            if (entry.photos.isNotEmpty) ...[
              SizedBox(height: context.r(13)),
              _Photos(photos: entry.photos),
            ],
            SizedBox(height: context.r(14)),
            _Quote(text: entry.quote),
            SizedBox(height: context.r(14)),
            _Foot(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                entry.date,
                style: AppTextStyles.headline(
                  context,
                ).copyWith(fontSize: context.sp(24), letterSpacing: -0.5),
              ),
              SizedBox(width: context.r(7)),
              Text(
                entry.weekday,
                style: AppTextStyles.caption(
                  context,
                ).copyWith(fontSize: context.sp(9)),
              ),
            ],
          ),
        ),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: context.r(5),
          runSpacing: context.r(5),
          children: [
            _Pill(text: '${entry.weather} · ${entry.temperature}'),
            _Pill(text: entry.mood),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.r(8),
        vertical: context.r(4),
      ),
      decoration: BoxDecoration(
        color: const Color(0x0BFFFFFF),
        borderRadius: BorderRadius.circular(context.r(999)),
        border: Border.all(color: const Color(0x14FFFFFF), width: 0.5),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption(context).copyWith(fontSize: context.sp(8)),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: context.r(8)),
      padding: EdgeInsets.only(bottom: context.r(9)),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x12FFFFFF), width: 0.5),
        ),
      ),
      child: Wrap(
        spacing: context.r(10),
        runSpacing: context.r(4),
        children: [
          Text(entry.dayCount, style: _metaStyle(context)),
          Text('栖湾 · 旧书店', style: _metaStyle(context)),
          Text(entry.writtenAt, style: _metaStyle(context)),
        ],
      ),
    );
  }

  TextStyle _metaStyle(BuildContext context) =>
      AppTextStyles.caption(context).copyWith(
        fontSize: context.sp(8),
        letterSpacing: 0.03,
        color: AppColors.inkFaint,
      );
}

class _Body extends StatelessWidget {
  const _Body({required this.paragraphs});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < paragraphs.length; i++) ...[
          if (i > 0) SizedBox(height: context.r(10)),
          if (i == 0 && paragraphs[i].isNotEmpty)
            Text.rich(
              TextSpan(
                style: AppTextStyles.body(context).copyWith(
                  fontSize: context.sp(12.5),
                  height: 2,
                  color: const Color(0xD6F7F2EB),
                ),
                children: [
                  TextSpan(
                    text: paragraphs[i].substring(0, 1),
                    style: AppTextStyles.headline(context).copyWith(
                      fontSize: context.sp(30),
                      height: 0.95,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tint,
                    ),
                  ),
                  TextSpan(text: paragraphs[i].substring(1)),
                ],
              ),
            )
          else
            Text(
              paragraphs[i],
              style: AppTextStyles.body(context).copyWith(
                fontSize: context.sp(12.5),
                height: 2,
                color: const Color(0xD6F7F2EB),
              ),
            ),
        ],
      ],
    );
  }
}

class _Photos extends StatelessWidget {
  const _Photos({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.r(68),
      child: Row(
        children: [
          for (var i = 0; i < photos.length; i++) ...[
            if (i > 0) SizedBox(width: context.r(6)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.r(10)),
                child: Opacity(
                  opacity: 0.92,
                  child: Image.asset(
                    photos[i],
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: context.r(14)),
      padding: EdgeInsets.symmetric(
        horizontal: context.r(12),
        vertical: context.r(9),
      ),
      decoration: BoxDecoration(
        color: const Color(0x0EFF9E6B),
        border: const Border(
          left: BorderSide(color: Color(0xA6FF9E6B), width: 2),
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(context.r(10)),
          bottomRight: Radius.circular(context.r(10)),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.body(context).copyWith(
          fontSize: context.sp(11),
          height: 1.7,
          color: const Color(0xB8F7F2EB),
        ),
      ),
    );
  }
}

class _Foot extends StatelessWidget {
  const _Foot({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.caption(context).copyWith(
      fontSize: context.sp(8),
      letterSpacing: 0.08,
      color: AppColors.inkFaint,
    );
    return Container(
      margin: EdgeInsets.only(top: context.r(14)),
      padding: EdgeInsets.only(top: context.r(9)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0FFFFFFF), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('未寄出', style: style),
          Text(entry.dayCount, style: style),
        ],
      ),
    );
  }
}
