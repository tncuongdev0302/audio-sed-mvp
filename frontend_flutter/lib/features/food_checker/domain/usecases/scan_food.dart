import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/health_360/domain/repositories/health_360_repository.dart';

class ScanFoodParams {
  final String userId;
  final Uint8List imageBytes;

  const ScanFoodParams({
    required this.userId,
    required this.imageBytes,
  });
}

class ScanFood {
  final Health360Repository repository;

  ScanFood({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(ScanFoodParams params) {
    return repository.scanFood(
      userId: params.userId,
      imageBytes: params.imageBytes,
    );
  }
}

class GetFoodOptions {
  final Health360Repository repository;

  GetFoodOptions({required this.repository});

  Future<Either<Failure, List<Map<String, String>>>> call() {
    return repository.getFoodOptions();
  }
}
