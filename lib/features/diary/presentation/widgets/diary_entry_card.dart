import 'package:flutter/material.dart';

import '../../../../core/contract/contract_format.dart';
import '../../../../core/contract/diary.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 日记条目：单页平面化排版，无卡片表面 / 阴影 / 圆角，只留底部分隔线。
///
/// 数据来自 GET /companion/diary：day / text / createdAt。契约暂未提供
/// 天气、心情、照片、引用，缺失时对应区块直接省略，不伪造。
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
    final day = entry.day;
    final dateLabel =
        contractDateLabel(day) ?? contractDateLabel(entry.createdAt) ?? '';
    final weekday = contractWeekdayLabel(day ?? entry.createdAt) ?? '';
    final clock = contractClockLabel(entry.createdAt) ?? '';
    final paragraphs = contractParagraphs(entry.text);
    return Container(
      key: Key('diary_entry_${entry.id ?? day ?? entry.createdAt ?? 'entry'}'),
      padding: EdgeInsets.symmetric(vertical: context.r(12)),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(dateLabel: dateLabel, weekday: weekday, clock: clock),
          if (clock.isNotEmpty) _Meta(clock: clock),
          SizedBox(height: context.r(12)),
          _Body(paragraphs: paragraphs),
          SizedBox(height: context.r(14)),
          _Foot(dateLabel: dateLabel),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({
    required this.dateLabel,
    required this.weekday,
    required this.clock,
  });

  final String dateLabel;
  final String weekday;
  final String clock;

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
                dateLabel.isEmpty ? '某一天' : dateLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headline(
                  context,
                ).copyWith(fontSize: context.sp(24), letterSpacing: -0.5),
              ),
              if (weekday.isNotEmpty) ...[
                SizedBox(width: context.r(7)),
                Text(
                  weekday,
                  maxLines: 1,
                  style: _noteStyle(context).copyWith(letterSpacing: 0.2),
                ),
              ],
            ],
          ),
        ),
        if (clock.isNotEmpty) ...[
          SizedBox(width: context.r(8)),
          Text(
            clock,
            maxLines: 1,
            style: _noteStyle(context).copyWith(color: AppColors.inkMuted),
          ),
        ],
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.clock});

  final String clock;

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
        children: [Text('写于 $clock', style: style)],
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
    if (paragraphs.isEmpty) {
      return Text(
        '这一天没有写下正文。',
        style: base.copyWith(color: AppColors.inkMuted),
      );
    }
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

class _Foot extends StatelessWidget {
  const _Foot({required this.dateLabel});

  final String dateLabel;

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
          Flexible(
            child: Text(
              dateLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _noteStyle(BuildContext context) => AppTextStyles.caption(
  context,
).copyWith(fontSize: context.sp(10.5), color: AppColors.inkFaint);
