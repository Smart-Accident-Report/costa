import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/vehicule_entity.dart';


abstract class VehicleRepository {
  Future<Either<Failure, VehicleEntity>> getVehicle();
  Future<Either<Failure, void>> updateVehicle(VehicleEntity vehicle);
}
