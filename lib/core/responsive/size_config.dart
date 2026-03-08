import 'dart:math';
import 'package:flutter/material.dart';

/// SizeConfig - Responsive ölçü sistemi
/// Referans cihaz: iPhone 13 (390 x 844)
/// Büyük ekranlarda scaling cap uygulanır.
class SizeConfig {
  static double _screenWidth = _referenceWidth;
  static double _screenHeight = _referenceHeight;
  static double _blockSizeHorizontal = _referenceWidth / 100;
  static double _blockSizeVertical = _referenceHeight / 100;
  static double _scaleFactor = 1.0;

  // Referans cihaz ölçüleri (iPhone 13)
  static const double _referenceWidth = 390.0;
  static const double _referenceHeight = 844.0;

  // Scaling cap - referans üstüne çıkmasın
  static const double _maxScaleFactor = 1.0;

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    // Scale factor hesapla - büyük ekran koruması
    final double widthScale = _screenWidth / _referenceWidth;
    final double heightScale = _screenHeight / _referenceHeight;
    _scaleFactor = min(min(widthScale, heightScale), _maxScaleFactor);
  }

  /// Genişliğe göre ölçekleme (padding, margin, spacing vb.)
  static double w(double size) {
    return size * _scaleFactor;
  }

  /// Yüksekliğe göre ölçekleme
  static double h(double size) {
    return size * _scaleFactor;
  }

  /// Font boyutu ölçekleme
  static double sp(double size) {
    return size * _scaleFactor;
  }

  /// Radius ölçekleme
  static double r(double size) {
    return size * _scaleFactor;
  }

  /// Icon boyutu ölçekleme
  static double icon(double size) {
    return size * _scaleFactor;
  }

  /// Ekran genişliğinin yüzdesi
  static double widthPercent(double percent) {
    return _blockSizeHorizontal * percent;
  }

  /// Ekran yüksekliğinin yüzdesi
  static double heightPercent(double percent) {
    return _blockSizeVertical * percent;
  }
}
