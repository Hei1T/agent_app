import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/photo_overlay.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/companion_state_mapper.dart';
import '../../domain/entities/today_entities.dart';

class TodayHeaderActions extends ConsumerWidget {
  const TodayHeaderActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(icon: AppIconName.search, onTap: () => _search(context)),
        SizedBox(width: AppSpacing.xs(context)),
        AppIconButton(icon: AppIconName.camera, onTap: () => _camera(context)),
        SizedBox(width: AppSpacing.xs(context)),
        AppIconButton(icon: AppIconName.more, onTap: () => _more(context)),
      ],
    );
  }

  void _search(BuildContext context) {
    showAppSheet(
      context,
      title: '搜索他的生活',
      full: true,
      child: const _SearchSheet(),
    );
  }

  void _camera(BuildContext context) {
    showPhotoPicker(context);
  }

  void _more(BuildContext context) {
    showAppSheet(
      context,
      title: '更多',
      child: SheetActionsWidget(
        actions: const [
          SheetActionData(
            id: 'index',
            label: '打开索引',
            description: '按世界、关系、物品查看',
            icon: AppIconName.grid,
          ),
          SheetActionData(
            id: 'settings',
            label: '设置',
            description: '通知、声音与关于',
            icon: AppIconName.settings,
          ),
          SheetActionData(
            id: 'refresh',
            label: '刷新今天',
            description: '重新读一遍今天的时间线',
            icon: AppIconName.sun,
          ),
          SheetActionData(
            id: 'about',
            label: '关于笨笨',
            description: '这个壳子背后的他',
            icon: AppIconName.book,
          ),
        ],
        onPick: (id) async {
          Navigator.of(context).pop();
          // 等上一个 sheet 的退出动画结束再推下一个，避免两个 route 交叉。
          await Future<void>.delayed(const Duration(milliseconds: 220));
          if (!context.mounted) return;
          if (id == 'index') _index(context);
          if (id == 'settings') _settings(context);
        },
      ),
    );
  }

  void _index(BuildContext context) {
    showAppSheet(
      context,
      title: '索引',
      child: SheetActionsWidget(
        actions: const [
          SheetActionData(
            id: 'world',
            label: '他的世界',
            description: '地图 · 街坊 · 风闻',
            icon: AppIconName.grid,
          ),
          SheetActionData(
            id: 'photos',
            label: '相册',
            description: '他拍过的所有照片',
            icon: AppIconName.moments,
          ),
          SheetActionData(
            id: 'mind',
            label: '心事',
            description: '他最近挂着的事',
            icon: AppIconName.heart,
          ),
          SheetActionData(
            id: 'relations',
            label: '关系',
            description: '他记住的人',
            icon: AppIconName.person,
          ),
          SheetActionData(
            id: 'things',
            label: '物品',
            description: '他的家当与磨损',
            icon: AppIconName.book,
          ),
          SheetActionData(
            id: 'days',
            label: '日子',
            description: '回看每一天',
            icon: AppIconName.calendar,
          ),
        ],
        onPick: (_) => Navigator.of(context).pop(),
      ),
    );
  }

  void _settings(BuildContext context) {
    showAppSheet(context, title: '设置', child: const _SettingsSheet());
  }
}

class _CameraSheet extends StatefulWidget {
  const _CameraSheet();

  @override
  State<_CameraSheet> createState() => _CameraSheetState();
}

