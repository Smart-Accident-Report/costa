import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/driver_repository.dart';

// --- Events ---
abstract class DriverEvent extends Equatable {
  const DriverEvent();
}

class LoadDrivers extends DriverEvent {
  const LoadDrivers();
  @override
  List<Object?> get props => [];
}

class GenerateInvitationLink extends DriverEvent {
  final String driverId;
  const GenerateInvitationLink({required this.driverId});
  @override
  List<Object?> get props => [driverId];
}

// --- States ---
abstract class DriverState extends Equatable {
  const DriverState();
}

class DriverInitial extends DriverState {
  @override
  List<Object?> get props => [];
}

class DriverLoading extends DriverState {
  @override
  List<Object?> get props => [];
}

class DriversLoaded extends DriverState {
  final List<DriverEntity> drivers;
  const DriversLoaded({required this.drivers});

  @override
  List<Object?> get props => [drivers];
}

class DriverError extends DriverState {
  final String message;
  const DriverError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LinkGenerationSuccess extends DriverState {
  final String link;
  const LinkGenerationSuccess({required this.link});

  @override
  List<Object?> get props => [link];
}

class LinkGenerationError extends DriverState {
  final String message;
  const LinkGenerationError({required this.message});
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRepository driverRepository;

  DriverBloc({required this.driverRepository}) : super(DriverInitial()) {
    on<LoadDrivers>(_onLoadDrivers);
    on<GenerateInvitationLink>(_onGenerateInvitationLink);
  }

  Future<void> _onLoadDrivers(
      LoadDrivers event, Emitter<DriverState> emit) async {
    emit(DriverLoading());
    final result = await driverRepository.getDrivers();
    result.fold(
      (failure) => emit(const DriverError(
          message: 'Failed to load drivers. Please try again.')),
      (drivers) => emit(DriversLoaded(drivers: drivers)),
    );
  }

  Future<void> _onGenerateInvitationLink(
      GenerateInvitationLink event, Emitter<DriverState> emit) async {
    emit(DriverLoading()); // Can use a more specific state if needed
    final result = await driverRepository.generateDriverLink(event.driverId);
    result.fold(
      (failure) => emit(
          const LinkGenerationError(message: 'Failed to generate link.')),
      (link) => emit(LinkGenerationSuccess(link: link)),
    );
    // After generating the link, we can reload the drivers list.
    add(const LoadDrivers());
  }
}
