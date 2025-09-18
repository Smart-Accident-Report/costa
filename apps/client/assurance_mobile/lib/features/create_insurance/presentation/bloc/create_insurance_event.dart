part of 'create_insurance_bloc.dart';

@immutable
abstract class CreateInsuranceEvent extends Equatable {
  const CreateInsuranceEvent();

  @override
  List<Object> get props => [];
}

class CreateInsuranceSubmitted extends CreateInsuranceEvent {
  final String company;
  final String type;
  final String carDocumentsUrl;

  const CreateInsuranceSubmitted({
    required this.company,
    required this.type,
    required this.carDocumentsUrl,
  });

  @override
  List<Object> get props => [company, type, carDocumentsUrl];
}