class _CameraSheetState extends State<_CameraSheet> {
  final _picker = ImagePicker();
  XFile? _photo;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 82);
    if (!mounted || file == null) return;
    setState(() => _photo = file);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _photo == null
        ? GestureDetector(
            onTap: () => _pick(ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: context.r(120),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppRadius.md(context)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    AppIconName.camera,
                    size: context.r(28),
                    color: AppColors.inkMuted,
                  ),
                  SizedBox(height: AppSpacing.sm(context)),
                  Text('打开相机或相册', style: AppTextStyles.caption(context)),
                ],
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md(context)),
            child: Image.file(
              File(_photo!.path),
              width: double.infinity,
              height: context.r(180),
              fit: BoxFit.cover,
            ),
          );
    return SizedBox(
      height: context.r(300),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              preview,
              SizedBox(height: AppSpacing.md(context)),
              Row(
                children: [
                  Expanded(
                    child: _SheetButton(
                      label: '拍一张',
                      onTap: () => _pick(ImageSource.camera),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm(context)),
                  Expanded(
                    child: _SheetButton(
                      label: '从相册选择',
                      onTap: () => _pick(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              if (_photo != null) ...[
                SizedBox(height: AppSpacing.sm(context)),
                _SheetButton(
                  label: '使用这张',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSheet extends ConsumerStatefulWidget {
  const _SearchSheet();

  @override
  ConsumerState<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends ConsumerState<_SearchSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final state = ref.watch(companionStateProvider).valueOrNull;
    final entries = state == null ? const <TimelineEntry>[] : timelineOf(state);
    final results = query.isEmpty
        ? entries.take(6).toList()
        : entries.where((e) => (e.title + e.detail).contains(query)).toList();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md(context)),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.body(context),
            decoration: InputDecoration(
              hintText: '搜他的一天...',
              hintStyle: AppTextStyles.caption(context),
              prefixIcon: Padding(
                padding: EdgeInsets.all(AppSpacing.sm(context)),
                child: AppIcon(
                  AppIconName.search,
                  size: context.r(16),
                  color: AppColors.inkMuted,
                ),
              ),
              filled: true,
              fillColor: AppColors.surfaceRaised,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill(context)),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(AppSpacing.md(context)),
            itemCount: results.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.xs(context)),
            itemBuilder: (context, index) => _SearchRow(entry: results[index]),
          ),
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm(context)),
          child: SizedBox(
            width: context.r(38),
            height: context.r(38),
            child: entry.photo == null
                ? const SizedBox.shrink()
                : Image.asset(entry.photo!, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: AppSpacing.sm(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong(context),
              ),
              Text(
                entry.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(context),
              ),
            ],
          ),
        ),
        Text(entry.time, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

class _SettingsSheet extends ConsumerStatefulWidget {
  const _SettingsSheet();

  @override
  ConsumerState<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<_SettingsSheet> {
  bool notify = true;
  bool sound = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companionStateProvider).valueOrNull;
    final companion = state == null ? null : companionOf(state);
    final subtitle = [
      '栖湾',
      if (companion != null && companion.place.isNotEmpty) companion.place,
      if (companion?.day != null) '第 ${companion!.day} 天',
    ].join(' · ');
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md(context),
        0,
        AppSpacing.md(context),
        AppSpacing.lg(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.md(context)),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('你的笨笨', style: AppTextStyles.bodyStrong(context)),
                  Text(subtitle, style: AppTextStyles.caption(context)),
                  Text('这里只有他，和你们正在过的日子。', style: AppTextStyles.micro(context)),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm(context)),
          _SettingRow(
            label: '通知',
            detail: '他发消息时提醒我',
            value: notify,
            onTap: () => setState(() => notify = !notify),
          ),
          _SettingRow(
            label: '声音',
            detail: '发送与接收提示音',
            value: sound,
            onTap: () => setState(() => sound = !sound),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.detail,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md(context)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyStrong(context)),
                  Text(detail, style: AppTextStyles.caption(context)),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: value ? AppColors.tint : AppColors.borderStrong,
                borderRadius: BorderRadius.circular(AppRadius.pill(context)),
              ),
              child: SizedBox(width: context.r(34), height: context.r(20)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.md(context)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: context.r(40),
          child: Center(
            child: Text(label, style: AppTextStyles.bodyStrong(context)),
          ),
        ),
      ),
    );
  }
}
