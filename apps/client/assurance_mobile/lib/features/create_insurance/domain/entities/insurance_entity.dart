import 'package:equatable/equatable.dart';

class InsuranceEntity extends Equatable {
  final String userId;
  final String company;
  final String type;
  final String carDocumentsUrl;

  const InsuranceEntity({
    required this.userId,
    required this.company,
    required this.type,
    required this.carDocumentsUrl,
  });

  @override
  List<Object?> get props => [userId, company, type, carDocumentsUrl];
}