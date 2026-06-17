import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/user_session/presentation/cubit/user_session_cubit.dart';
import '../../../../core/user_session/presentation/cubit/user_session_state.dart';
import '../../../../app/theme/app_theme.dart';

class OnboardingQuizPage extends StatefulWidget {
  const OnboardingQuizPage({super.key});

  @override
  State<OnboardingQuizPage> createState() => _OnboardingQuizPageState();
}

class _OnboardingQuizPageState extends State<OnboardingQuizPage> {
  // Local state for interactive choices matching specifications
  int _selectedQ1 = -1;
  int _selectedQ2 = -1;

  final List<bool> _selectedQ3 = [false, false, false, false, false, false];
  final List<bool> _selectedQ4 = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  final List<bool> _selectedQ5 = [false, false, false, false, false, false];

  final List<String> _q1Options = [
    'Tôi đang có triệu chứng và muốn AI phân tích',
    'Tôi muốn theo dõi để phòng bệnh',
    'Tôi chỉ muốn nhận cảnh báo nguy cơ mỗi ngày',
    'Tôi muốn kiểm tra sức khỏe định kỳ',
    'Bỏ qua câu hỏi này',
  ];

  final List<String> _q2Options = [
    'Tôi hoàn toàn khỏe mạnh',
    'Tôi hiện chưa có triệu chứng',
    'Thỉnh thoảng mới khó chịu',
    'Tôi đang có triệu chứng',
    'Bỏ qua câu hỏi này',
  ];

  final List<String> _q3Options = [
    'Hay đi ngoài đường',
    'Làm việc văn phòng máy lạnh',
    'Thường xuyên tiếp xúc bụi',
    'Có trẻ nhỏ trong gia đình',
    'Có người bị dị ứng',
    'Muốn theo dõi sức khỏe hô hấp',
  ];

  final List<String> _q4Options = [
    'AQI xấu',
    'PM2.5 tăng',
    'Thời tiết thay đổi',
    'Độ ẩm thấp',
    'Phấn hoa cao',
    'Thực phẩm dễ kích ứng',
    'Nguy cơ ngủ ngáy',
  ];

