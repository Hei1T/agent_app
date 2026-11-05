import 'package:flutter/material.dart';

import '../../../../shared/widgets/media_attachment.dart';

/// 动态配图：图片和视频共用媒体解析（/media -> /api/v1/media + token）。
class MomentPhotoView extends StatelessWidget {
  const MomentPhotoView({
    super.key,
    required this.source,
    this.cacheWidth,
    this.fit = BoxFit.cover,
  });

  final String source;
  final int? cacheWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return MediaAttachmentView(
      source: source,
      fit: fit,
      cacheWidth: cacheWidth,
      maxHeight: 520,
      radius: 10,
    );
  }
}
