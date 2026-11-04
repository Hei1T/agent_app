import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_sheet.dart';

final pendingChatPhotoProvider = StateProvider<XFile?>((ref) => null);

/// 所有入口共用同一个 Sheet 宿主，不再为拍照单独做浮层。
Future<void> showPhotoPicker(BuildContext context) {
  return showAppSheet(
    context,
    title: '给他看一张照片',
    child: const PhotoPickerContent(),
    heightFactor: 0.42,
  );
}

class PhotoPickerContent extends StatefulWidget {
  const PhotoPickerContent({super.key});

  @override
  State<PhotoPickerContent> createState() => _PhotoPickerContentState();
}

class _PhotoPickerContentState extends State<PhotoPickerContent> {
  final _picker = ImagePicker();
  XFile? _photo;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 82);
    if (!mounted || file == null) return;
    setState(() => _photo = file);
  }

  void _use() {
    final file = _photo;
    if (file == null) return;
    final container = ProviderScope.containerOf(context);
    container.read(pendingChatPhotoProvider.notifier).state = file;
    Navigator.of(context).pop();
    context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_photo == null)
          GestureDetector(
            onTap: () => _pick(ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: context.r(140),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(context.r(14)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: context.r(30),
                    color: AppColors.inkMuted,
                  ),
                  SizedBox(height: AppSpacing.sm(context)),
                  Text('打开相机或相册', style: AppTextStyles.caption(context)),
                ],
              ),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(context.r(14)),
            child: Image.file(
              File(_photo!.path),
              width: double.infinity,
              height: context.r(190),
              fit: BoxFit.cover,
            ),
          ),
        SizedBox(height: AppSpacing.md(context)),
        Row(
          children: [
            Expanded(
              child: _Action(
                label: '拍一张',
                onTap: () => _pick(ImageSource.camera),
              ),
            ),
            SizedBox(width: AppSpacing.sm(context)),
            Expanded(
              child: _Action(
                label: '从相册选择',
                onTap: () => _pick(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (_photo != null) ...[
          SizedBox(height: AppSpacing.sm(context)),
          _Action(label: '使用这张', onTap: _use, primary: true),
        ],
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.r(40),
        decoration: BoxDecoration(
          color: primary ? AppColors.tint : AppColors.surface,
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: primary ? AppColors.tint : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyStrong(context).copyWith(
              color: primary ? AppColors.ground : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
