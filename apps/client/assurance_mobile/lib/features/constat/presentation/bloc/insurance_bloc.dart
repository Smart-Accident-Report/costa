import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../create_insurance/domain/entities/insurance_entity.dart';
import '../../domain/repositories/insurance_repository.dart';

// --- Events ---
abstract class InsuranceEvent extends Equatable {
  const InsuranceEvent();
}

class LoadInsuranceData extends InsuranceEvent {
  const LoadInsuranceData();
  @override
  List<Object?> get props => [];
}

// --- States ---
abstract class InsuranceState extends Equatable {
  const InsuranceState();
}

class InsuranceInitial extends InsuranceState {
  @override
  List<Object?> get props => [];
}

class InsuranceLoading extends InsuranceState {
  @override
  List<Object?> get props => [];
}

class InsuranceLoaded extends InsuranceState {
  final InsuranceEntity insurance;
  const InsuranceLoaded({required this.insurance});

  @override
  List<Object?> get props => [insurance];
}

class InsuranceError extends InsuranceState {
  final String message;
  const InsuranceError({required this.message});

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class InsuranceBloc extends Bloc<InsuranceEvent, InsuranceState> {
  final InsuranceRepository insuranceRepository;

  InsuranceBloc({required this.insuranceRepository})
      : super(InsuranceInitial()) {
    on<LoadInsuranceData>(_onLoadInsuranceData);
  }

  Future<void> _onLoadInsuranceData(
      LoadInsuranceData event, Emitter<InsuranceState> emit) async {
    emit(InsuranceLoading());
    final result = await insuranceRepository.getInsurancePolicy();
    result.fold(
      (failure) => emit(const InsuranceError(
          message: 'Failed to load insurance data. Please try again.')),
      (insurance) => emit(InsuranceLoaded(insurance: insurance)),
    );
  }
}
