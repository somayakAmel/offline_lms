/// App name and translation keys.
/// Every key here must exist in each `translations/<languageCode>.json`.
class StringsManager {
  StringsManager._();

  static const String appName = 'Offline LMS';

  static const String clear = 'clear';
  static const String done = 'done';
  static const String tryAgain = 'tryAgain';
  static const String retry = 'retry';
  static const String error = 'error';
  static const String success = 'success';
  static const String warning = 'warning';
  static const String cancel = 'cancel';
  static const String next = 'next';
  static const String search = 'search';
  static const String somethingWentWrong = 'somethingWentWrong';
  static const String noResultsFound = 'noResultsFound';

  static const String splashTagline = 'splashTagline';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String welcomeTitle = 'welcomeTitle';
  static const String continueWatching = 'continueWatching';
  static const String resumeLesson = 'resumeLesson';

  /// Contains `{position}` and `{duration}`.
  static const String watchedOf = 'watchedOf';
  static const String courses = 'courses';

  /// Plural key: use with `trPlural`.
  static const String lessons = 'lessons';
  static const String completed = 'completed';
  static const String coursesLoadErrorTitle = 'coursesLoadErrorTitle';
  static const String coursesLoadErrorMessage = 'coursesLoadErrorMessage';
  static const String noCoursesTitle = 'noCoursesTitle';
  static const String noCoursesMessage = 'noCoursesMessage';
  static const String profilePlaceholder = 'profilePlaceholder';
  static const String lessonPlayerUnavailable = 'lessonPlayerUnavailable';
  static const String courseDetailsUnavailable = 'courseDetailsUnavailable';
}
