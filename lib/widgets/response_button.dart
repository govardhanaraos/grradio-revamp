import 'package:flutter/cupertino.dart';

/// Responsive sizing helpers based on screen width (breakpoint-style).
class RButton {
  static double screenWidth = 600.0;

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static void initialize(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
  }

  static double getBaseSize() {
    if (screenWidth < mobileBreakpoint) {
      return 55.0;
    } else if (screenWidth < tabletBreakpoint) {
      return 60.0;
    } else {
      return 64.0;
    }
  }

  static double getHorizontalPadding() {
    final double baseSize = getBaseSize();
    return baseSize * 1.5;
  }

  static double getVerticalPadding() {
    final double baseSize = getBaseSize();
    return baseSize * 0.8;
  }

  static double getSmallButtonSize() => getBaseSize() * 0.8;
  static double getMediumButtonSize() => getBaseSize();
  static double getLargeButtonSize() => getBaseSize() * 1.2;
  static double getXLargeButtonSize() => getBaseSize() * 1.5;

  static double getSmallIconSize() => getBaseSize() * 0.5;
  static double getMediumIconSize() => getBaseSize() * 0.7;
  static double getLargeIconSize() => getBaseSize() * 0.9;
  static double getXLargeIconSize() => getBaseSize() * 1.1;

  static double getSmallContainerSize() => getBaseSize() * 1.0;
  static double getMediumContainerSize() => getBaseSize() * 1.3;
  static double getLargeContainerSize() => getBaseSize() * 1.6;
  static double getXLargeContainerSize() => getBaseSize() * 2.0;

  static double getSmallImageSize() => getBaseSize() * 0.8;
  static double getMediumImageSize() => getBaseSize() * 1.2;
  static double getLargeImageSize() => getBaseSize() * 1.8;
  static double getXLargeImageSize() => getBaseSize() * 2.5;
  static double getXXLargeImageSize() => getBaseSize() * 3.6;

  static double getExSmallFontSize() => getBaseSize() * 0.20;
  static double getSmallFontSize() => getBaseSize() * 0.25;
  static double getMediumFontSize() => getBaseSize() * 0.3;
  static double getLargeFontSize() => getBaseSize() * 0.4;
  static double getXLargeFontSize() => getBaseSize() * 0.5;
  static double getXXLargeFontSize() => getBaseSize() * 0.6;

  static double getSmallBorderRadius() => getBaseSize() * 0.1;
  static double getMediumBorderRadius() => getBaseSize() * 0.15;
  static double getLargeBorderRadius() => getBaseSize() * 0.2;

  static double getSmallSpacing() => getBaseSize() * 0.1;
  static double getMediumSpacing() => getBaseSize() * 0.2;
  static double getLargeSpacing() => getBaseSize() * 0.3;
  static double getXLargeSpacing() => getBaseSize() * 0.4;
  static double getXXLargeSpacing() => getBaseSize() * 0.6;

  static double getAppBarHeight() => getBaseSize() * 1.1;
  static double getAppBarIconSize() => getBaseSize() * 0.6;

  static double getMiniPlayerHeight() => getBaseSize() * 1.2;
  static double getExpandedPlayerHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.7;

  static double getControlButtonSize() => getBaseSize() * 1.1;
  static double getControlIconSize() => getBaseSize() * 0.9;
  static double getMainControlButtonSize() => getBaseSize() * 1.3;
  static double getMainControlIconSize() => getBaseSize() * 1.1;

  static double getActionButtonSize() => getBaseSize() * 1.0;
  static double getActionIconSize() => getBaseSize() * 0.5;

  static double getListItemHeight() => getBaseSize() * 0.9;
  static double getListIconSize() => getBaseSize() * 0.4;

  static T responsiveValue<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (screenWidth < mobileBreakpoint) {
      return mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return tablet;
    } else {
      return desktop;
    }
  }
}
