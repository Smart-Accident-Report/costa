import 'package:equatable/equatable.dart';

/// Represents the status of a constat.
enum ConstatStatus { inProgress, completed, pending }

/// Represents a constat (accident report) entity.
class ConstatEntity extends Equatable {
  final String id;
  final ConstatStatus status;
  final DateTime date;
  final String location;
  final String otherDriver;
  final String vehicleType;
  final String description;
  final int completionPercentage;
  final List<String> capturedImages;
  final List<dynamic> drawings;

  const ConstatEntity({
    required this.id,
    required this.status,
    required this.date,
    required this.location,
    required this.otherDriver,
    required this.vehicleType,
    required this.description,
    required this.completionPercentage,
    this.capturedImages = const [],
    this.drawings = const [],
  });

  @override
  List<Object?> get props => [
        id,
        status,
        date,
        location,
        otherDriver,
        vehicleType,
        description,
        completionPercentage,
        capturedImages,
        drawings,
      ];
}