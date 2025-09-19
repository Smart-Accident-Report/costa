import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.licenseNumber,
    required super.joinedDate,
    required super.isOwner,
    required super.status,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      licenseNumber: json['licenseNumber'] as String,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      isOwner: json['isOwner'] as bool,
      status: DriverStatus.values.firstWhere(
        (e) => e.toString() == 'DriverStatus.${json['status']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'joinedDate': joinedDate.toIso8601String(),
      'isOwner': isOwner,
      'status': status.toString().split('.').last,
    };
  }
}
