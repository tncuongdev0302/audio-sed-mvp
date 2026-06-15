import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';
import 'onboarding_quiz_page.dart';
import '../widgets/environment_tab.dart';
import '../widgets/ai_assistant_tab.dart';
import '../widgets/missions_tab.dart';
import '../widgets/handbook_tab.dart';

class AudioSedPage extends StatefulWidget {
  const AudioSedPage({super.key});

  @override
  State<AudioSedPage> createState() => _AudioSedPageState();
}

class _AudioSedPageState extends State<AudioSedPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<Health360Cubit, Health360State>(
      listenWhen: (previous, current) =>
          current.errorMsg != null && previous.errorMsg != current.errorMsg,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMsg!),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<Health360Cubit>().clearError();
      },
      builder: (context, state) {
        // Render Onboarding Quiz if not completed
        if (!state.isSurveyCompleted) {
          if (state.isOnboardingLoading) {
            return const OnboardingSyncView();
          }
          return const OnboardingQuizPage();
        }

        final symptomText = _getSymptomProfile(state.symptoms);

        // Render main dashboard with segmented tab controller
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Builder(
              builder: (context) {
                final statusBarHeight = MediaQuery.of(context).padding.top;
                
                final alertsList = state.userContext?['alerts'] as List<dynamic>? ?? [];
                final hasAlert = alertsList.isNotEmpty;

                final alertMessage = hasAlert 
                    ? (alertsList[0]['body'] as String? ?? 'Cảnh báo sức khỏe') 
                    : 'Hệ thống hô hấp an toàn, không phát hiện nguy cơ';
                final alertBgColor = hasAlert ? const Color(0xFFFDE7E8) : const Color(0xFFE9FBF2);
                final alertBorderColor = hasAlert ? AppColors.errorColor : AppColors.successColor;
                final alertIcon = hasAlert ? '⚠️' : '✅';
                final alertTextCol = hasAlert ? AppColors.errorColor : AppColors.successColor;

                return Container(
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 8,
                    left: 12,
                    right: 12,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C1220) : AppColors.primaryBlue,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile & Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white24,
                                ),
                                child: const Center(
                                  child: Text(
                                    '👤',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.userContext?['name'] as String? ?? 'Chưa có thông tin',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Vàng | ${state.coins} Lxu | $symptomText',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                                tooltip: 'Làm lại khảo sát',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  context.read<Health360Cubit>().resetSurvey();
                                },
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.history, color: Colors.white, size: 20),
                                tooltip: 'Báo cáo tuần',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  context.push('/history');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Warning Alert Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: alertBgColor,
                          border: Border.all(color: alertBorderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              alertIcon,
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                alertMessage,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: alertTextCol,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          body: Column(
            children: [
              // Segmented Tab Bar Controller
              Container(
                width: double.infinity,
                height: 54,
                color: isDark ? const Color(0xFF0C1220) : Colors.white,
                child: Row(
                  children: [
                    _buildTabItem(context, state, 0, 'Trang chủ'),
                    _buildTabItem(context, state, 1, 'Trợ lý AI'),
                    _buildTabItem(context, state, 2, 'Nhiệm vụ'),
                    _buildTabItem(context, state, 3, 'Cẩm nang'),
                  ],
                ),
              ),
              // Tab Body Content
              Expanded(
                child: _buildTabBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
      BuildContext context, Health360State state, int tabIndex, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = state.currentTab == tabIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.read<Health360Cubit>().setTab(tabIndex);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryBlue
                    : (isDark ? Colors.grey.shade400 : const Color(0xFF7F8C8D)),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(Health360State state) {
    final symptomText = _getSymptomProfile(state.symptoms);

    switch (state.currentTab) {
      case 0:
        return EnvironmentTab(coins: state.coins, symptomProfile: symptomText);
      case 1:
        return AIAssistantTab(coins: state.coins, symptomProfile: symptomText);
      case 2:
        return MissionsTab(state: state);
      case 3:
        return HandbookTab(coins: state.coins, symptomProfile: symptomText);
      default:
        return EnvironmentTab(coins: state.coins, symptomProfile: symptomText);
    }
  }

  String _getSymptomProfile(Map<String, bool> symptoms) {
    final nw = symptoms['nose_weather'] ?? false;
    final nf = symptoms['nose_food'] ?? false;
    final tc = symptoms['throat_cough'] ?? false;
    final ts = symptoms['throat_snore'] ?? false;

    if (nw && nf && tc && ts) return 'Hồ sơ: SÀNG LỌC TMH';
    if (nw && tc && ts) return 'Hồ sơ: XOANG & HO NGÁY';
    if (nw && ts) return 'Hồ sơ: XOANG & NGỦ NGÁY';
    if (nw && tc) return 'Hồ sơ: XOANG & HO KHAN';
    if (nw) return 'Hồ sơ: Xoang Mãn Tính';
    if (tc || ts) return 'Hồ sơ: HO KHAN / NGÁY ĐÊM';
    if (nf) return 'Hồ sơ: KÍCH ỨNG THỨC ĂN';
    return 'Hồ sơ: CHƯA XÁC ĐỊNH';
  }
}

// OnboardingSyncView displays the syncing state during onboarding setup
class OnboardingSyncView extends StatefulWidget {
  const OnboardingSyncView({super.key});

  @override
  State<OnboardingSyncView> createState() => _OnboardingSyncViewState();
}

class _OnboardingSyncViewState extends State<OnboardingSyncView> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Đang đồng bộ hồ sơ bệnh lý xoang...',
    'Đang phân tích điều kiện khí hậu trạm thực tế...',
    'Đang đo chỉ số chất lượng không khí PM2.5...',
    'Đồng bộ hoàn tất! Xin chào bạn.',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted) {
        setState(() {
          if (_currentStep < _steps.length - 1) {
            _currentStep++;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1220) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _steps[_currentStep],
                  key: ValueKey<int>(_currentStep),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
