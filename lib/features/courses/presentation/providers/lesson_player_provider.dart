import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../di/courses_providers.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/progress_service.dart';
import 'home_notifier.dart';

class LessonPlayerState {
  const LessonPlayerState({
    required this.controller,
    required this.completed,
    required this.savedPositionSeconds,
  });

  /// Initialized, positioned at the resume point.
  final VideoPlayerController controller;
  final bool completed;

  /// Last position written to storage; changes after each save.
  final int savedPositionSeconds;

  LessonPlayerState copyWith({bool? completed, int? savedPositionSeconds}) =>
      LessonPlayerState(
        controller: controller,
        completed: completed ?? this.completed,
        savedPositionSeconds: savedPositionSeconds ?? this.savedPositionSeconds,
      );
}

/// Video playback for one lesson, keyed by lesson id. Disposed (and its
/// progress saved) when no screen shows that lesson any more.
final lessonPlayerProvider = AsyncNotifierProvider.autoDispose
    .family<LessonPlayerNotifier, LessonPlayerState, String>(
  LessonPlayerNotifier.new,
  retry: (_, _) => null,
);

/// Loads the lesson video, resumes from the saved position, saves the
/// watched position, and marks the lesson completed at the 90% rule of
/// [ProgressService]. Business rules stay in the domain layer.
class LessonPlayerNotifier extends AsyncNotifier<LessonPlayerState> {
  LessonPlayerNotifier(this.lessonId);

  final String lessonId;

  /// Save at most this often while playing.
  static const int saveEverySeconds = 5;

  late ProgressRepository _repository;
  late ProgressService _progressService;
  late int _durationSeconds;
  VideoPlayerController? _controller;
  AppLifecycleListener? _lifecycle;
  bool _completed = false;
  bool _wasPlaying = false;
  int _lastSavedSeconds = 0;

  @override
  Future<LessonPlayerState> build() async {
    _repository = ref.read(progressRepositoryProvider);
    _progressService = ref.read(progressServiceProvider);
    ref.onDispose(_onDispose);

    final lesson = await _findLesson();
    final saved = await _repository.getLessonProgress(lessonId);
    await _repository.saveLastOpenedLessonId(lessonId);

    final controller = VideoPlayerController.asset(lesson.video);
    _controller = controller;
    await controller.initialize();
    if (!ref.mounted) throw StateError('Player closed while loading');

    final videoSeconds = controller.value.duration.inSeconds;
    _durationSeconds = videoSeconds > 0 ? videoSeconds : lesson.durationSec;
    _completed = saved?.completed ?? false;
    _lastSavedSeconds = saved?.watchedPositionSeconds ?? 0;

    // Resume where the student left off; a finished video restarts.
    final resumeAt = _lastSavedSeconds < _durationSeconds - 1
        ? _lastSavedSeconds
        : 0;
    if (resumeAt > 0) await controller.seekTo(Duration(seconds: resumeAt));
    if (!ref.mounted) throw StateError('Player closed while loading');
    // Opening a lesson without watching must not overwrite its saved
    // position (e.g. with 0 when a finished video restarts).
    _lastSavedSeconds = resumeAt;

    controller.addListener(_onTick);
    _lifecycle = AppLifecycleListener(onPause: save, onHide: save);

    return LessonPlayerState(
      controller: controller,
      completed: _completed,
      savedPositionSeconds: _lastSavedSeconds,
    );
  }

  Future<Lesson> _findLesson() async {
    final home = await ref.read(homeProvider.future);
    for (final overview in home.courses) {
      for (final lesson in overview.course.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    throw StateError('Unknown lesson $lessonId');
  }

  int get _positionSeconds => _controller?.value.position.inSeconds ?? 0;

  void _onTick() {
    final value = _controller?.value;
    if (value == null || !value.isInitialized) return;
    final position = value.position.inSeconds;

    // The platform reports isPlaying=false while it buffers; that is a stall
    // inside continuing playback, not a pause, so it must not trigger work.
    final playing = value.isPlaying || (value.isBuffering && _wasPlaying);

    if (!_completed &&
        _progressService.isLessonCompleted(
          positionSeconds: position,
          durationSeconds: _durationSeconds,
        )) {
      _completed = true;
      save();
    } else if (_wasPlaying && !playing) {
      save();
    } else if (playing &&
        (position - _lastSavedSeconds).abs() >= saveEverySeconds) {
      // Periodic save: storage only, no state change, so nothing rebuilds.
      _lastSavedSeconds = position;
      _persist(position);
    }
    _wasPlaying = playing;
  }

  /// Writes the current position (and completion) and publishes it, so the
  /// screen refreshes lesson statuses and progress. Used on pause,
  /// completion, fullscreen changes and leaving, not while playing.
  Future<void> save() async {
    final position = _positionSeconds;
    final current = state.value;
    if (position != _lastSavedSeconds ||
        _completed != (current?.completed ?? false)) {
      _lastSavedSeconds = position;
      await _persist(position);
    }
    if (!ref.mounted) return;
    final latest = state.value;
    if (latest != null &&
        (latest.savedPositionSeconds != position ||
            latest.completed != _completed)) {
      state = AsyncData(latest.copyWith(
        completed: _completed,
        savedPositionSeconds: position,
      ));
    }
  }

  Future<void> _persist(int position) => _repository.saveLessonProgress(
        LessonProgress(
          lessonId: lessonId,
          watchedPositionSeconds: position,
          completed: _completed,
          updatedAt: DateTime.now(),
        ),
      );

  void _onDispose() {
    _lifecycle?.dispose();
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_onTick);
    if (controller.value.isInitialized) {
      final position = controller.value.position.inSeconds;
      controller.pause();
      if (position != _lastSavedSeconds) _persist(position);
    }
    controller.dispose();
  }
}
