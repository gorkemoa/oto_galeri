/// VehicleImageHelper - Araç marka/model bazlı yerel asset yolu üretici
///
/// Yeni araç görseli eklemek için:
///   1. Dosyayı `assets/images/vehicles/` klasörüne koy
///   2. pubspec.yaml > assets listesine ekle
///   3. `_modelMap` veya `_brandMap`'e kayıt ekle
class VehicleImageHelper {
  VehicleImageHelper._();

  static const String _base = 'assets/images/vehicles';

  // ── Marka + Model → asset dosyası ───────────────────────────────────────
  static const Map<String, String> _modelMap = {
    'bmw_x5':        '$_base/bmw_x5.webp',
    'bmw_3_serisi':  '$_base/bmw_3_serisi.png',
    'bmw_f30':       '$_base/bmw_3_serisi.png',
    'bmw_320i':      '$_base/bmw_3_serisi.png',
    'bmw_316i':      '$_base/bmw_3_serisi.png',
    'bmw_318i':      '$_base/bmw_3_serisi.png',
    'bmw_320d':      '$_base/bmw_3_serisi.png',
    'audi_a3':       '$_base/audi_a3.png',
    'audi_a6':       '$_base/audi_a6.png',
    'mercedes_c180': '$_base/mercedes_c200.png',
    'mercedes_c200': '$_base/mercedes_c200.png',
    'mercedes_e200': '$_base/mercedes_e200.png',
  };

  static String _key(String? s) =>
      (s ?? '').toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');

  static String getAssetPath(String? brand, String? model) {
    final b = _key(brand);
    final m = _key(model);
    if (b.isNotEmpty && m.isNotEmpty) {
      final hit = _modelMap['${b}_$m'];
      if (hit != null) return hit;
    }
    // Eşleşme yoksa placeholder → errorBuilder devreye girer, icon gösterilir
    return '$_base/placeholder.png';
  }

  static String getImageUrl(String? brand, String? model) =>
      getAssetPath(brand, model);

  static String getLargeImageUrl(String? brand, String? model) =>
      getAssetPath(brand, model);
}