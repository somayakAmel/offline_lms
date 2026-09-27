# Project status and TODO

Tracks every requirement of the screening task (Mini Offline LMS with Video
Player) and what is left. `[x]` = done, `[ ]` = not done yet. Notes under an
item say what is partial or where the code lives.

Last updated: 2026-09-27.

---

## 1. Data (bundled, offline)

- [x] `assets/data/courses.json` with 2 courses, 2 sections each, 2–3 lessons per section
  - Also has a 3rd course with **no lessons** (added on request, to show the empty state).
    The brief asks for 2 courses: explain this in the README.
- [x] 2–3 short MP4 files in `assets/videos/` (under 10 MB each), referenced from the JSON
  - `lesson_1.mp4` (30 s), `lesson_2.mp4` (45 s), `lesson_3.mp4` (60 s): generated with
    ffmpeg (gradient + timer), so no licensing issue. Each lesson's `durationSec`
    matches its clip.
- [x] Course thumbnails in `assets/images/` (generated: anatomy, physiology, pharmacology)
- [x] IDs unique across the catalog (`anatomy-101`, `anatomy-s1`, `anatomy-s1-l1`)
  - Differs from the suggested shape (`s1`, `l1`): explain why in the README.
- [ ] **Course data in both languages (ar + en)**: `courses.json` has Arabic
  text only, so the English UI still shows Arabic course, section and lesson
  titles and instructor names. Add English values for every text field and
  pick the one matching the current locale.

## 2. Courses screen

- [x] List of courses: thumbnail, title, instructor, lesson count, progress %
- [x] "Continue watching" card at the top when there is an unfinished lesson
- [x] Loading (skeleton), empty and error (with Retry) states
- [x] Tapping a card opens Course Details

## 3. Course details screen

- [x] Sections and lessons, each lesson with its duration
- [x] Lesson status: not started / in progress (%) / completed / locked
- [x] Sequential unlock: locked until the previous lesson is completed
- [x] Tapping a locked lesson shows a friendly message
- [x] Stats row (sections, lessons, total duration) and course progress
- [x] Empty state for a course with no lessons
- [x] Note icon on every lesson (outline = no note, filled = has note; see bonus "notes")
- [x] Course image / lesson video is the top section: edge to edge behind the
  status bar, floating back button, speed button on the opposite corner

## 4. Lesson player

The player is **inside Course Details** (the top media area), not a separate
screen. Explain this choice in the README.

- [x] Play / pause, seek bar, current time and duration (Chewie controls)
- [x] Playback speed 1x / 1.25x / 1.5x / 2x
- [x] Fullscreen with landscape; orientation restored on exit
- [x] Resume from the last watched position
- [x] Lesson completed automatically at 90% watched (`ProgressService.isLessonCompleted`)
- [x] "Next lesson" button that respects the unlock rule
- [x] Last lesson: shows "course finished" instead of a misleading Next button
- [x] Auto-pause bug investigated and fixed (buffering was treated as a pause)
- [x] Missing/corrupt video error state (`_PlayerError` + Retry), verified on a device
- [x] Manual test pass by the user: play, seek, speeds, fullscreen, resume, 90%,
  next lesson, rapid lesson switching, leaving while playing

## 5. Local persistence

- [x] Progress (positions, completed lessons) survives an app restart: **sqflite**
  - Tables: `lesson_progress`, `lesson_notes`, `app_state` (last opened lesson).
  - Completion never goes back to incomplete (`ProgressRepositoryImpl`).
- [ ] **Justify the storage choice (sqflite) in the README**

## 6. Arabic-first and RTL

- [x] Arabic UI with RTL layout (icons, paddings, progress bars fill from the right)
- [x] Arabic plurals (`trPlural`: درس واحد / درسان / 3 دروس / 11 درسًا)
- [x] Video controls kept left-to-right (standard for media timelines)
  - Explain in the README: the brief says "seek bar direction make sense".
- [x] Bonus: Arabic/English switch (Profile page, saved in SharedPreferences)
- [x] English UI checked end to end (layout, LTR, every UI string translated)
  - Only the course data is still Arabic in English: see section 1.

## 7. States and errors (no red screens)

- [x] Loading, empty and error states on Home and Course Details
- [x] Course not found, course with no lessons
- [x] Missing/corrupt video: friendly error with Retry (see section 4)

## 8. Tests

