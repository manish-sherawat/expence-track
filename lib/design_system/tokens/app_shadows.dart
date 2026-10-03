import 'package:flutter/widgets.dart';

/// Shadow tokens for subtle, layered elevation.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 2.0,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 18.0,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> floatingNav = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 30.0,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> circleButton = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 2.0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> segmentedThumb = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> none = [];
}
