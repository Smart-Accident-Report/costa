import '../../domain/entities/constat_entity.dart';

class ConstatModel extends ConstatEntity {
  const ConstatModel({
    required super.id,
    required super.status,
    required super.date,
    required super.location,
    required super.otherDriver,
    required super.vehicleType,
    required super.description,
    required super.completionPercentage,
    required super.capturedImages,
    required super.drawings,
  });

  factory ConstatModel.fromJson(Map<String, dynamic> json) {
    return ConstatModel(
      id: json['id'] as String,
      status: ConstatStatus.values.firstWhere(
        (e) => e.toString() == 'ConstatStatus.${json['status']}',
      ),
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      otherDriver: json['otherDriver'] as String,
      vehicleType: json['vehicleType'] as String,
      description: json['description'] as String,
      completionPercentage: json['completionPercentage'] as int,
      capturedImages: (json['capturedImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      drawings: json['drawings'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.toString().split('.').last,
      'date': date.toIso8601String(),
      'location': location,
      'otherDriver': otherDriver,
      'vehicleType': vehicleType,
      'description': description,
      'completionPercentage': completionPercentage,
      'capturedImages': capturedImages,
      'drawings': drawings,
    };
  }
}