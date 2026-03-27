/// VehicleProfitReportModel - Araç bazlı kârlılık raporu modeli
/// Backend'den gelen tüm alanlar modelde bulunur. Unused alanlar silinmez.
class VehicleProfitReportModel {
  final int? vehicleId;
  final String? vehicleName;
  final String? plate;
  final int? year;
  final String? brand;
  final String? model;
  final String? status; // STOKTA / SATILDI
  final double? purchaseCost; // Alış maliyeti
  final double? operationExpenses; // Operasyon giderleri
  final double? financingCost; // Finansman / vade farkı gideri
  final double? saleRevenue; // Satış geliri (sadece SATILDI araçlarda)
  final DateTime? purchaseDate;
  final DateTime? saleDate;
  final String? paymentMethod;
  final String? salePaymentMethod;
  final Map<String, double>? expenseByCategory; // Gider kategori dağılımı

  const VehicleProfitReportModel({
    this.vehicleId,
    this.vehicleName,
    this.plate,
    this.year,
    this.brand,
    this.model,
    this.status,
    this.purchaseCost,
    this.operationExpenses,
    this.financingCost,
    this.saleRevenue,
    this.purchaseDate,
    this.saleDate,
    this.paymentMethod,
    this.salePaymentMethod,
    this.expenseByCategory,
  });

  // ─── HESAPLANAN ALANLAR ───────────────────────────
  double get totalCost =>
      (purchaseCost ?? 0) + (operationExpenses ?? 0) + (financingCost ?? 0);

  double get profitLoss => (saleRevenue ?? 0) - totalCost;

  bool get isSold => status == 'SATILDI';

  bool get isProfitable => profitLoss > 0;

  factory VehicleProfitReportModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? categoryMap;
    if (json['expense_by_category'] is Map) {
      categoryMap = (json['expense_by_category'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }
    return VehicleProfitReportModel(
      vehicleId: json['vehicle_id'] as int?,
      vehicleName: json['vehicle_name'] as String?,
      plate: json['plate'] as String?,
      year: json['year'] as int?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      status: json['status'] as String?,
      purchaseCost: (json['purchase_cost'] as num?)?.toDouble(),
      operationExpenses: (json['operation_expenses'] as num?)?.toDouble(),
      financingCost: (json['financing_cost'] as num?)?.toDouble(),
      saleRevenue: (json['sale_revenue'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] != null
          ? DateTime.tryParse(json['purchase_date'])
          : null,
      saleDate: json['sale_date'] != null
          ? DateTime.tryParse(json['sale_date'])
          : null,
      paymentMethod: json['payment_method'] as String?,
      salePaymentMethod: json['sale_payment_method'] as String?,
      expenseByCategory: categoryMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'vehicle_id': vehicleId,
        'vehicle_name': vehicleName,
        'plate': plate,
        'year': year,
        'brand': brand,
        'model': model,
        'status': status,
        'purchase_cost': purchaseCost,
        'operation_expenses': operationExpenses,
        'financing_cost': financingCost,
        'sale_revenue': saleRevenue,
        'purchase_date': purchaseDate?.toIso8601String(),
        'sale_date': saleDate?.toIso8601String(),
        'payment_method': paymentMethod,
        'sale_payment_method': salePaymentMethod,
        'expense_by_category': expenseByCategory,
      };
}
