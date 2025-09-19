


import '../../domain/entities/vehicule_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.brand,
    required super.model,
    required super.year,
    required super.plateNumber,
    required super.chassisNumber,
    required super.energy,
    required super.power,
    required super.seats,
    required super.value,
    required super.wilaya,
    required super.registrationType,
    required super.color,
    required super.transmission,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      plateNumber: json['plateNumber'] as String,
      chassisNumber: json['chassisNumber'] as String,
      energy: json['energy'] as String,
      power: json['power'] as String,
      seats: json['seats'] as int,
      value: (json['value'] as num).toDouble(),
      wilaya: json['wilaya'] as String,
      registrationType: json['registrationType'] as String,
      color: json['color'] as String,
      transmission: json['transmission'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'plateNumber': plateNumber,
      'chassisNumber': chassisNumber,
      'energy': energy,
      'power': power,
      'seats': seats,
      'value': value,
      'wilaya': wilaya,
      'registrationType': registrationType,
      'color': color,
      'transmission': transmission,
    };
  }
}
