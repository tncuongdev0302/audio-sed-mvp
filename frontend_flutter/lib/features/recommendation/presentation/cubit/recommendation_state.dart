import '../../domain/entities/recommendation_result.dart';
import '../../domain/entities/product.dart';

sealed class RecommendationState {
  const RecommendationState();
}

final class RecommendationInitial extends RecommendationState {
  const RecommendationInitial();
}

final class RecommendationLoading extends RecommendationState {
  const RecommendationLoading();
}

final class RecommendationSuccess extends RecommendationState {
  final RecommendationResult result;
  final List<Product> products;
  const RecommendationSuccess(this.result, this.products);
}

final class RecommendationSleepSuccess extends RecommendationState {
  final Map<String, dynamic> sleepData;
  final List<Product> products;
  const RecommendationSleepSuccess(this.sleepData, this.products);
}

final class RecommendationError extends RecommendationState {
  final String message;
  const RecommendationError(this.message);
}
