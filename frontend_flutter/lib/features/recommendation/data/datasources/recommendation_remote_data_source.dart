import '../../../../core/network/api_client.dart';
import '../../domain/entities/cough_assessment.dart';
import '../models/recommendation_result_model.dart';
import '../../domain/entities/product.dart';

abstract class RecommendationRemoteDataSource {
  Future<RecommendationResultModel> getRecommendation(CoughAssessment assessment);

  Future<Map<String, dynamic>> getSleepRecommendation({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  });

  Future<List<Product>> getProducts({
    required String category,
    String? subject,
  });
}

class RecommendationRemoteDataSourceImpl implements RecommendationRemoteDataSource {
  final ApiClient client;

  RecommendationRemoteDataSourceImpl({required this.client});

  @override
  Future<RecommendationResultModel> getRecommendation(CoughAssessment assessment) async {
    final response = await client.post(
      '/api/recommendation',
      data: assessment.toJson(),
    );

    if (response.statusCode == 200) {
      return RecommendationResultModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to get recommendations');
    }
  }

  @override
  Future<Map<String, dynamic>> getSleepRecommendation({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  }) async {
    final response = await client.post(
      '/api/sleep-assessment',
      data: {
        'snoring_freq': snoringFreq,
        'daytime_sleepiness': daytimeSleepiness,
        'apnea_observed': apneaObserved,
        'body_type': bodyType,
        'sleep_symptoms': sleepSymptoms,
      },
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get sleep recommendations');
    }
  }

  @override
  Future<List<Product>> getProducts({
    required String category,
    String? subject,
  }) async {
    final isSleep = category == 'sleep';
    final path = isSleep ? '/api/v1/products/sleep' : '/api/v1/products/cough';
    
    final queryParams = <String, dynamic>{};
    if (!isSleep) {
      queryParams['category'] = category;
      if (subject != null) {
        queryParams['subject'] = subject;
      }
    }

    final response = await client.get(
      path,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200) {
      final List<dynamic> productsJson = response.data['products'];
      return productsJson.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
