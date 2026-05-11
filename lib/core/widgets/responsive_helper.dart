import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎯 نظام Responsive & Adaptive محسّن للمقاسات
/// ═══════════════════════════════════════════════════════════════════════════
/// يوفر نظام شامل للتحكم في المقاسات عبر جميع أحجام الشاشات
/// مع ضبط دقيق للموبايل لتجنب العناصر الكبيرة
/// ═══════════════════════════════════════════════════════════════════════════
class ResponsiveHelper {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double _safeBlockHorizontal;
  static late double _safeBlockVertical;

  // ═══════════════════════════════════════════════════════════════════════
  // 📐 تهيئة الأبعاد
  // ═══════════════════════════════════════════════════════════════════════
  static void init(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    _safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    _safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    _safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    _safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 معلومات الشاشة
  // ═══════════════════════════════════════════════════════════════════════
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static double get screenDiagonal =>
      math.sqrt(_screenWidth * _screenWidth + _screenHeight * _screenHeight);
  static double get shortestSide => math.min(_screenWidth, _screenHeight);
  static double get longestSide => math.max(_screenWidth, _screenHeight);

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Scale Factor المحسّن (أصغر للموبايل)
  // ═══════════════════════════════════════════════════════════════════════
  /// iPhone 11 Pro (375px) كأساس - مع clamping محسّن
  static double get textScale {
    const baseWidth = 375.0; // iPhone 11 Pro
    double scale = _screenWidth / baseWidth;

    // تقليل Scale للشاشات الصغيرة جداً
    if (_screenWidth < 360) {
      scale *= 0.90; // تصغير إضافي للشاشات الصغيرة جداً
    }

    // تطبيق حدود معقولة
    return scale.clamp(0.75, 1.3);
  }

  /// Scale محسّن للمسافات (أصغر من النصوص)
  static double get spaceScale {
    const baseWidth = 375.0;
    double scale = _screenWidth / baseWidth;
    return scale.clamp(0.7, 1.2); // حدود أضيق للمسافات
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 أحجام الخطوط المحسّنة (أصغر للموبايل)
  // ═══════════════════════════════════════════════════════════════════════
  // الخطوط الأساسية - body text
  static double get fontTiny => 9 * textScale;      // للملاحظات الصغيرة جداً
  static double get fontSmall => 11 * textScale;    // للنصوص الثانوية
  static double get fontMedium => 13 * textScale;   // الحجم الأساسي
  static double get fontLarge => 14 * textScale;    // نصوص مهمة
  static double get fontXLarge => 15 * textScale;   // نصوص بارزة

  // العناوين - headings
  static double get fontHeadingSmall => 16 * textScale;   // عناوين صغيرة
  static double get fontHeadingMedium => 18 * textScale;  // عناوين متوسطة
  static double get fontHeadingLarge => 20 * textScale;   // عناوين كبيرة
  static double get fontHeadingXLarge => 22 * textScale;  // عناوين رئيسية
  static double get fontDisplay => 24 * textScale;        // عناوين شاشات

  // ═══════════════════════════════════════════════════════════════════════
  // 📏 المسافات (Spacing) - مصغّرة 51% من الأصل
  // ═══════════════════════════════════════════════════════════════════════
  static double get spaceXXTiny => 0.98 * spaceScale;    // 2 * 0.49
  static double get spaceXTiny => 1.96 * spaceScale;     // 4 * 0.49
  static double get spaceTiny => 2.94 * spaceScale;      // 6 * 0.49
  static double get spaceSmall => 3.92 * spaceScale;     // 8 * 0.49
  static double get spaceMedium => 5.88 * spaceScale;    // 12 * 0.49
  static double get spaceLarge => 7.84 * spaceScale;     // 16 * 0.49
  static double get spaceXLarge => 9.8 * spaceScale;     // 20 * 0.49
  static double get spaceXXLarge => 11.76 * spaceScale;  // 24 * 0.49
  static double get spaceHuge => 15.68 * spaceScale;     // 32 * 0.49
  static double get spaceXXXLarge => 19.6 * spaceScale;  // 40 * 0.49

  // مسافات محددة للاستخدامات الشائعة
  static double get cardPadding => 5.88 * spaceScale;      // 12 * 0.49
  static double get screenPadding => 7.84 * spaceScale;    // 16 * 0.49
  static double get sectionSpacing => 9.8 * spaceScale;    // 20 * 0.49
  static double get itemSpacing => 3.92 * spaceScale;      // 8 * 0.49

  // ═══════════════════════════════════════════════════════════════════════
  // 🎭 Border Radius - مصغّرة 51% من الأصل
  // ═══════════════════════════════════════════════════════════════════════
  static double get radiusXSmall => 1.96 * spaceScale;     // 4 * 0.49
  static double get radiusSmall => 3.92 * spaceScale;      // 8 * 0.49
  static double get radiusMedium => 5.88 * spaceScale;     // 12 * 0.49
  static double get radiusLarge => 7.84 * spaceScale;      // 16 * 0.49
  static double get radiusXLarge => 9.8 * spaceScale;      // 20 * 0.49
  static double get radiusXXLarge => 11.76 * spaceScale;   // 24 * 0.49
  static double get radiusFull => 999;

  // Radius لمكونات محددة
  static double get cardRadius => 5.88 * spaceScale;       // 12 * 0.49
  static double get buttonRadius => 4.9 * spaceScale;      // 10 * 0.49
  static double get inputRadius => 4.9 * spaceScale;       // 10 * 0.49
  static double get dialogRadius => 7.84 * spaceScale;     // 16 * 0.49

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 أحجام الأيقونات - مكبرة مرة أخرى (× 1.96 من الحجم المصغر)
  // ═══════════════════════════════════════════════════════════════════════
  static double get iconXSmall => 11.52 * textScale;     // 5.88 * 1.96
  static double get iconSmall => 15.37 * textScale;      // 7.84 * 1.96
  static double get iconMedium => 19.21 * textScale;     // 9.8 * 1.96
  static double get iconLarge => 23.05 * textScale;      // 11.76 * 1.96
  static double get iconXLarge => 26.89 * textScale;     // 13.72 * 1.96
  static double get iconXXLarge => 30.73 * textScale;    // 15.68 * 1.96
  static double get iconHuge => 46.10 * textScale;       // 23.52 * 1.96

  // أيقونات لأماكن محددة
  static double get iconButton => 19.21 * textScale;     // 9.8 * 1.96
  static double get iconAppBar => 21.13 * textScale;     // 10.78 * 1.96
  static double get iconBottomNav => 21.13 * textScale;  // 10.78 * 1.96

  // ═══════════════════════════════════════════════════════════════════════
  // 🔘 أحجام الأزرار - مصغّرة 51% من الأصل
  // ═══════════════════════════════════════════════════════════════════════
  static double get buttonHeightSmall => 17.64 * textScale;   // 36 * 0.49
  static double get buttonHeightMedium => 21.56 * textScale;  // 44 * 0.49
  static double get buttonHeightLarge => 25.48 * textScale;   // 52 * 0.49
  static double get buttonMinWidth => 43.12 * textScale;      // 88 * 0.49

  // Button padding
  static EdgeInsets get buttonPaddingSmall =>
      EdgeInsets.symmetric(horizontal: 5.88 * spaceScale, vertical: 2.94 * spaceScale);   // 12*0.49, 6*0.49
  static EdgeInsets get buttonPaddingMedium =>
      EdgeInsets.symmetric(horizontal: 7.84 * spaceScale, vertical: 4.9 * spaceScale);    // 16*0.49, 10*0.49
  static EdgeInsets get buttonPaddingLarge =>
      EdgeInsets.symmetric(horizontal: 11.76 * spaceScale, vertical: 5.88 * spaceScale);  // 24*0.49, 12*0.49

  // ═══════════════════════════════════════════════════════════════════════
  // 📐 النسب المئوية من الشاشة
  // ═══════════════════════════════════════════════════════════════════════
  static double widthPercent(double percent) => _screenWidth * (percent / 100);
  static double heightPercent(double percent) => _screenHeight * (percent / 100);

  // مقاسات شائعة
  static double get halfWidth => _screenWidth * 0.5;
  static double get thirdWidth => _screenWidth * 0.33;
  static double get quarterWidth => _screenWidth * 0.25;

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Responsive Value - للقيم المخصصة
  // ═══════════════════════════════════════════════════════════════════════
  static double responsive(double size) => size * textScale;
  static double responsiveSpace(double size) => size * spaceScale;

  // Responsive with different values per device
  static T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 تحديد نوع الجهاز
  // ═══════════════════════════════════════════════════════════════════════
  static bool get isMobile => _screenWidth < 600;
  static bool get isTablet => _screenWidth >= 600 && _screenWidth < 900;
  static bool get isDesktop => _screenWidth >= 900;

  // تحديد حجم الشاشة بدقة أكبر
  static bool get isSmallMobile => _screenWidth < 360;  // iPhone SE, small Android
  static bool get isMediumMobile => _screenWidth >= 360 && _screenWidth < 400;  // iPhone 12 mini
  static bool get isLargeMobile => _screenWidth >= 400 && _screenWidth < 600;   // iPhone Pro Max

  static bool get isSmallScreen => _screenHeight < 700;
  static bool get isMediumScreen => _screenHeight >= 700 && _screenHeight < 900;
  static bool get isLargeScreen => _screenHeight >= 900;

  // Orientation
  static bool get isPortrait => _screenHeight > _screenWidth;
  static bool get isLandscape => _screenWidth > _screenHeight;

  // ═══════════════════════════════════════════════════════════════════════
  // 📦 App Bar & Bottom Nav Heights
  // ═══════════════════════════════════════════════════════════════════════
  static double get appBarHeight => 56 * textScale;
  static double get bottomNavHeight => 60 * textScale;

  // ═══════════════════════════════════════════════════════════════════════
  // 🎴 Card & Container Sizes
  // ═══════════════════════════════════════════════════════════════════════
  static double get cardElevation => 2;
  static double get cardMinHeight => 80 * textScale;

  // Image sizes
  static double get avatarSmall => 32 * textScale;
  static double get avatarMedium => 48 * textScale;
  static double get avatarLarge => 72 * textScale;
  static double get avatarXLarge => 96 * textScale;

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Safe Area Helpers
  // ═══════════════════════════════════════════════════════════════════════
  static double get safeAreaHorizontal => _safeAreaHorizontal;
  static double get safeAreaVertical => _safeAreaVertical;
}