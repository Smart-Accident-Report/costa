import '../../../create_insurance/data/models/insurance_model.dart';

abstract class InsuranceRemoteDataSource {
  Future<InsuranceModel> getInsurancePolicy();
}

class InsuranceRemoteDataSourceImpl implements InsuranceRemoteDataSource {
  @override
  Future<InsuranceModel> getInsurancePolicy() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return InsuranceModel(
      userId: 'user-123',
      company: 'Assurance XYZ',
      type: 'Comprehensive',
      carDocumentsUrl: 'https://example.com/car-documents.pdf',
    );
  }
}
