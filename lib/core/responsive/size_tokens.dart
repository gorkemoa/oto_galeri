import 'package:oto_galeri/core/responsive/size_config.dart';

/// SizeTokens - Token bazlı ölçü sistemi
/// Tüm UI elementleri bu tokenları kullanır.
/// Sabit pixel değeri yazmak YASAKTIR.
class SizeTokens {
  SizeTokens._();

  // ─── SPACING (Padding / Margin) ─────────────────────────
  static double get spacingXxs => SizeConfig.w(2);
  static double get spacingXs => SizeConfig.w(4);
  static double get spacingSm => SizeConfig.w(8);
  static double get spacingMd => SizeConfig.w(12);
  static double get spacingLg => SizeConfig.w(16);
  static double get spacingXl => SizeConfig.w(20);
  static double get spacingXxl => SizeConfig.w(24);
  static double get spacing3xl => SizeConfig.w(32);
  static double get spacing4xl => SizeConfig.w(40);
  static double get spacing5xl => SizeConfig.w(48);

  // ─── RADIUS ─────────────────────────────────────────────
  static double get radiusSm => SizeConfig.r(4);
  static double get radiusMd => SizeConfig.r(8);
  static double get radiusLg => SizeConfig.r(12);
  static double get radiusXl => SizeConfig.r(16);
  static double get radiusXxl => SizeConfig.r(20);
  static double get radiusFull => SizeConfig.r(999);

  // ─── FONT SIZE ──────────────────────────────────────────
  static double get fontXxs => SizeConfig.sp(10);
  static double get fontXs => SizeConfig.sp(12);
  static double get fontSm => SizeConfig.sp(14);
  static double get fontMd => SizeConfig.sp(16);
  static double get fontLg => SizeConfig.sp(18);
  static double get fontXl => SizeConfig.sp(20);
  static double get fontXxl => SizeConfig.sp(24);
  static double get font3xl => SizeConfig.sp(28);
  static double get font4xl => SizeConfig.sp(32);

  // ─── ICON SIZE ──────────────────────────────────────────
  static double get iconXs => SizeConfig.icon(16);
  static double get iconSm => SizeConfig.icon(20);
  static double get iconMd => SizeConfig.icon(24);
  static double get iconLg => SizeConfig.icon(28);
  static double get iconXl => SizeConfig.icon(32);

  // ─── COMPONENT HEIGHT ───────────────────────────────────
  static double get buttonHeight => SizeConfig.h(52);
  static double get inputHeight => SizeConfig.h(48);
  static double get appBarHeight => SizeConfig.h(56);
  static double get bottomNavHeight => SizeConfig.h(64);
  static double get cardMinHeight => SizeConfig.h(80);

  // ─── COMPONENT WIDTH ───────────────────────────────────
  static double get cardImageWidth => SizeConfig.w(100);
  static double get avatarSm => SizeConfig.w(32);
  static double get avatarMd => SizeConfig.w(40);
  static double get avatarLg => SizeConfig.w(48);

  // ─── BORDER WIDTH ──────────────────────────────────────
  static double get borderThin => SizeConfig.w(1);
  static double get borderMedium => SizeConfig.w(1.5);
  static double get borderThick => SizeConfig.w(2);
}
