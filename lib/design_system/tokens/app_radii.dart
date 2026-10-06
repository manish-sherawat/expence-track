import 'package:flutter/widgets.dart';

/// Corner radius tokens.
class AppRadii {
  const AppRadii._();

  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r14 = 14.0;
  static const double r16 = 16.0;
  static const double r18 = 18.0;
  static const double r20 = 20.0;
  static const double r22 = 22.0;
  static const double rFull = 999.0;

  // Semantic Radii
  static const Radius radius4 = Radius.circular(r4);
  static const Radius radius6 = Radius.circular(r6);
  static const Radius radius8 = Radius.circular(r8);
  static const Radius radius12 = Radius.circular(r12);
  static const Radius radius16 = Radius.circular(r16);
  static const Radius radius18 = Radius.circular(r18);
  static const Radius radius20 = Radius.circular(r20);
  static const Radius radius22 = Radius.circular(r22);
  static const Radius radiusFull = Radius.circular(rFull);

  static const BorderRadius border4 = BorderRadius.all(radius4);
  static const BorderRadius border6 = BorderRadius.all(radius6);
  static const BorderRadius border8 = BorderRadius.all(radius8);
  static const BorderRadius border12 = BorderRadius.all(radius12);
  static const BorderRadius border16 = BorderRadius.all(radius16);
  static const BorderRadius border18 = BorderRadius.all(radius18);
  static const BorderRadius border20 = BorderRadius.all(radius20);
  static const BorderRadius border22 = BorderRadius.all(radius22);
  static const BorderRadius borderFull = BorderRadius.all(radiusFull);

  // Component-specific
  static const BorderRadius card = border20;
  static const BorderRadius cardLarge = border22;
  static const BorderRadius fullPill = borderFull;
  static const BorderRadius pill = borderFull;
  static const BorderRadius innerBalanceCard = border18;
  static const BorderRadius outerBalanceContainer = border22;
  static const BorderRadius categoryCard = border18;
  static const BorderRadius banner = border16;
  static const BorderRadius circle = borderFull;
  static const BorderRadius receiptThumb = border6;
}
