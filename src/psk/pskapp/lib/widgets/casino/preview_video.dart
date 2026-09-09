import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A muted, looping, inline demo clip with a poster fallback.
///
/// The website relies on `<video muted loop playsInline>`; this is the Flutter
/// equivalent. On platforms where the video plugin is unavailable (or when the
/// asset fails to load) the poster stays on screen and nothing breaks.
class PreviewVideo extends StatefulWidget {
  final String asset;
  final String poster;
  final bool playing;
  final BoxFit fit;

  const PreviewVideo({
    super.key,
    required this.asset,
    required this.poster,
    required this.playing,
    this.fit = BoxFit.cover,
  });

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.playing) _ensureController();
  }

  @override
  void didUpdateWidget(covariant PreviewVideo old) {
    super.didUpdateWidget(old);
    if (old.asset != widget.asset) {
      _dispose();
      _ready = false;
      _failed = false;
    }
    if (widget.playing) {
      _ensureController();
      if (_ready) _controller?.play();
    } else {
      _controller?.pause();
      _controller?.seekTo(Duration.zero);
    }
  }

  Future<void> _ensureController() async {
    if (_controller != null || _failed) return;
    final c = VideoPlayerController.asset(widget.asset);
    _controller = c;
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      if (!mounted) return;
      setState(() => _ready = true);
      if (widget.playing) await c.play();
    } catch (_) {
      // plugin missing (desktop) or asset unreadable — keep the poster
      if (mounted) setState(() => _failed = true);
      _dispose();
    }
  }

  void _dispose() {
    final c = _controller;
    _controller = null;
    c?.dispose();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showVideo = widget.playing && _ready && _controller != null;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(widget.poster, fit: widget.fit, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        AnimatedOpacity(
          opacity: showVideo ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: showVideo
              ? FittedBox(
                  fit: widget.fit,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
