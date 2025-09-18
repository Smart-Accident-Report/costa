import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/insurance_entity.dart';
import '../../domain/usecases/create_insurance_usecase.dart';
part 'create_insurance_event.dart';
part 'create_insurance_state.dart';

class CreateInsuranceBloc extends Bloc<CreateInsuranceEvent, CreateInsuranceState> {
  final CreateInsuranceAccountUseCase createInsuranceAccount;

  CreateInsuranceBloc({required this.createInsuranceAccount})
      : super(CreateInsuranceInitial()) {
    on<CreateInsuranceSubmitted>(_onCreateInsuranceSubmitted);
  }

  void _onCreateInsuranceSubmitted(
      CreateInsuranceSubmitted event, Emitter<CreateInsuranceState> emit) async {
    emit(CreateInsuranceLoading());
    final result = await createInsuranceAccount(CreateInsuranceParams(
      company: event.company,
      type: event.type,
      carDocumentsUrl: event.carDocumentsUrl,
    ));

    result.fold(
      (failure) => emit(CreateInsuranceFailure(message: _mapFailureToMessage(failure))),
      (insurance) => emit(CreateInsuranceSuccess(insurance: insurance)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server Error. Please try again later.';
      default:
        return 'Unexpected error occurred.';
    }
  }
}