Scope: only the three unit tests required by the brief, in one file:
`test/features/courses/domain/progress_service_test.dart` (11 tests, all
passing). It tests `ProgressService` directly: no UI, database, Riverpod or
video player.

- [x] 90% completion rule (3 tests: 53/60 not completed, 54/60 and 60/60
  completed, zero duration never completed)
- [x] Lesson unlock rule (5 tests: first lesson open, locked while the previous
  is not completed or only half watched, unlocks after completion, lesson 1
  doesn't unlock lesson 3, order continues across sections)
- [x] Progress percentage calculation (3 tests: 1 of 3 completed = 33% with a
  half-watched lesson adding nothing, all completed = 100%, no lessons = 0%)
- [x] Old GetIt-era tests (which no longer compiled) removed
- [x] Widget, repository, database and notes tests removed on purpose to keep
  the scope to the brief's requirement

## 9. Technical expectations

- [x] Flutter stable, null-safe
- [x] Riverpod, used consistently (GetIt and flutter_bloc were removed)
- [x] Separation of data / domain / presentation
  - Domain has no Flutter imports; presentation only sees domain types;
    `core` doesn't depend on features.
- [x] video_player + chewie
- [x] go_router

## 10. Bonus (optional)

- [x] Dark mode: System / Light / Dark switch in Profile (`themeModeProvider`)
- [ ] Search courses
- [x] Per-lesson notes saved locally (SQLite `lesson_notes`)
  - Bottom sheet editor, explicit Save, discard confirmation, clearing a note
    deletes it. Notes are for unlocked lessons only.
- [ ] Remember the last playback speed
- [ ] Widget tests

## 11. Deliverables

- [x] GitHub repository: https://github.com/somayakAmel/offline_lms
- [x] Video player, Profile, Notes and top-section work committed and pushed
- [x] Tests committed and pushed (see section 8)
- [ ] **README** covering:
  - [ ] How to run the app
  - [ ] Architecture and state management (Riverpod), and why
  - [ ] Storage choice (sqflite) and why
  - [ ] Trade-offs and known issues:
    - 3rd course without lessons
    - player inside Course Details instead of a separate screen
    - LTR seek bar
    - simulated 1.5 s loading delay for the bundled catalog
    - emulator buffering in debug mode
  - [ ] What I'd do with more time
  - [ ] Roughly how long I spent
- [ ] **2–3 minute screen recording or an APK**

---

## Next steps (code; deliverables are tracked in section 11)

1. **Course data in both languages**: add English values to `courses.json`
   (course title, instructor, section and lesson titles) and show the one for
   the current locale.
2. **Bonus, if time allows**: remember the last playback speed, then course
   search.

---

## Working notes (for whoever continues)

- **Structure**
  - `lib/src/`: `app/` (App, bootstrap, router, shell) and `core/` (DI providers,
    database, localization, theme, `core/router/app_routes.dart`,
    `core/functions/duration_format.dart`).
  - `lib/features/courses/`: `data/`, `domain/` (entities, repositories,
    `services/progress_service.dart`), `di/courses_providers.dart`,
    `presentation/`.
- **Business rules live only in `ProgressService`**: 90% completion, lesson
  status, unlock, lesson/course progress. Don't duplicate them in widgets or
  providers.
- **Player**
  - `lessonPlayerProvider` (per lesson, auto-disposed) owns the `VideoPlayerController`
    and progress saving.
  - `LessonPlayerView` owns the `ChewieController` (UI, localized).
  - Buffering is not a pause.
  - The speed button is ours (`_Controls` in `lesson_player_view.dart`);
    Chewie's own options button is off because it sat under the RTL back button.
- **Notes**: `lessonNoteProvider` (sheet) and `lessonIdsWithNotesProvider`
  (icons, one SQLite query). Saving a note refreshes only the icons, never
  course details or the player.
- **Strings**: add keys to `ar.json`, `en.json` and `StringsManager`. Watch for
  trailing commas when removing the last JSON entry.
- **Git**
  - No Claude/AI attribution in commit messages.
  - Don't commit `.claude/`.
- **Windows machine**
  - C: is often full, which breaks Gradle, `flutter run` and the emulator.
  - `kotlin.incremental=false` is set in `android/gradle.properties`, because the
    pub cache (C:) and the project (D:) are on different drives.
- **Tests**: run `flutter test test/features/courses/domain/progress_service_test.dart`.
  Keep new tests to plain domain logic unless the scope changes.
