import '../models/vehicule_model.dart';

abstract class VehicleRemoteDataSource {
  Future<VehicleModel> getVehicle();
  Future<void> updateVehicle(VehicleModel vehicle);
}

/// A mock implementation of [VehicleRemoteDataSource] for demonstration.
class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  @override
  Future<VehicleModel> getVehicle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const VehicleModel(
      id: 'v-123',
      brand: 'Peugeot',
      model: '208',
      year: 2021,
      plateNumber: '31-123-456',
      chassisNumber: 'VF3XXXXXXXX123456',
      energy: 'Essence',
      power: '7 CV',
      seats: 5,
      value: 1850000,
      wilaya: 'Alger',
      registrationType: 'Permanent',
      color: 'Blanc',
      transmission: 'Manuelle',
    );
  }

  @override
  Future<void> updateVehicle(VehicleModel vehicle) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return;
  }
}