  final List<String> _q5Options = [
    'Không bị viêm mũi theo mùa',
    'Giảm nguy cơ dị ứng',
    'Ngủ ngon hơn',
    'Bảo vệ cổ họng',
    'Theo dõi sức khỏe gia đình',
    'Chỉ muốn nhận cảnh báo',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // FPT Long Châu Design System & App Theming Alignment
    final primaryColor =
        isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary;
    final appBarBg = isDark ? const Color(0xFF0C1220) : AppColors.brandPrimary;
    final scaffoldBg = isDark ? const Color(0xFF020617) : AppColors.bgBase;
    final cardBg = isDark ? const Color(0xFF131C2E) : AppColors.bgSurface;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : AppColors.borderColor;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final unselectedTagBg = isDark ? const Color(0xFF1E293B) : AppColors.bgBase;
    final unselectedTagText =
        isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    final lightTealBg = isDark
        ? AppColors.brandPrimary.withValues(alpha: 0.15)
        : AppColors.brandPrimaryLight;

    return BlocConsumer<UserSessionCubit, UserSessionState>(
      listenWhen: (previous, current) =>
          !previous.isSurveyCompleted && current.isSurveyCompleted,
      listener: (context, state) {
        context.go('/');
      },
      builder: (context, state) {
        final bool isAllAnswered = _selectedQ1 != -1 && _selectedQ2 != -1;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'KHẢO SÁT SỨC KHỎE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QUESTION 1 (Single Choice / Radio Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x33000000)
                            : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.track_changes,
                            size: 16,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mục tiêu của bạn hôm nay là gì?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q1Options.length, (index) {
                        final isSelected = _selectedQ1 == index;
                        final optionBg = isSelected
                            ? (isDark
                                ? AppColors.brandPrimary.withValues(alpha: 0.15)
                                : AppColors.brandPrimaryLight)
                            : cardBg;
                        final optionBorderColor =
                            isSelected ? AppColors.brandPrimary : borderColor;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ1 = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: optionBorderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: optionBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? const Color(0xFF64748B)
                                                : AppColors.textTertiary),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.brandPrimary,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _q1Options[index],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? Colors.white
                                                : AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // QUESTION 2 (Single Choice / Radio Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x33000000)
                            : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hiện tại tình trạng sức khỏe của bạn như thế nào?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q2Options.length, (index) {
                        final isSelected = _selectedQ2 == index;
                        final optionBg = isSelected
                            ? (isDark
                                ? AppColors.brandPrimary.withValues(alpha: 0.15)
                                : AppColors.brandPrimaryLight)
                            : cardBg;
                        final optionBorderColor =
                            isSelected ? AppColors.brandPrimary : borderColor;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ2 = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: optionBorderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: optionBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? const Color(0xFF64748B)
                                                : AppColors.textTertiary),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.brandPrimary,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _q2Options[index],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? Colors.white
                                                : AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // QUESTION 3 (Multiple Choice / Checkbox Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x33000000)
                            : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bạn thuộc nhóm đối tượng nào? (Chọn nhiều mục)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q3Options.length, (index) {
                        final isSelected = _selectedQ3[index];
                        final optionBg = isSelected
                            ? (isDark
                                ? AppColors.brandPrimary.withValues(alpha: 0.15)
                                : AppColors.brandPrimaryLight)
                            : cardBg;
                        final optionBorderColor =
                            isSelected ? AppColors.brandPrimary : borderColor;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ3[index] = !_selectedQ3[index];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: optionBorderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: optionBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: isSelected
                                          ? AppColors.brandPrimary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? const Color(0xFF64748B)
                                                : AppColors.textTertiary),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _q3Options[index],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? Colors.white
                                                : AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // QUESTION 4 (Multiple Choice / Checkbox Style / Pill Tags)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x33000000)
                            : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            size: 16,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bạn muốn AI cảnh báo điều gì? (Chọn nhiều mục)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_q4Options.length, (index) {
                          final isSelected = _selectedQ4[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (index == _q4Options.length - 1) {
                                  // 'Tất cả' toggles everything
                                  final turnOn = !_selectedQ4[index];
                                  for (int i = 0; i < _selectedQ4.length; i++) {
                                    _selectedQ4[i] = turnOn;
                                  }
                                } else {
                                  _selectedQ4[index] = !_selectedQ4[index];
                                  // Turn off 'Tất cả' if any item is deselected
                                  if (!_selectedQ4[index]) {
                                    _selectedQ4[_q4Options.length - 1] = false;
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color:
                                    isSelected ? lightTealBg : unselectedTagBg,
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.brandPrimary, width: 1)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check,
                                      size: 10,
                                      color: AppColors.brandPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    _q4Options[index],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.brandPrimary
                                          : unselectedTagText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // QUESTION 5 (Multiple Choice / Checkbox Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x33000000)
                            : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            size: 16,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mục tiêu sức khỏe bạn muốn đạt được?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q5Options.length, (index) {
                        final isSelected = _selectedQ5[index];
                        final optionBg = isSelected
                            ? (isDark
                                ? AppColors.brandPrimary.withValues(alpha: 0.15)
                                : AppColors.brandPrimaryLight)
                            : cardBg;
                        final optionBorderColor =
                            isSelected ? AppColors.brandPrimary : borderColor;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ5[index] = !_selectedQ5[index];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: optionBorderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: optionBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: isSelected
                                          ? AppColors.brandPrimary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? const Color(0xFF64748B)
                                                : AppColors.textTertiary),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _q5Options[index],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : (isDark
                                                ? Colors.white
                                                : AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C1220) : Colors.white,
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? const Color(0xFF1E293B) : AppColors.borderColor,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Reward Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 14,
                      color: AppColors.warningColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hoàn thành khảo sát nhận ngay ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warningColor,
                      ),
                    ),
                    Text(
                      '+50 Fsell',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Primary action button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAllAnswered ? primaryColor : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: state.isOnboardingLoading || !isAllAnswered
                        ? null
                        : () {
                            // Compile and submit survey answers
                            final symptoms = <String>[];
                            final tags = <String>[
                              'ENT'
                            ]; // AICare is always ENT tags

                            // Map Q1 (Mục tiêu)
                            symptoms.add('muc_tieu_${_selectedQ1 + 1}');

                            // Map Q2 (Tình trạng sức khỏe)
                            symptoms.add('suc_khoe_${_selectedQ2 + 1}');

                            // Map Q3 (Nhóm đối tượng)
                            for (int i = 0; i < _selectedQ3.length; i++) {
                              if (_selectedQ3[i]) {
                                symptoms.add('doi_tuong_${i + 1}');
                              }
                            }

                            // Map Q4 (AI Cảnh báo)
                            for (int i = 0; i < _selectedQ4.length; i++) {
                              if (_selectedQ4[i]) {
                                symptoms.add('canh_bao_${i + 1}');
                              }
                            }

                            // Map Q5 (Mục tiêu sức khỏe)
                            for (int i = 0; i < _selectedQ5.length; i++) {
                              if (_selectedQ5[i]) {
                                symptoms.add('muc_tieu_suc_khoe_${i + 1}');
                              }
                            }

                            context.read<UserSessionCubit>().submitSurvey(
                                  symptoms: symptoms,
                                  diseaseTags: tags,
                                );
                          },
                    child: state.isOnboardingLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'TIẾP TỤC',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
