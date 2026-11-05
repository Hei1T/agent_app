import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/companion.dart';

/// 「他此刻」：单页平面化，没有卡片外壳，只在底部留一条 hairline。
///
/// 对齐 React 稿 `.today-single .now-card`：透明底、0 圆角、透明 stats，
/// stats 三列一行，用 0.5px 左分隔线区分。
class NowCard extends StatelessWidget {
  const NowCard({super.key, required this.companion, required this.onTap});

  final Companion companion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('today_now_card'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: context.r(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopRow(companion: companion),
              _Stats(companion: companion),
              _Quote(text: companion.quote),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(initial: _initial(companion.name), awake: companion.awake),
        SizedBox(width: context.r(10)),
        Expanded(child: _TitleBlock(companion: companion)),
        Icon(
          Icons.chevron_right_rounded,
          size: context.r(15),
          color: AppColors.inkFaint,
        ),
      ],
    );
  }

  String _initial(String name) => name.isEmpty ? '笨' : name.substring(0, 1);
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.awake});

  final String initial;
  final bool awake;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('now_avatar'),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.tintSoft,
        border: Border.all(color: AppColors.tintBorder),
      ),
      child: SizedBox(
        width: context.r(42),
        height: context.r(42),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              initial,
              maxLines: 1,
              style: AppTextStyles.title(
                context,
              ).copyWith(color: AppColors.tint, fontSize: context.sp(17)),
            ),
            if (awake)
              Positioned(
                right: 0,
                bottom: context.r(1),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.ground,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.r(2)),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: context.r(7),
                        height: context.r(7),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleLine(companion),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(context).copyWith(
            fontSize: context.sp(10.5),
            letterSpacing: 0.8,
            color: AppColors.inkFaint,
            height: 1.35,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: context.r(1)),
          child: Text(
            _whereLine(companion),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title(
              context,
            ).copyWith(fontSize: context.sp(15), fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: context.r(2)),
          child: Text(
            _meta(companion),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              fontSize: context.sp(11.5),
              color: AppColors.inkSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  String _titleLine(Companion companion) {
    final day = companion.day;
    return day == null ? '他此刻 · 今天' : '他此刻 · 第 $day 天';
  }

  String _whereLine(Companion companion) {
    final place = companion.place;
    final action = companion.action;
    if (place.isEmpty) return action;
    if (action.isEmpty) return '在$place';
    return '在$place · $action';
  }

  String _meta(Companion companion) {
    final date = companion.lastSeen;
    final weather = companion.weather;
    if (date.isEmpty) return weather;
    if (weather.isEmpty) return date;
    return '$date · $weather';
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.r(12)),
      child: Row(
        key: const Key('now_stats'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Stat(
              label: '体力',
              value: _percentText(companion.energy),
              divider: false,
            ),
          ),
          Expanded(
            child: _Stat(label: '心情', value: companion.mood),
          ),
          Expanded(
            child: _Stat(label: '饱腹', value: _percentText(companion.satiety)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.divider = true});

  final String label;
  final String value;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: EdgeInsets.only(
        left: divider ? context.r(10) : 0,
        right: context.r(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              fontSize: context.sp(10),
              color: AppColors.inkFaint,
              height: 1.3,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: context.r(1)),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyStrong(
                context,
              ).copyWith(fontSize: context.sp(13), height: 1.35),
            ),
          ),
        ],
      ),
    );
    if (!divider) return body;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: body,
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: context.r(12)),
      child: Text(
        '“$text”',
        key: const Key('now_quote'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body(context).copyWith(
          fontSize: context.sp(12.5),
          height: 1.65,
          color: AppColors.inkSecondary,
        ),
      ),
    );
  }
}

String _percentText(int? value) => value == null ? '—' : '$value%';
