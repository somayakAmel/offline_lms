import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../providers/lesson_player_provider.dart';

/// The lesson video with Chewie controls, or its loading/error state.
class LessonPlayerView extends ConsumerWidget {
  const LessonPlayerView({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only what this widget shows: saving progress changes the provider's
    // state but must never rebuild (or disturb) the player.
    final (controller, hasError, isLoading) = ref.watch(
      lessonPlayerProvider(lessonId).select(
        (player) => (player.value?.controller, player.hasError, player.isLoading),
      ),
    );
    final Widget child;
    if (controller != null) {
      child = _ChewiePlayer(
        controller: controller,
        onFullScreenChanged: () =>
            ref.read(lessonPlayerProvider(lessonId).notifier).save(),
      );
    } else if (hasError && !isLoading) {
      child = _PlayerError(
        onRetry: () => ref.invalidate(lessonPlayerProvider(lessonId)),
      );
    } else {
      child = const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return ColoredBox(color: Colors.black, child: child);
  }
}

/// Chewie is UI, so its controller lives here; the video controller (and
/// the lesson's progress) belong to [lessonPlayerProvider].
class _ChewiePlayer extends StatefulWidget {
  const _ChewiePlayer({
    required this.controller,
    required this.onFullScreenChanged,
  });

  final VideoPlayerController controller;
  final VoidCallback onFullScreenChanged;

  @override
  State<_ChewiePlayer> createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<_ChewiePlayer> {
  ChewieController? _chewie;
  bool _wasFullScreen = false;

  static const List<double> _speeds = [1, 1.25, 1.5, 2];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chewie ??= _create();
  }

  @override
  void didUpdateWidget(_ChewiePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _disposeChewie();
      _chewie = _create();
    }
  }

  ChewieController _create() {
    final scheme = Theme.of(context).colorScheme;
    final chewie = ChewieController(
      videoPlayerController: widget.controller,
      autoPlay: true,
      aspectRatio: widget.controller.value.aspectRatio,
      playbackSpeeds: _speeds,
      optionsTranslation: OptionsTranslation(
        playbackSpeedButtonText: StringsManager.playbackSpeed.tr(context),
        cancelButtonText: StringsManager.cancel.tr(context),
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: scheme.primary,
        handleColor: scheme.primary,
        bufferedColor: Colors.white38,
        backgroundColor: Colors.white24,
      ),
      // Landscape while fullscreen, then back to any orientation.
      deviceOrientationsOnEnterFullScreen: const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: DeviceOrientation.values,
      errorBuilder: (context, message) => _PlayerError(onRetry: null),
    );
    chewie.addListener(_onChewieChanged);
    return chewie;
  }

  void _onChewieChanged() {
    final isFullScreen = _chewie?.isFullScreen ?? false;
    if (isFullScreen != _wasFullScreen) {
      _wasFullScreen = isFullScreen;
      widget.onFullScreenChanged();
    }
  }

  void _disposeChewie() {
    final chewie = _chewie;
    _chewie = null;
    if (chewie == null) return;
    chewie.removeListener(_onChewieChanged);
    // Leaving the screen from fullscreen must not keep landscape locked.
    if (chewie.isFullScreen) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    chewie.dispose();
  }

  @override
  void dispose() {
    _disposeChewie();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Chewie marks the selected speed in the primary colour, which is too
    // pale on light sheets; use the stronger accent inside the player.
    return Theme(
      data: theme.copyWith(
        colorScheme:
            theme.colorScheme.copyWith(primary: theme.colorScheme.secondary),
      ),
      // Media controls keep the universal left-to-right timeline.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Chewie(controller: _chewie!),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined,
                size: 40, color: Colors.white70),
            const SizedBox(height: 10),
            Text(
              StringsManager.videoLoadErrorTitle.tr(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              StringsManager.videoLoadErrorMessage.tr(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(StringsManager.retry.tr(context)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
