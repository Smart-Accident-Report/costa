import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/insurance_entity.dart';
import '../repositories/create_insurance_repository.dart';

class CreateInsuranceAccountUseCase implements UseCase<InsuranceEntity, CreateInsuranceParams> {
  final CreateInsuranceRepository repository;

  CreateInsuranceAccountUseCase(this.repository);

  @override
  Future<Either<Failure, InsuranceEntity>> call(CreateInsuranceParams params) async {
    return await repository.createInsuranceAccount(
      company: params.company,
      type: params.type,
      carDocumentsUrl: params.carDocumentsUrl,
    );
  }
}

class CreateInsuranceParams extends Equatable {
  final String company;
  final String type;
  final String carDocumentsUrl;

  const CreateInsuranceParams({
    required this.company,
    required this.type,
    required this.carDocumentsUrl,
  });

  @override
  List<Object?> get props => [company, type, carDocumentsUrl];
}