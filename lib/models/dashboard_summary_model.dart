/// DashboardSummaryModel - Dashboard özet kartları modeli
class DashboardSummaryModel {
  final int? totalVehicles; // Toplam araç
  final int? inStockVehicles; // Stoktaki araç
  final int? soldVehicles; // Satılan araç
  final double? totalProfit; // Toplam kar
  final DateTime? createdAt;

  const DashboardSummaryModel({
    this.totalVehicles,
    this.inStockVehicles,
    this.soldVehicles,
    this.totalProfit,
    this.createdAt,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalVehicles: json['total_vehicles'] as int?,
      inStockVehicles: json['in_stock_vehicles'] as int?,
      soldVehicles: json['sold_vehicles'] as int?,
      totalProfit: (json['total_profit'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_vehicles': totalVehicles,
      'in_stock_vehicles': inStockVehicles,
      'sold_vehicles': soldVehicles,
      'total_profit': totalProfit,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
