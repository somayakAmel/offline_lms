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
        (player) =>
            (player.value?.controller, player.hasError, player.isLoading),
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
      // Chewie's options button is pinned top-right, where the back button
      // floats in RTL; speed gets its own button on the other side.
      showOptions: false,
      customControls: _Controls(
        appDirection: Directionality.of(context),
        onSpeedTap: _pickSpeed,
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

  /// [context] is where the button was tapped: inline or the fullscreen
  /// route, so the sheet opens above whichever is showing.
  Future<void> _pickSpeed(BuildContext context, TextDirection direction) async {
    final controller = widget.controller;
    final speed = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => Directionality(
        textDirection: direction,
        child: _SpeedSheet(
          speeds: _speeds,
          current: controller.value.playbackSpeed,
        ),
      ),
    );
    if (speed != null) await controller.setPlaybackSpeed(speed);
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
    // Media controls keep the universal left-to-right timeline.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Chewie(controller: _chewie!),
    );
  }
}

/// Chewie's material controls plus the speed button, used inline and in
/// fullscreen. The button sits at the app's "end" corner, away from the
/// back button.
class _Controls extends StatelessWidget {
  const _Controls({required this.appDirection, required this.onSpeedTap});

  final TextDirection appDirection;
  final void Function(BuildContext context, TextDirection direction) onSpeedTap;

  @override
  Widget build(BuildContext context) {
    final onLeft = appDirection == TextDirection.rtl;
    final controller = ChewieController.of(context).videoPlayerController;
    return Stack(
      fit: StackFit.expand,
      children: [
        const MaterialControls(),
        Positioned(
          top: 8,
          left: onLeft ? 8 : null,
          right: onLeft ? null : 8,
          child: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, _) => _SpeedButton(
                speed: value.playbackSpeed,
                onTap: () => onSpeedTap(context, appDirection),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.speed, required this.onTap});

  final double speed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: StringsManager.playbackSpeed.tr(context),
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  _speedLabel(speed),
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _speedLabel(double speed) =>
    '${speed == speed.roundToDouble() ? speed.toInt() : speed}x';

/// Picks one of [speeds]; pops with the chosen value.
class _SpeedSheet extends StatelessWidget {
  const _SpeedSheet({required this.speeds, required this.current});

  final List<double> speeds;
  final double current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              StringsManager.playbackSpeed.tr(context),
              style: theme.textTheme.titleMedium,
            ),
          ),
          for (final speed in speeds)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                _speedLabel(speed),
                // Numbers read left-to-right even in Arabic.
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                style: speed == current
                    ? theme.textTheme.bodyLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      )
                    : theme.textTheme.bodyLarge,
              ),
              trailing: speed == current
                  ? Icon(Icons.check_rounded, color: accent)
                  : null,
              onTap: () => Navigator.of(context).pop(speed),
            ),
          const SizedBox(height: 8),
        ],
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
            const Icon(
              Icons.videocam_off_outlined,
              size: 40,
              color: Colors.white70,
            ),
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
