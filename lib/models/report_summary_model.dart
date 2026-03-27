/// ReportSummaryModel - Rapor dönemi özet istatistikleri
/// Backend'den gelen tüm alanlar modelde bulunur.
class ReportSummaryModel {
  final int? totalVehicles; // Dönemdeki toplam araç
  final int? soldVehicles; // Satılan araç sayısı
  final int? stockVehicles; // Stokta kalan araç sayısı
  final double? totalRevenue; // Toplam satış geliri
  final double? totalPurchaseCost; // Toplam alış maliyeti (satılanlar)
  final double? totalOperationExpenses; // Toplam operasyon gideri (satılanlar)
  final double? totalFinancingCost; // Toplam finansman gideri (satılanlar)
  final double? netProfit; // Net kâr/zarar (sadece satılan araçlar)
  final double? avgProfitPerSoldVehicle; // Araç başı ortalama kâr
  final int? stockInvestment; // Stoktaki toplam yatırım (alış + gider)
  final String? mostProfitableVehicle; // En kârlı araç adı
  final String? highestExpenseVehicle; // En çok gider yapılan araç adı

  const ReportSummaryModel({
    this.totalVehicles,
    this.soldVehicles,
    this.stockVehicles,
    this.totalRevenue,
    this.totalPurchaseCost,
    this.totalOperationExpenses,
    this.totalFinancingCost,
    this.netProfit,
    this.avgProfitPerSoldVehicle,
    this.stockInvestment,
    this.mostProfitableVehicle,
    this.highestExpenseVehicle,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalVehicles: json['total_vehicles'] as int?,
      soldVehicles: json['sold_vehicles'] as int?,
      stockVehicles: json['stock_vehicles'] as int?,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble(),
      totalPurchaseCost: (json['total_purchase_cost'] as num?)?.toDouble(),
      totalOperationExpenses:
          (json['total_operation_expenses'] as num?)?.toDouble(),
      totalFinancingCost: (json['total_financing_cost'] as num?)?.toDouble(),
      netProfit: (json['net_profit'] as num?)?.toDouble(),
      avgProfitPerSoldVehicle:
          (json['avg_profit_per_sold_vehicle'] as num?)?.toDouble(),
      stockInvestment: (json['stock_investment'] as num?)?.toInt(),
      mostProfitableVehicle: json['most_profitable_vehicle'] as String?,
      highestExpenseVehicle: json['highest_expense_vehicle'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_vehicles': totalVehicles,
        'sold_vehicles': soldVehicles,
        'stock_vehicles': stockVehicles,
        'total_revenue': totalRevenue,
        'total_purchase_cost': totalPurchaseCost,
        'total_operation_expenses': totalOperationExpenses,
        'total_financing_cost': totalFinancingCost,
        'net_profit': netProfit,
        'avg_profit_per_sold_vehicle': avgProfitPerSoldVehicle,
        'stock_investment': stockInvestment,
        'most_profitable_vehicle': mostProfitableVehicle,
        'highest_expense_vehicle': highestExpenseVehicle,
      };
}
