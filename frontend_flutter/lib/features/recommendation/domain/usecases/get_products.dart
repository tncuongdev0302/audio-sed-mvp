import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/recommendation_repository.dart';

class GetProductsParams {
  final String category;
  final String? subject;

  const GetProductsParams({required this.category, this.subject});
}

class GetProducts {
  final RecommendationRepository repository;

  GetProducts({required this.repository});

  Future<Either<Failure, List<Product>>> call(GetProductsParams params) {
    return repository.getProducts(
      category: params.category,
      subject: params.subject,
    );
  }
}
