import 'package:flutter/widgets.dart';

class AppLayout {
  AppLayout._();

  /// Content stays this wide at most, centred on tablets.
  static const double maxContentWidth = 640;
  static const double pagePadding = 20;

  /// Space kept free at the bottom of pages for the floating navigation.
  static const double navBarClearance = 104;

  /// Horizontal padding that centres content within [maxContentWidth].
  static EdgeInsets horizontalPadding(double screenWidth) {
    final side = ((screenWidth - maxContentWidth) / 2)
        .clamp(pagePadding, double.infinity);
    return EdgeInsets.symmetric(horizontal: side);
  }
}
