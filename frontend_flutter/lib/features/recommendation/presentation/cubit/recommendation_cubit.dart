import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cough_assessment.dart';
import '../../domain/usecases/get_recommendation.dart';
import '../../domain/usecases/get_sleep_recommendation.dart';
import '../../domain/usecases/get_products.dart';
import 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final GetRecommendation _getRecommendation;
  final GetSleepRecommendation _getSleepRecommendation;
  final GetProducts _getProducts;

  RecommendationCubit({
    required GetRecommendation getRecommendation,
    required GetSleepRecommendation getSleepRecommendation,
    required GetProducts getProducts,
  })  : _getRecommendation = getRecommendation,
        _getSleepRecommendation = getSleepRecommendation,
        _getProducts = getProducts,
        super(const RecommendationInitial());

  Future<void> submitCoughAssessment(CoughAssessment assessment) async {
    emit(const RecommendationLoading());
    final result = await _getRecommendation(assessment);
    
    await result.fold(
      (failure) async => emit(RecommendationError(failure.message)),
      (recommendationResult) async {
        final productsResult = await _getProducts(GetProductsParams(
          category: recommendationResult.classification.coughType,
          subject: recommendationResult.classification.subject,
        ));
        
        productsResult.fold(
          (failure) => emit(RecommendationError(failure.message)),
          (products) => emit(RecommendationSuccess(recommendationResult, products)),
        );
      },
    );
  }

  Future<void> submitSleepAssessment({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  }) async {
    emit(const RecommendationLoading());
    final result = await _getSleepRecommendation(
      SleepAssessmentParams(
        snoringFreq: snoringFreq,
        daytimeSleepiness: daytimeSleepiness,
        apneaObserved: apneaObserved,
        bodyType: bodyType,
        sleepSymptoms: sleepSymptoms,
      ),
    );
    
    await result.fold(
      (failure) async => emit(RecommendationError(failure.message)),
      (sleepData) async {
        final productsResult = await _getProducts(const GetProductsParams(category: 'sleep'));
        
        productsResult.fold(
          (failure) => emit(RecommendationError(failure.message)),
          (products) => emit(RecommendationSleepSuccess(sleepData, products)),
        );
      },
    );
  }

  void resetSurvey() {
    emit(const RecommendationInitial());
  }
}
