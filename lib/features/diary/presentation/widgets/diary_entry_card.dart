import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/diary_entry.dart';

/// 日记条目：单页平面化排版，无卡片表面 / 阴影 / 圆角，只留底部分隔线。
class DiaryEntryCard extends StatelessWidget {
  const DiaryEntryCard({
    super.key,
    required this.entry,
    this.showDivider = true,
  });

  final DiaryEntry entry;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('diary_entry_${entry.id}'),
      padding: EdgeInsets.symmetric(vertical: context.r(12)),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(entry: entry),
          _Meta(entry: entry),
          SizedBox(height: context.r(12)),
          _Body(paragraphs: entry.paragraphs),
          if (entry.photos.isNotEmpty) ...[
            SizedBox(height: context.r(13)),
            _Photos(photos: entry.photos),
          ],
          SizedBox(height: context.r(14)),
          _Quote(text: entry.quote),
          _Foot(entry: entry),
        ],
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
                style: _noteStyle(context).copyWith(letterSpacing: 0.2),
              ),
            ],
          ),
        ),
        SizedBox(width: context.r(8)),
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: context.r(8),
            runSpacing: context.r(4),
            children: [
              Text(
                '${entry.weather} · ${entry.temperature}',
                style: _noteStyle(context).copyWith(color: AppColors.inkMuted),
              ),
              Text(
                entry.mood,
                style: _noteStyle(context).copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final style = _noteStyle(context).copyWith(letterSpacing: 0.3);
    return Container(
      key: const Key('diary_entry_meta'),
      width: double.infinity,
      margin: EdgeInsets.only(top: context.r(8)),
      padding: EdgeInsets.only(bottom: context.r(9)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Wrap(
        spacing: context.r(10),
        runSpacing: context.r(4),
        children: [
          Text(entry.dayCount, style: style),
          Text('栖湾 · 旧书店', style: style),
          Text(entry.writtenAt, style: style),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.paragraphs});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.body(context).copyWith(
      fontSize: context.sp(14),
      height: 1.8,
      color: AppColors.ink.withValues(alpha: 0.84),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < paragraphs.length; i++) ...[
          if (i > 0) SizedBox(height: context.r(10)),
          _Paragraph(text: paragraphs[i], dropCap: i == 0, style: base),
        ],
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({
    required this.text,
    required this.dropCap,
    required this.style,
  });

  final String text;
  final bool dropCap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (!dropCap || text.isEmpty) {
      return Text(text, style: style);
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: text.substring(0, 1),
            style: style.copyWith(
              fontSize: context.sp(30),
              height: 0.95,
              fontWeight: FontWeight.w600,
              color: AppColors.tint,
            ),
          ),
          TextSpan(text: text.substring(1)),
        ],
      ),
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
                borderRadius: BorderRadius.circular(AppRadius.sm(context)),
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
      key: const Key('diary_entry_quote'),
      width: double.infinity,
      margin: EdgeInsets.only(top: context.r(14)),
      padding: EdgeInsets.only(
        left: context.r(10),
        top: context.r(2),
        bottom: context.r(2),
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.tint.withValues(alpha: 0.65),
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.body(context).copyWith(
          fontSize: context.sp(13),
          height: 1.65,
          color: AppColors.inkSecondary,
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
    final style = _noteStyle(context).copyWith(letterSpacing: 0.8);
    return Container(
      margin: EdgeInsets.only(top: context.r(14)),
      padding: EdgeInsets.only(top: context.r(9)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
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

TextStyle _noteStyle(BuildContext context) => AppTextStyles.caption(
  context,
).copyWith(fontSize: context.sp(10.5), color: AppColors.inkFaint);
