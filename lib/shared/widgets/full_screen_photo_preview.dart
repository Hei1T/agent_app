import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_sheet.dart';

/// 全站统一的图片全屏预览。
///
/// 通过根 Navigator 推入，层级位于页面/底部弹层之上、主动消息通知之下。
/// 朋友圈、聊天、日记、头像等任何地方都直接调用，不再各写一套。
Future<void> showFullScreenPhotoPreview(
  BuildContext context,
  String source, {
  String? heroTag,
}) {
  final host = AppSheetHost.hostKey.currentState;
  if (host != null) {
    return showPopup(
      context,
      _FullScreenPhotoPreview(source: source, heroTag: heroTag),
    );
  }
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '图片预览',
    barrierColor: const Color(0xF2070504),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _FullScreenPhotoPreview(source: source, heroTag: heroTag),
  );
}

class _FullScreenPhotoPreview extends StatefulWidget {
  const _FullScreenPhotoPreview({required this.source, this.heroTag});

  final String source;
  final String? heroTag;

  @override
  State<_FullScreenPhotoPreview> createState() =>
      _FullScreenPhotoPreviewState();
}

class _FullScreenPhotoPreviewState extends State<_FullScreenPhotoPreview> {
  late final TransformationController _transform;
  Offset _drag = Offset.zero;

  @override
  void initState() {
    super.initState();
    _transform = TransformationController();
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image(widget.source);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        setState(() => _drag += details.delta);
      },
      onVerticalDragEnd: (_) {
        if (_drag.dy.abs() > 110) {
          Navigator.of(context).pop();
        } else {
          setState(() => _drag = Offset.zero);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: const ColoredBox(color: Color(0xB8070504)),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: _drag,
                child: Hero(
                  tag: widget.heroTag ?? 'photo-preview',
                  child: InteractiveViewer(
                    transformationController: _transform,
                    minScale: 1,
                    maxScale: 4,
                    child: image,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 12,
              child: _CloseButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(String source) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const _Fallback(),
      );
    }
    return Image.asset(
      source,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const _Fallback(),
    );
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x6615100E),
          border: Border.all(color: const Color(0x2BFFFFFF), width: 0.5),
        ),
        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.ink),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.broken_image_outlined, color: AppColors.inkFaint),
    );
  }
}
