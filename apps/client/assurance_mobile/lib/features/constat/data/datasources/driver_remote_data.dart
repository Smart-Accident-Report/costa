import '../../domain/entities/driver_entity.dart';
import '../models/driver_model.dart';

abstract class DriverRemoteDataSource {
  Future<List<DriverModel>> getDrivers();
  Future<String> generateDriverLink(String driverId);
}
class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  @override
  Future<List<DriverModel>> getDrivers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DriverModel(
        id: '1',
        name: 'Benali Ahmed',
        email: 'benali.ahmed@email.com',
        phone: '+213 555 123 456',
        licenseNumber: 'DZ123456789',
        joinedDate: DateTime.now().subtract(const Duration(days: 365)),
        isOwner: true,
        status: DriverStatus.active,
      ),
      DriverModel(
        id: '2',
        name: 'Fatima Bensalem',
        email: 'fatima.bensalem@email.com',
        phone: '+213 777 987 654',
        licenseNumber: 'DZ987654321',
        joinedDate: DateTime.now().subtract(const Duration(days: 50)),
        isOwner: false,
        status: DriverStatus.pending,
      ),
    ];
  }

  @override
  Future<String> generateDriverLink(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://app.example.com/invite/$driverId';
  }
}
