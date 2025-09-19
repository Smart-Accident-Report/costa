import 'package:equatable/equatable.dart';

/// Represents a vehicle entity, which contains the core vehicle data.
class VehicleEntity extends Equatable {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final String chassisNumber;
  final String energy;
  final String power;
  final int seats;
  final double value;
  final String wilaya;
  final String registrationType;
  final String color;
  final String transmission;

  const VehicleEntity({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.chassisNumber,
    required this.energy,
    required this.power,
    required this.seats,
    required this.value,
    required this.wilaya,
    required this.registrationType,
    required this.color,
    required this.transmission,
  });

  @override
  List<Object?> get props => [
        id,
        brand,
        model,
        year,
        plateNumber,
        chassisNumber,
        energy,
        power,
        seats,
        value,
        wilaya,
        registrationType,
        color,
        transmission,
      ];
}