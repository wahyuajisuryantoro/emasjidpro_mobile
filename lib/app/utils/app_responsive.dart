import 'package:flutter/material.dart';

class AppResponsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  
  // Safe Area
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  // Device Type
  static late bool isMobile;
  static late bool isTablet;
  static late bool isDesktop;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    // Set device type
    isMobile = screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 1200;
    isDesktop = screenWidth >= 1200;
  }

  // Get responsive size
  static double getResponsiveSize(double size) {
    double screenSize = screenWidth;
    if (isDesktop) {
      screenSize = screenSize * 0.5;
    } else if (isTablet) {
      screenSize = screenSize * 0.75; 
    }
    return (size / 375) * screenSize;
  }

  // Responsive width
  static double w(double width) {
    return blockSizeHorizontal * width;
  }

  // Responsive height
  static double h(double height) {
    return blockSizeVertical * height;
  }

  // Safe area width
  static double sw(double width) {
    return safeBlockHorizontal * width;
  }

  // Safe area height
  static double sh(double height) {
    return safeBlockVertical * height;
  }

  // Responsive font size
  static double sp(double size) {
    return getResponsiveSize(size);
  }

  // Responsive padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: w(left ?? horizontal ?? all ?? 0),
      top: h(top ?? vertical ?? all ?? 0),
      right: w(right ?? horizontal ?? all ?? 0),
      bottom: h(bottom ?? vertical ?? all ?? 0),
    );
  }

  // Responsive margin
  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: w(left ?? horizontal ?? all ?? 0),
      top: h(top ?? vertical ?? all ?? 0),
      right: w(right ?? horizontal ?? all ?? 0),
      bottom: h(bottom ?? vertical ?? all ?? 0),
    );
  }

  // Get screen type
  static String getScreenType() {
    if (isDesktop) return 'Desktop';
    if (isTablet) return 'Tablet';
    return 'Mobile';
  }

  // Check orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}