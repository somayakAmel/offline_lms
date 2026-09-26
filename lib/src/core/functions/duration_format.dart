// Unicode left-to-right isolate, so "01:05" is not reordered in RTL text.
final String _ltrStart = String.fromCharCode(0x2066);
final String _ltrEnd = String.fromCharCode(0x2069);

/// `mm:ss`, or `h:mm:ss` from one hour, always left-to-right.
String formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String two(int value) => value.toString().padLeft(2, '0');
  final text = hours > 0
      ? '$hours:${two(minutes)}:${two(seconds)}'
      : '${two(minutes)}:${two(seconds)}';
  return '$_ltrStart$text$_ltrEnd';
}
