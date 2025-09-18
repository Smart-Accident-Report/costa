import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class SignupUser implements UseCase<AuthResponse, SignupParams> {
  final AuthRepository repository;

  SignupUser(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(SignupParams params) async {
    return await repository.signup(
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
      email: params.email,
      password: params.password,
      studyYear: params.studyYear,
      specialite: params.specialite,
      area: params.area,
    );
  }
}

class SignupParams extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final String studyYear;
  final String specialite;
  final String area;

  const SignupParams({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.studyYear,
    required this.specialite,
    required this.area,
  });

  @override
  List<Object> get props =>
      [fullName, phoneNumber, email, password, studyYear, specialite, area];
}
