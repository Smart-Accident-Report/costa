import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/constat_entity.dart';
import '../../domain/repositories/constat_repository.dart';

// --- Events ---
abstract class ScanEvent extends Equatable {
  const ScanEvent();
}

class StartScan extends ScanEvent {
  final String scanType;
  const StartScan({required this.scanType});
  @override
  List<Object?> get props => [scanType];
}

class ScanDataCaptured extends ScanEvent {
  final String scanType;
  final dynamic data;
  const ScanDataCaptured({required this.scanType, required this.data});
  @override
  List<Object?> get props => [scanType, data];
}

class SubmitConstat extends ScanEvent {
  final ConstatEntity constat;
  const SubmitConstat({required this.constat});
  @override
  List<Object?> get props => [constat];
}

// --- States ---
abstract class ScanState extends Equatable {
  const ScanState();
}

class ScanInitial extends ScanState {
  @override
  List<Object?> get props => [];
}

class ScanInProgress extends ScanState {
  final String scanType;
  const ScanInProgress({required this.scanType});
  @override
  List<Object?> get props => [scanType];
}

class ScanDataAvailable extends ScanState {
  final String scanType;
  final dynamic data;
  const ScanDataAvailable({required this.scanType, required this.data});
  @override
  List<Object?> get props => [scanType, data];
}

class ScanError extends ScanState {
  final String message;
  const ScanError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ConstatSubmissionSuccess extends ScanState {
  @override
  List<Object?> get props => [];
}

// --- BLoC ---
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ConstatRepository constatRepository;

  ScanBloc({required this.constatRepository}) : super(ScanInitial()) {
    on<StartScan>(_onStartScan);
    on<ScanDataCaptured>(_onScanDataCaptured);
    on<SubmitConstat>(_onSubmitConstat);
  }

  void _onStartScan(StartScan event, Emitter<ScanState> emit) {
    emit(ScanInProgress(scanType: event.scanType));
  }

  void _onScanDataCaptured(ScanDataCaptured event, Emitter<ScanState> emit) {
    emit(ScanDataAvailable(scanType: event.scanType, data: event.data));
  }

  Future<void> _onSubmitConstat(
      SubmitConstat event, Emitter<ScanState> emit) async {
    final result = await constatRepository.createConstat(event.constat);
    result.fold(
      (failure) => emit(const ScanError(message: 'Failed to submit constat.')),
      (_) => emit(ConstatSubmissionSuccess()),
    );
  }
}
