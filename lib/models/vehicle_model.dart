/// VehicleModel - Araç modeli
/// Backend'den gelen tüm alanlar modelde bulunur.
/// Unused alanlar bile silinmez, nullable olabilir.
class VehicleModel {
  final int? id;
  final String? brand; // Marka
  final String? model; // Model
  final int? year; // Yıl
  final int? kilometer; // KM
  final String? fuelType; // Yakıt tipi
  final String? color; // Renk
  final String? plate; // Plaka
  final double? purchasePrice; // Alış fiyatı
  final DateTime? purchaseDate; // Alış tarihi
  final String? paymentMethod; // Ödeme yöntemi (Nakit, Çek, Vadeli, Vadesiz)
  final DateTime? insuranceDate; // Sigorta tarihi
  final DateTime? kaskoDate; // Kasko tarihi
  final DateTime? inspectionDate; // Muayene tarihi
  final String? status; // STOKTA / SATILDI
  final double? totalExpense; // Toplam masraf
  final double? salePrice; // Satış fiyatı
  final DateTime? saleDate; // Satış tarihi
  final String? salePaymentMethod; // Satış ödeme yöntemi
  final String? customerName; // Müşteri adı
  final String? customerPhone; // Müşteri telefonu
  final double? customerBalance; // Müşteri bakiyesi
  final String? imageUrl; // Araç görseli URL
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleModel({
    this.id,
    this.brand,
    this.model,
    this.year,
    this.kilometer,
    this.fuelType,
    this.color,
    this.plate,
    this.purchasePrice,
    this.purchaseDate,
    this.paymentMethod,
    this.insuranceDate,
    this.kaskoDate,
    this.inspectionDate,
    this.status,
    this.totalExpense,
    this.salePrice,
    this.saleDate,
    this.salePaymentMethod,
    this.customerName,
    this.customerPhone,
    this.customerBalance,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Araç tam adı
  String get fullName => '${brand ?? ''} ${model ?? ''}'.trim();

  /// Stokta mı?
  bool get isInStock => status == 'STOKTA';

  /// Satıldı mı?
  bool get isSold => status == 'SATILDI';

  /// Net kar/zarar hesabı
  double? get profitLoss {
    if (salePrice == null || purchasePrice == null) return null;
    return salePrice! - (purchasePrice! + (totalExpense ?? 0));
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      kilometer: json['kilometer'] as int?,
      fuelType: json['fuel_type'] as String?,
      color: json['color'] as String?,
      plate: json['plate'] as String?,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] != null ? DateTime.tryParse(json['purchase_date']) : null,
      paymentMethod: json['payment_method'] as String?,
      insuranceDate: json['insurance_date'] != null ? DateTime.tryParse(json['insurance_date']) : null,
      kaskoDate: json['kasko_date'] != null ? DateTime.tryParse(json['kasko_date']) : null,
      inspectionDate: json['inspection_date'] != null ? DateTime.tryParse(json['inspection_date']) : null,
      status: json['status'] as String?,
      totalExpense: (json['total_expense'] as num?)?.toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      saleDate: json['sale_date'] != null ? DateTime.tryParse(json['sale_date']) : null,
      salePaymentMethod: json['sale_payment_method'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerBalance: (json['customer_balance'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'kilometer': kilometer,
      'fuel_type': fuelType,
      'color': color,
      'plate': plate,
      'purchase_price': purchasePrice,
      'purchase_date': purchaseDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'insurance_date': insuranceDate?.toIso8601String(),
      'kasko_date': kaskoDate?.toIso8601String(),
      'inspection_date': inspectionDate?.toIso8601String(),
      'status': status,
      'total_expense': totalExpense,
      'sale_price': salePrice,
      'sale_date': saleDate?.toIso8601String(),
      'sale_payment_method': salePaymentMethod,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_balance': customerBalance,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
