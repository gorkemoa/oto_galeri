import 'package:flutter/material.dart';
import 'package:oto_galeri/models/expense_model.dart';
import 'package:oto_galeri/services/expense_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// ExpensesViewModel - Giderler listesi ekranı state yönetimi
class ExpensesViewModel extends ChangeNotifier {
  final ExpenseService _service = ExpenseService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  List<ExpenseModel>? expenses;

  // Filtre state
  int? selectedVehicleId;
  String? selectedType;
  String? selectedBrand;

  // Arama (client-side)
  String searchQuery = '';

  // Pagination
  int page = 1;
  bool hasMore = false;
  bool isLoadingMore = false;

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    page = 1;
    notifyListeners();

    try {
      final result = await _service.getExpenses(
        vehicleId: selectedVehicleId,
        type: selectedType,
      );

      result.fold(
        onSuccess: (data) {
          expenses = data;
        },
        onFailure: (error) {
          AppLogger.error('Giderler yüklenemedi', error: error);
          errorMessage = error.userMessage;
        },
      );
    } catch (e) {
      AppLogger.error('Giderler init hatası', error: e);
      errorMessage = 'Giderler yüklenirken bir hata oluştu.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── REFRESH ──────────────────────────────────────────
  Future<void> refresh() async {
    await init();
  }

  // ─── LOAD MORE ────────────────────────────────────────
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      page++;
      final result = await _service.getExpenses(
        vehicleId: selectedVehicleId,
        type: selectedType,
      );

      result.fold(
        onSuccess: (data) {
          expenses = [...(expenses ?? []), ...data];
          hasMore = data.isNotEmpty;
        },
        onFailure: (error) {
          page--;
          AppLogger.error('Daha fazla gider yüklenemedi', error: error);
        },
      );
    } catch (e) {
      page--;
      AppLogger.error('loadMore hatası', error: e);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  // ─── RETRY ────────────────────────────────────────────
  Future<void> onRetry() async {
    await init();
  }

  // ─── FİLTRE ───────────────────────────────────────────
  void setVehicleFilter(int? vehicleId) {
    selectedVehicleId = vehicleId;
    init();
  }

  void setTypeFilter(String? type) {
    selectedType = type;
    init();
  }

  void setBrandFilter(String? brand) {
    selectedBrand = brand;
    init();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void clearFilters() {
    selectedVehicleId = null;
    selectedType = null;
    selectedBrand = null;
    searchQuery = '';
    init();
  }

  /// Mevcut filtrelere (arama dahil) göre toplam gider tutarı
  double get totalExpense {
    final all = groupedByVehicle.values.expand((list) => list).toList();
    return all.fold(0.0, (sum, e) => sum + (e.amount ?? 0.0));
  }

  /// Giderleri araç bazında gruplar: vehicleId → gider listesi (tarihe göre azalan)
  Map<int, List<ExpenseModel>> get groupedByVehicle {
    var all = expenses ?? [];

    // Brand filtresi (client-side)
    if (selectedBrand != null && selectedBrand != 'Tümü') {
      all = all.where((e) => e.vehicleBrand == selectedBrand).toList();
    }

    // Client-side arama filtresi
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      all = all.where((e) =>
        (e.vehicleName?.toLowerCase().contains(q) ?? false) ||
        (e.type?.toLowerCase().contains(q) ?? false) ||
        (e.description?.toLowerCase().contains(q) ?? false),
      ).toList();
    }
    final Map<int, List<ExpenseModel>> map = {};
    for (final e in all) {
      final key = e.vehicleId ?? 0;
      map.putIfAbsent(key, () => []).add(e);
    }
    // Her grubun içini tarihe göre sırala (yeniden eskiye)
    for (final key in map.keys) {
      map[key]!.sort((a, b) =>
          (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
    }
    return map;
  }

  /// Mevcut giderler içindeki tüm markaları döner
  List<String> get availableBrands {
    final brands = (expenses ?? [])
        .map((e) => e.vehicleBrand)
        .where((b) => b != null)
        .cast<String>()
        .toSet()
        .toList();
    brands.sort();
    return ['Tümü', ...brands];
  }

  /// Araç başına toplam gider tutarı
  double vehicleTotal(int vehicleId) {
    return groupedByVehicle[vehicleId]
            ?.fold<double>(0, (s, e) => s + (e.amount ?? 0)) ??
        0;
  }

  /// Görünen (filtrelenmiş) giderlerin genel toplamı
  double get grandTotal =>
      groupedByVehicle.values
          .expand((list) => list)
          .fold<double>(0, (s, e) => s + (e.amount ?? 0));
}
