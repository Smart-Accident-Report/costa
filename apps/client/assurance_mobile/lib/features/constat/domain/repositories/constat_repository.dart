import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/constat_entity.dart';
abstract class ConstatRepository {
  Future<Either<Failure, List<ConstatEntity>>> getConstats();
  Future<Either<Failure, ConstatEntity>> getConstatById(String id);
  Future<Either<Failure, void>> createConstat(ConstatEntity constat);
  Future<Either<Failure, void>> updateConstat(ConstatEntity constat);
}