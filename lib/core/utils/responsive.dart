import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1000;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletBreakpoint;

  static int quickDurationColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _desktopBreakpoint) return 5;
    if (width >= _tabletBreakpoint) return 4;
    return 3;
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _desktopBreakpoint ? 720 : width;
  }
}
