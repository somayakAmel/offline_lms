# Offline LMS

A small, fully offline version of a student learning app for health-sciences

courses. Students browse courses, watch video lessons in order, and pick up

where they left off. The app is Arabic-first (RTL), with an English option.

It has no backend and makes no network calls: everything comes from bundled

assets and local storage.

## Features

- **Courses screen:** each course shows its thumbnail, title, instructor,

  lesson count and progress %. A **Continue watching** card at the top reopens

  the last unfinished lesson.

- **Course details:** sections and lessons with durations, and a status on each

  lesson (not started / in progress % / completed / locked). **Sequential

  unlock:** a lesson opens only when the one before it is completed; tapping a

  locked lesson shows a friendly message.

- **Lesson player:**

  - play/pause, seek bar, current time and duration;

  - speeds 1x / 1.25x / 1.5x / 2x;

  - fullscreen in landscape;

  - **resumes** from the last watched position;

  - **completed automatically at 90%**;

  - a **Next lesson** button that respects the unlock rule.

- **Local persistence:** positions, completed lessons and the last opened lesson

  survive an app restart (SQLite).

- **Arabic-first RTL** layout, with an **Arabic/English switch**.

- **States and errors:** loading, empty (a course with no lessons, no search

  results) and error states, including a missing or corrupt video file, all

  with friendly messages and Retry where it helps. No red screens.

- **Unit tests** for the three progress rules.

- Dark mode (System / Light / Dark, saved).

- Search courses by name. It ignores Arabic diacritics and letter variants,

  so "مقدمه" finds "مقدمة".

- Per-lesson notes saved locally (add, edit, delete).