import 'dart:async';
import 'package:flutter/services.dart' show Uint8List;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../features/onboarding/domain/usecases/submit_user_intake.dart';
import '../../../../features/home/domain/usecases/get_context_weather.dart';
import '../../../../features/food_checker/domain/usecases/scan_food.dart';
import '../../../../features/missions/domain/usecases/redeem_voucher.dart';
import '../../../../core/analytics/domain/usecases/track_event.dart';
import '../../../../features/missions/domain/usecases/get_weekly_summary.dart';
import 'user_session_state.dart';

class UserSessionCubit extends Cubit<UserSessionState> {
  final SubmitUserIntake _submitUserIntake;
  final GetContextWeather _getContextWeather;
  final ScanFood _scanFood;
  final RedeemVoucher _redeemVoucher;
  final TrackEvent _trackEvent;
  final GetWeeklySummary _getWeeklySummary;
  final GetFoodOptions _getFoodOptions;

  final _audioRecorder = AudioRecorder();
  String? _nightRecordingPath;

  UserSessionCubit({
    required SubmitUserIntake submitUserIntake,
    required GetContextWeather getContextWeather,
    required ScanFood scanFood,
    required RedeemVoucher redeemVoucher,
    required TrackEvent trackEvent,
    required GetWeeklySummary getWeeklySummary,
    required GetFoodOptions getFoodOptions,
  })  : _submitUserIntake = submitUserIntake,
        _getContextWeather = getContextWeather,
        _scanFood = scanFood,
        _redeemVoucher = redeemVoucher,
        _trackEvent = trackEvent,
        _getWeeklySummary = getWeeklySummary,
        _getFoodOptions = getFoodOptions,
        super(UserSessionState(timeOfDay: _getCurrentTimeOfDay())) {
    fetchFoodOptions();
  }

  Future<void> fetchFoodOptions() async {
    final result = await _getFoodOptions();
    result.fold(
      (failure) => emit(state.copyWith(errorMsg: failure.message)),
      (options) => emit(state.copyWith(foodOptions: options)),
    );
  }

