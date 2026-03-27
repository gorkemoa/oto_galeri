import 'package:flutter/material.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/services/vehicle_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// VehiclesViewModel - Araçlar listesi ekranı state yönetimi
class VehiclesViewModel extends ChangeNotifier {
  final VehicleService _service = VehicleService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  List<VehicleModel>? vehicles;

  // Filtre state
  String? searchQuery;
  String? selectedBrand;
  String? selectedStatus;

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
      final result = await _service.getVehicles(
        search: searchQuery,
        brand: selectedBrand,
        status: selectedStatus,
      );

      result.fold(
        onSuccess: (data) {
          vehicles = data;
        },
        onFailure: (error) {
          AppLogger.error('Araçlar yüklenemedi', error: error);
          errorMessage = error.userMessage;
        },
      );
    } catch (e) {
      AppLogger.error('Araçlar init hatası', error: e);
      errorMessage = 'Araçlar yüklenirken bir hata oluştu.';
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
      final result = await _service.getVehicles(
        search: searchQuery,
        brand: selectedBrand,
        status: selectedStatus,
      );

      result.fold(
        onSuccess: (data) {
          vehicles = [...(vehicles ?? []), ...data];
          hasMore = data.isNotEmpty;
        },
        onFailure: (error) {
          page--;
          AppLogger.error('Daha fazla araç yüklenemedi', error: error);
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
  void setSearchQuery(String query) {
    searchQuery = query.isEmpty ? null : query;
    init();
  }

  void setStatusFilter(String? status) {
    selectedStatus = status;
    init();
  }

  void setBrandFilter(String? brand) {
    selectedBrand = brand;
    init();
  }

  void clearFilters() {
    searchQuery = null;
    selectedBrand = null;
    selectedStatus = null;
    init();
  }

  // ─── HESAPLANAN ───────────────────────────────────────
  int get vehicleCount => vehicles?.length ?? 0;
  int get stockCount => vehicles?.where((v) => v.status == 'STOKTA').length ?? 0;
  int get soldCount => vehicles?.where((v) => v.status == 'SATILDI').length ?? 0;
}
