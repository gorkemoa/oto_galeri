/// UserModel - Kullanıcı/Profil modeli
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? galleryName;
  final String? galleryAddress;
  final String? galleryPhone;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.galleryName,
    this.galleryAddress,
    this.galleryPhone,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      galleryName: json['gallery_name'] as String?,
      galleryAddress: json['gallery_address'] as String?,
      galleryPhone: json['gallery_phone'] as String?,
      token: json['token'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'gallery_name': galleryName,
      'gallery_address': galleryAddress,
      'gallery_phone': galleryPhone,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