  void toggleSymptom(String key) {
    final updatedSymptoms = Map<String, bool>.from(state.symptoms);
    updatedSymptoms[key] = !(updatedSymptoms[key] ?? false);
    emit(state.copyWith(symptoms: updatedSymptoms));
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> submitSurvey(
      {List<String>? symptoms, List<String>? diseaseTags}) async {
    emit(state.copyWith(isOnboardingLoading: true, clearError: true));
    try {
      final symptomList = symptoms ?? <String>[];
      if (symptomList.isEmpty) {
        if (state.symptoms['nose_weather'] == true) {
          symptomList.add('hat_hoi_giao_mua');
        }
        if (state.symptoms['nose_food'] == true) {
          symptomList.add('nghet_mui_sau_an');
        }
        if (state.symptoms['throat_cough'] == true) {
          symptomList.add('ho_khan_ve_dem');
        }
        if (state.symptoms['throat_snore'] == true) {
          symptomList.add('ngu_ngay_tho_mieng');
        }
      }
      final tags = diseaseTags ?? const ['ENT'];

      // Fetch dynamic GPS location
      final position = await _getCurrentLocation();
      final lat = position?.latitude ?? 10.78;
      final long = position?.longitude ?? 106.7;

      // 1. Call User Intake Use Case
      final intakeResult = await _submitUserIntake(
        SubmitUserIntakeParams(
          name: 'Minh Tuấn',
          symptoms: symptomList,
          diseaseTags: tags,
          lat: lat,
          long: long,
          deviceToken: 'fcm_token_health360',
        ),
      );

      final String userId = await intakeResult.fold(
        (failure) => throw Exception(failure.message),
        (id) => id,
      );

      // 2. Fetch aggregated user context
      final contextResult = await _getContextWeather(userId);
      final contextData = contextResult.fold(
        (failure) => throw Exception(failure.message),
        (data) => data,
      );

      final weatherData =
          Map<String, dynamic>.from(contextData['weather'] as Map? ?? {});
      weatherData['sinus_score'] = contextData['sinus_score'];
      weatherData['sinus_status'] = contextData['sinus_status'];
      weatherData['sinus_description'] = contextData['sinus_description'];
      weatherData['ai_advice'] = contextData['ai_advice'];

      // Track onboarding sync analytics event
      await _trackEvent(
        TrackEventParams(
          userId: userId,
          eventType: 'onboarding_sync_success',
          metadata: {'symptoms_count': symptomList.length},
        ),
      );

      emit(state.copyWith(
        userId: userId,
        weatherData: weatherData,
        userContext: contextData,
        isOnboardingLoading: false,
        isSurveyCompleted: true,
        timeOfDay: _getCurrentTimeOfDay(),
      ));

      // Fetch initial summary stats
      await fetchWeeklySummary();
    } catch (e) {
      emit(state.copyWith(
        isOnboardingLoading: false,
        errorMsg: 'Lỗi đồng bộ API: $e',
      ));
    }
  }

  void setTab(int tab) {
    emit(state.copyWith(currentTab: tab));
    if (tab == 1) {
      fetchWeeklySummary();
    }
  }

  void setTimeOfDay(String time) {
    emit(state.copyWith(timeOfDay: time));
  }

  static String _getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 18) {
      return 'noon';
    } else {
      return 'night';
    }
  }

  Future<void> fetchWeeklySummary() async {}

  Future<void> completeTask(String taskId, int reward) async {
    if (state.completedTasks[taskId] == true) return;

    final updatedTasks = Map<String, bool>.from(state.completedTasks);
    updatedTasks[taskId] = true;

    emit(state.copyWith(
      completedTasks: updatedTasks,
      coins: state.coins + reward,
    ));

    if (state.userId != null) {
      final result = await _trackEvent(
        TrackEventParams(
          userId: state.userId!,
          eventType: 'complete_habit_task',
          metadata: {'task_id': taskId, 'coins_earned': reward},
        ),
      );
      result.fold(
        (failure) => null,
        (_) => fetchWeeklySummary(),
      );
    }
  }

  Future<void> runScanner({Uint8List? customImageBytes}) async {
    emit(state.copyWith(
      isScanning: true,
      clearScannedFood: true,
    ));

    try {
      final userId = state.userId ?? 'user_001';

      // Use custom image bytes or fallback to 1x1 dummy PNG if null
      Uint8List imageBytes;
      if (customImageBytes != null) {
        imageBytes = customImageBytes;
      } else {
        // Fallback to 1x1 dummy PNG
        return;
      }

      final scanResult = await _scanFood(
        ScanFoodParams(
          userId: userId,
          imageBytes: imageBytes,
        ),
      );

      scanResult.fold(
        (failure) =>
            emit(state.copyWith(isScanning: false, errorMsg: failure.message)),
        (response) async {
          final int coinReward = state.isScanRewarded ? 0 : 50;
          final List<dynamic> foods = response['foods'] ?? [];
          final String detectedKey = foods.isNotEmpty
              ? (foods[0]['name'] ?? foods[0]['class_id'] ?? 'phoga').toString()
              : 'phoga';

          emit(state.copyWith(
            isScanning: false,
            scannedFoodKey: detectedKey,
            scannedFoodResponse: response,
            isScanRewarded: true,
            coins: state.coins + coinReward,
          ));

          await _trackEvent(
            TrackEventParams(
              userId: userId,
              eventType: 'food_scan_success',
              metadata: {'food_key': detectedKey},
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        errorMsg: 'Lỗi quét camera: $e',
      ));
    }
  }

  void clearScannedFood() {
    emit(state.copyWith(clearScannedFood: true));
  }

  Future<void> toggleNightMic(bool active) async {
    emit(state.copyWith(isNightMicActive: active, clearError: true));
    try {
      if (active) {
        // Enforce microphone permission
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          emit(state.copyWith(
            isNightMicActive: false,
            errorMsg: 'Không có quyền truy cập microphone để giám sát đêm.',
          ));
          return;
        }

        final tempDir = await getTemporaryDirectory();
        _nightRecordingPath =
            '${tempDir.path}/night_monitor_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            numChannels: 1,
            sampleRate: 16000,
          ),
          path: _nightRecordingPath!,
        );

        if (state.userId != null) {
          await _trackEvent(
            TrackEventParams(
              userId: state.userId!,
              eventType: 'activate_night_monitoring',
              metadata: const {'mic_active': true},
            ),
          );
        }
      } else {
        // Stop recording
        if (await _audioRecorder.isRecording()) {
          await _audioRecorder.stop();
        }
      }
    } catch (e) {
      emit(state.copyWith(
        isNightMicActive: false,
        errorMsg: 'Lỗi mic giám sát đêm: $e',
      ));
    }
  }

  Future<void> claimNightlyBonus() async {
    if (state.isNightBonusClaimed) return;
    emit(state.copyWith(
      isNightBonusClaimed: true,
      coins: state.coins + 100,
    ));

    if (state.userId != null) {
      final result = await _trackEvent(
        TrackEventParams(
          userId: state.userId!,
          eventType: 'claim_nightly_bonus',
          metadata: const {'coins': 100},
        ),
      );
      result.fold(
        (failure) => null,
        (_) => fetchWeeklySummary(),
      );
    }
  }

  Future<void> claimWeeklyBonus() async {
    if (state.isWeeklyBonusClaimed) return;
    emit(state.copyWith(
      isWeeklyBonusClaimed: true,
      coins: state.coins + 450,
    ));

    if (state.userId != null) {
      final result = await _trackEvent(
        TrackEventParams(
          userId: state.userId!,
          eventType: 'claim_weekly_bonus',
          metadata: const {'coins': 450},
        ),
      );
      result.fold(
        (failure) => null,
        (_) => fetchWeeklySummary(),
      );
    }
  }

  Future<bool> redeemVoucher(String name, int cost) async {
    if (state.coins >= cost) {
      try {
        final userId = state.userId ?? 'user_001';

        final position = await _getCurrentLocation();
        final lat = position?.latitude ?? 10.78;
        final long = position?.longitude ?? 106.7;

        final orderResult = await _redeemVoucher(
          RedeemVoucherParams(
            userId: userId,
            productId: 'voucher_sinufresh_50k',
            productName: 'Voucher 50K Xịt Mũi Sinufresh',
            cost: cost,
            lat: lat,
            long: long,
          ),
        );

        return await orderResult.fold(
          (failure) {
            emit(state.copyWith(errorMsg: failure.message));
            return false;
          },
          (response) async {
            final updatedVouchers = List<String>.from(state.redeemedVouchers);
            updatedVouchers.add(name);

            emit(state.copyWith(
              coins: state.coins - cost,
              redeemedVouchers: updatedVouchers,
              lastOrderResponse: response,
            ));

            await _trackEvent(
              TrackEventParams(
                userId: userId,
                eventType: 'order_voucher_success',
                metadata: {
                  'product_name': 'Voucher 50K Xịt Mũi Sinufresh',
                  'cost': cost
                },
              ),
            );

            return true;
          },
        );
      } catch (e) {
        emit(state.copyWith(errorMsg: 'Lỗi tạo đơn hàng: $e'));
        return false;
      }
    }
    return false;
  }

  void resetSurvey() {
    emit(UserSessionState(
      coins: 750,
      isSurveyCompleted: false,
      isOnboardingLoading: false,
      symptoms: const {
        'nose_weather': true,
        'nose_food': true,
        'throat_cough': true,
        'throat_snore': true,
      },
      currentTab: 0,
      timeOfDay: _getCurrentTimeOfDay(),
      completedTasks: const {},
      scannedFoodKey: null,
      isScanning: false,
      isScanRewarded: false,
      isNightMicActive: false,
      isNightBonusClaimed: false,
      isWeeklyBonusClaimed: false,
      redeemedVouchers: const [],
      userId: null,
      weatherData: null,
      lastOrderResponse: null,
      scannedFoodResponse: null,
      weeklySummary: null,
      errorMsg: null,
    ));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() async {
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
    _audioRecorder.dispose();
    return super.close();
  }
}
