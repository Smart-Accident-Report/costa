import '../../domain/entities/insurance_entity.dart';

class InsuranceModel extends InsuranceEntity {
  const InsuranceModel({
    required super.userId,
    required super.company,
    required super.type,
    required super.carDocumentsUrl,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      userId: json['userId'] as String,
      company: json['company'] as String,
      type: json['type'] as String,
      carDocumentsUrl: json['carDocumentsUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'company': company,
      'type': type,
      'carDocumentsUrl': carDocumentsUrl,
    };
  }
}