part of 'create_insurance_bloc.dart';

@immutable
abstract class CreateInsuranceState extends Equatable {
  const CreateInsuranceState();

  @override
  List<Object> get props => [];
}

class CreateInsuranceInitial extends CreateInsuranceState {}

class CreateInsuranceLoading extends CreateInsuranceState {}

class CreateInsuranceSuccess extends CreateInsuranceState {
  final InsuranceEntity insurance;

  const CreateInsuranceSuccess({required this.insurance});

  @override
  List<Object> get props => [insurance];
}

class CreateInsuranceFailure extends CreateInsuranceState {
  final String message;

  const CreateInsuranceFailure({required this.message});

  @override
  List<Object> get props => [message];
}