import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import 'full_screen_photo_preview.dart';

const _videoExtensions = ['.mp4', '.mov', '.webm', '.m4v', '.avi', '.mkv'];

bool isVideoSource(String source) {
  final path = Uri.tryParse(source)?.path.toLowerCase() ?? source.toLowerCase();
  return _videoExtensions.any(path.endsWith);
}

/// 统一媒体渲染：/media 相对地址 -> 业务层 /api/v1/media，带登录 token。
/// 图片点开全屏；视频内联播放并可全屏。
class MediaAttachmentView extends ConsumerWidget {
  const MediaAttachmentView({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.maxHeight = 260,
    this.radius = 8,
  });

  final String source;
  final BoxFit fit;
  final int? cacheWidth;
  final double maxHeight;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiProvider);
    final url = api.resolveMediaUrl(source);
    if (url == null) {
      return Image.asset(
        source,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => const _MediaFallback(),
      );
    }
    final rounded = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: isVideoSource(url)
          ? NetworkVideoView(
              url: url,
              headers: api.imageHeaders,
              maxHeight: maxHeight,
            )
          : Image.network(
              url,
              fit: fit,
              cacheWidth: cacheWidth,
              headers: api.imageHeaders,
              errorBuilder: (_, _, _) => const _MediaFallback(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const _MediaFallback(),
            ),
    );
    return GestureDetector(
      onTap: () {
        if (isVideoSource(url)) {
          showFullScreenVideo(context, url: url, headers: api.imageHeaders);
        } else {
          showFullScreenPhotoPreview(context, source);
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: rounded,
      ),
    );
  }
}

class NetworkVideoView extends StatefulWidget {
  const NetworkVideoView({
    super.key,
    required this.url,
    this.headers,
    this.maxHeight = 260,
  });

  final String url;
  final Map<String, String>? headers;
  final double maxHeight;

  @override
  State<NetworkVideoView> createState() => _NetworkVideoViewState();
}

class _NetworkVideoViewState extends State<NetworkVideoView> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: widget.headers ?? const {},
    );
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(false);
      setState(() => _controller = controller);
    } catch (_) {
      await controller.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const _MediaFallback(icon: Icons.videocam_off_outlined);
    final controller = _controller;
    if (controller == null) {
      return const _MediaFallback(icon: Icons.play_circle_outline);
    }
    final ratio = controller.value.aspectRatio <= 0
        ? 16 / 9
        : controller.value.aspectRatio;
    return AspectRatio(
      aspectRatio: ratio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              child: AnimatedOpacity(
                opacity: controller.value.isPlaying ? 0 : 1,
                duration: const Duration(milliseconds: 160),
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 52,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.tint,
                bufferedColor: Colors.white38,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({this.icon = Icons.image_outlined});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ColoredBox(
        color: AppColors.surfaceRaised,
        child: Center(child: Icon(icon, color: AppColors.inkFaint, size: 28)),
      ),
    );
  }
}

Future<void> showFullScreenVideo(
  BuildContext context, {
  required String url,
  Map<String, String>? headers,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: NetworkVideoView(
                url: url,
                headers: headers,
                maxHeight: double.infinity,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
