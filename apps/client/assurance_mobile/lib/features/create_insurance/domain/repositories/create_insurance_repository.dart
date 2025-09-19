import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/insurance_entity.dart';

abstract class CreateInsuranceRepository {
  Future<Either<Failure, InsuranceEntity>> createInsuranceAccount({
    required String company,
    required String type,
    required String carDocumentsUrl,
  });
}