import '../../domain/entities/constat_entity.dart';
import '../models/constat_model.dart';

abstract class ConstatRemoteDataSource {
  Future<List<ConstatModel>> getConstats();
  Future<ConstatModel> getConstatById(String id);
  Future<void> createConstat(ConstatModel constat);
  Future<void> updateConstat(ConstatModel constat);
}
class ConstatRemoteDataSourceImpl implements ConstatRemoteDataSource {
  
  final List<ConstatModel> _mockConstats = [
    ConstatModel(
      id: '2024-003',
      status: ConstatStatus.inProgress,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'Avenue de l\'Indépendance, Alger',
      otherDriver: 'Mohammed Benaissa',
      vehicleType: 'Renault Clio',
      description: 'Collision légère à Ardis',
      completionPercentage: 50,
      capturedImages: [],
      drawings: [],
    ),
    ConstatModel(
      id: '2024-002',
      status: ConstatStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 5)),
      location: 'Rue Didouche Mourad, Alger',
      otherDriver: 'Farid Oubrahem',
      vehicleType: 'Volkswagen Golf',
      description: 'Accident avec dégâts matériels',
      completionPercentage: 100,
      capturedImages: [],
      drawings: [],
    ),
  ];

  @override
  Future<List<ConstatModel>> getConstats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockConstats;
  }

  @override
  Future<ConstatModel> getConstatById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final constat = _mockConstats.firstWhere((c) => c.id == id);
    return constat;
  }

  @override
  Future<void> createConstat(ConstatModel constat) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockConstats.add(constat);
    return;
  }

  @override
  Future<void> updateConstat(ConstatModel constat) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockConstats.indexWhere((c) => c.id == constat.id);
    if (index != -1) {
      _mockConstats[index] = constat;
    }
    return;
  }
}