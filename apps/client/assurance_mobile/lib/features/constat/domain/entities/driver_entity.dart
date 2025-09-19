import 'package:equatable/equatable.dart';

/// Represents the status of a driver.
enum DriverStatus { active, pending, inactive }

/// Represents a driver entity, which contains the core driver data.
class DriverEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final DateTime joinedDate;
  final bool isOwner;
  final DriverStatus status;

  const DriverEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.joinedDate,
    required this.isOwner,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        licenseNumber,
        joinedDate,
        isOwner,
        status,
      ];
}