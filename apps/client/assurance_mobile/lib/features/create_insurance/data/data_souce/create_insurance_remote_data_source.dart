
import 'dart:async';

import '../models/insurance_model.dart';

abstract class CreateInsuranceRemoteDataSource {
  Future<InsuranceModel> createInsuranceAccount({
    required String company,
    required String type,
    required String carDocumentsUrl,
  });
}

class CreateInsuranceRemoteDataSourceImpl implements CreateInsuranceRemoteDataSource {
  @override
  Future<InsuranceModel> createInsuranceAccount({
    required String company,
    required String type,
    required String carDocumentsUrl,
  }) async {
    // This is a mocked API call
    // Simulate a network delay
    await Future.delayed(Duration(seconds: 2));

    // For the MVP, it always succeeds
    return InsuranceModel(
      userId: 'mocked_user_id',
      company: company,
      type: type,
      carDocumentsUrl: carDocumentsUrl,
    );
  }
}