import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/fade_mask.dart';
import '../../../shared/widgets/phone_page.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../data/demo_moments.dart';
import 'moment_overlay_provider.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/photo_overlay.dart';
import 'widgets/moment_detail_sheet.dart';
import '../domain/entities/moment.dart';
import 'widgets/moment_card.dart';

class MomentsView extends ConsumerStatefulWidget {
  const MomentsView({super.key});

  @override
  ConsumerState<MomentsView> createState() => _MomentsViewState();
}

class _MomentsViewState extends ConsumerState<MomentsView> {

  @override
  Widget build(BuildContext context) {
    final liked = ref.watch(likedMomentsProvider);
    final comments = ref.watch(momentCommentsProvider);
    return PhonePage(
      key: const Key('moments_view'),
      header: ScreenHeader(
        title: '朋友圈',
        subtitle: '他的生活 · 第 5 天',
        actions: [
          AppIconButton(
            icon: AppIconName.camera,
            onTap: () => _showCamera(context),
          ),
        ],
      ),
      child: FadeMask(
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageH(context),
            context.r(62),
            AppSpacing.pageH(context),
            context.isPortrait ? context.r(112) : AppSpacing.lg(context),
          ),
          itemCount: demoMoments.length,
          separatorBuilder: (context, index) =>
              SizedBox(height: AppSpacing.md(context)),
          itemBuilder: (context, index) {
            final item = demoMoments[index];
            return MomentCard(
              moment: item,
              liked: liked.contains(item.id),
              comments: comments[item.id] ?? item.comments,
              onLike: () => _toggle(item.id),
              onTap: () => _open(item),
            );
          },
        ),
      ),
    );
  }

  void _toggle(String id) {
    ref.read(likedMomentsProvider.notifier).update((liked) {
      final next = {...liked};
      if (!next.remove(id)) next.add(id);
      return next;
    });
  }

  void _open(Moment moment) {
    showAppSheet(
      context,
      title: '动态',
      full: true,
      child: MomentDetailSheet(
        moment: moment,
        liked: ref.read(likedMomentsProvider).contains(moment.id),
        comments: ref.read(momentCommentsProvider)[moment.id],
        onLike: () {
          ref.read(likedMomentsProvider.notifier).update((liked) {
            final next = {...liked};
            if (!next.remove(moment.id)) next.add(moment.id);
            return next;
          });
        },
        onAddComment: (text) {
          ref.read(momentCommentsProvider.notifier).update((value) {
            final next = {...value};
            next[moment.id] = [
              ...?value[moment.id],
              MomentComment(author: '你', text: text, time: '刚刚'),
            ];
            return next;
          });
        },
      ),
    );
  }
  void _showCamera(BuildContext context) {
    showPhotoPicker(context, withNote: true);
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_photo == null)
              GestureDetector(
                onTap: () => _pick(ImageSource.camera),
                child: Container(
                  width: double.infinity,
                  height: context.r(150),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppRadius.md(context)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 32, color: Colors.white70),
                      SizedBox(height: AppSpacing.md(context)),
                      Text('打开相机或相册', style: AppTextStyles.caption(context)),
                    ],
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md(context)),
                child: Image.file(
                  File(_photo!.path),
                  width: double.infinity,
                  height: context.r(210),
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: AppSpacing.md(context)),
            Row(
              children: [
                Expanded(
                  child: _PhotoButton(label: '拍一张', onTap: () => _pick(ImageSource.camera)),
                ),
                SizedBox(width: AppSpacing.sm(context)),
                Expanded(
                  child: _PhotoButton(label: '从相册选择', onTap: () => _pick(ImageSource.gallery)),
                ),
              ],
            ),
            if (_photo != null) ...[
              SizedBox(height: AppSpacing.sm(context)),
              _PhotoButton(label: '使用这张', onTap: () => Navigator.of(context).pop()),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.r(10)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill(context)),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(label, style: AppTextStyles.body(context)),
        ),
      ),
    );
  }
}
