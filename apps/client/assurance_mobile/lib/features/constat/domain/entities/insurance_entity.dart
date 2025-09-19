import 'package:equatable/equatable.dart';

/// Represents an insurance policy entity, which contains the core insurance data.
class InsuranceEntity extends Equatable {
  final String id;
  final String policyNumber;
  final String policyType;
  final String vehicleBrand;
  final DateTime expirationDate;
  final double monthlyPayment;
  final DateTime nextPaymentDate;

  const InsuranceEntity({
    required this.id,
    required this.policyNumber,
    required this.policyType,
    required this.vehicleBrand,
    required this.expirationDate,
    required this.monthlyPayment,
    required this.nextPaymentDate,
  });

  @override
  List<Object?> get props => [
        id,
        policyNumber,
        policyType,
        vehicleBrand,
        expirationDate,
        monthlyPayment,
        nextPaymentDate,
      ];
}