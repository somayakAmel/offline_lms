import 'package:flutter/material.dart';

/// Bundled course image with a neutral fallback if the asset is missing.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.asset,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  final String asset;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.menu_book_rounded, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
