import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../create_insurance/domain/entities/insurance_entity.dart';

abstract class InsuranceRepository {
  Future<Either<Failure, InsuranceEntity>> getInsurancePolicy();
}