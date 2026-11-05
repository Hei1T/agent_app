import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';

/// 动态配图：契约 URL 可以直接是 http(s)，也可以是后端 /media/...。
/// 相对媒体路径经 ApiClient 解析成业务层 /api/v1/media/...，并带登录 token。
class MomentPhotoView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiProvider);
    final url = api.resolveMediaUrl(source);
    if (url != null) {
      return Image.network(
        url,
        fit: fit,
        cacheWidth: cacheWidth,
        headers: api.imageHeaders,
        errorBuilder: (context, error, stackTrace) => const _PhotoFallback(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const _PhotoFallback(),
      );
    }
    return Image.asset(
      source,
      fit: fit,
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
