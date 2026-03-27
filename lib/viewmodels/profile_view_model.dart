import 'package:flutter/material.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// ProfileViewModel - Profil/Ayarlar ekranı state yönetimi
class ProfileViewModel extends ChangeNotifier {
  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;

  // Profil verileri
  String? userName;
  String? galleryName;
  String? phone;
  String? address;

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: API hazır olduğunda gerçek service çağrılacak
      await Future.delayed(const Duration(milliseconds: 300));

      // Geçici dummy veri (Service katmanından gelecek)
      userName = 'Görkem';
      galleryName = 'OtoGens Auto Gallery';
      phone = '0532 000 00 00';
      address = 'İstanbul, Türkiye';
    } catch (e) {
      AppLogger.error('Profil init hatası', error: e);
      errorMessage = 'Profil yüklenirken bir hata oluştu.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── REFRESH ──────────────────────────────────────────
  Future<void> refresh() async {
    await init();
  }

  // ─── RETRY ────────────────────────────────────────────
  Future<void> onRetry() async {
    await init();
  }

  // ─── ÇIKIŞ YAP ───────────────────────────────────────
  Future<void> logout() async {
    // TODO: API hazır olduğunda logout endpoint çağrılacak
    AppLogger.info('Kullanıcı çıkış yaptı');
  }
}
