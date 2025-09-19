import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/insurance_entity.dart';
import '../../domain/repositories/create_insurance_repository.dart';
import '../data_souce/create_insurance_remote_data_source.dart';

class CreateInsuranceRepositoryImpl implements CreateInsuranceRepository {
  final CreateInsuranceRemoteDataSource remoteDataSource;

  CreateInsuranceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, InsuranceEntity>> createInsuranceAccount({
    required String company,
    required String type,
    required String carDocumentsUrl,
  }) async {
    try {
      final insuranceModel = await remoteDataSource.createInsuranceAccount(
        company: company,
        type: type,
        carDocumentsUrl: carDocumentsUrl,
      );
      return Right(insuranceModel);
    } catch (e) {
      return Left(ServerFailure(message: 'server error'));
    }
  }
}