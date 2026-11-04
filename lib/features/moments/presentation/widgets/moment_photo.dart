import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 动态配图：后端给 http(s) URL，设计稿/本地数据给 asset 路径。
/// 加载失败时退回一块中性底色，避免整行布局塌掉。
class MomentPhoto extends StatelessWidget {
  const MomentPhoto({super.key, required this.source, this.cacheWidth});

  final String source;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        errorBuilder: (context, error, stackTrace) => const _PhotoFallback(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const _PhotoFallback(),
      );
    }
    return Image.asset(
      source,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stackTrace) => const _PhotoFallback(),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: AppColors.surfaceRaised);
  }
}
