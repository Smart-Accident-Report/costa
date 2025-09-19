import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/driver_entity.dart';

abstract class DriverRepository {
  Future<Either<Failure, List<DriverEntity>>> getDrivers();
  Future<Either<Failure, String>> generateDriverLink(String driverId);
}
