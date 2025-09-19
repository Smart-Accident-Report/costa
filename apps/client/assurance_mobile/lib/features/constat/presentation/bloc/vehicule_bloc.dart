import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicule_entity.dart';
import '../../domain/repositories/vehicule_repository.dart';

// --- Events ---
abstract class VehicleEvent extends Equatable {
  const VehicleEvent();
}

class LoadVehicle extends VehicleEvent {
  const LoadVehicle();
  @override
  List<Object?> get props => [];
}

class UpdateVehicle extends VehicleEvent {
  final VehicleEntity vehicle;
  const UpdateVehicle({required this.vehicle});
  @override
  List<Object?> get props => [vehicle];
}

// --- States ---
abstract class VehicleState extends Equatable {
  const VehicleState();
}

class VehicleInitial extends VehicleState {
  @override
  List<Object?> get props => [];
}

class VehicleLoading extends VehicleState {
  @override
  List<Object?> get props => [];
}

class VehicleLoaded extends VehicleState {
  final VehicleEntity vehicle;
  const VehicleLoaded({required this.vehicle});
  @override
  List<Object?> get props => [vehicle];
}

class VehicleError extends VehicleState {
  final String message;
  const VehicleError({required this.message});
  @override
  List<Object?> get props => [message];
}

class VehicleUpdated extends VehicleState {
  @override
  List<Object?> get props => [];
}

// --- BLoC ---
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicle>(_onLoadVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
  }

  Future<void> _onLoadVehicle(
      LoadVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    final result = await vehicleRepository.getVehicle();
    result.fold(
      (failure) => emit(const VehicleError(
          message: 'Failed to load vehicle data. Please try again.')),
      (vehicle) => emit(VehicleLoaded(vehicle: vehicle)),
    );
  }

  Future<void> _onUpdateVehicle(
      UpdateVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading()); // Or a more specific state
    final result = await vehicleRepository.updateVehicle(event.vehicle);
    result.fold(
      (failure) => emit(const VehicleError(
          message: 'Failed to update vehicle data. Please try again.')),
      (_) => emit(VehicleUpdated()),
    );

    add(const LoadVehicle());
  }
}
