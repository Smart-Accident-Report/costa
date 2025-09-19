import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/constat_entity.dart';
import '../../domain/repositories/constat_repository.dart';

// --- Events ---
abstract class ConstatEvent extends Equatable {
  const ConstatEvent();
}

class LoadConstats extends ConstatEvent {
  const LoadConstats();
  @override
  List<Object?> get props => [];
}

class CreateConstat extends ConstatEvent {
  final ConstatEntity constat;
  const CreateConstat({required this.constat});
  @override
  List<Object?> get props => [constat];
}

// --- States ---
abstract class ConstatState extends Equatable {
  const ConstatState();
}

class ConstatInitial extends ConstatState {
  @override
  List<Object?> get props => [];
}

class ConstatLoading extends ConstatState {
  @override
  List<Object?> get props => [];
}

class ConstatsLoaded extends ConstatState {
  final List<ConstatEntity> constats;
  const ConstatsLoaded({required this.constats});

  @override
  List<Object?> get props => [constats];
}

class ConstatError extends ConstatState {
  final String message;
  const ConstatError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ConstatCreated extends ConstatState {
  @override
  List<Object?> get props => [];
}

// --- BLoC ---
class ConstatBloc extends Bloc<ConstatEvent, ConstatState> {
  final ConstatRepository constatRepository;

  ConstatBloc({required this.constatRepository}) : super(ConstatInitial()) {
    on<LoadConstats>(_onLoadConstats);
    on<CreateConstat>(_onCreateConstat);
  }

  Future<void> _onLoadConstats(
      LoadConstats event, Emitter<ConstatState> emit) async {
    emit(ConstatLoading());
    final result = await constatRepository.getConstats();
    result.fold(
      (failure) => emit(const ConstatError(
          message: 'Failed to load constats. Please try again.')),
      (constats) => emit(ConstatsLoaded(constats: constats)),
    );
  }

  Future<void> _onCreateConstat(
      CreateConstat event, Emitter<ConstatState> emit) async {
    emit(ConstatLoading());
    final result = await constatRepository.createConstat(event.constat);
    result.fold(
      (failure) => emit(const ConstatError(
          message: 'Failed to create constat. Please try again.')),
      (_) => emit(ConstatCreated()),
    );

    add(const LoadConstats());
  }
}
