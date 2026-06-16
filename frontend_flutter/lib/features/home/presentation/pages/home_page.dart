import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/user_session/presentation/cubit/user_session_cubit.dart';
import '../../../../core/user_session/presentation/cubit/user_session_state.dart';

class HomePage extends StatelessWidget {
  final int coins;
  final String symptomProfile;

  const HomePage({
    super.key,
    required this.coins,
    required this.symptomProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<UserSessionCubit, UserSessionState>(
      builder: (context, state) {
        final weatherData = state.weatherData;

        if (weatherData == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMsg ??
                        'Không có thông tin thời tiết & sức khỏe xoang từ API. Vui lòng kiểm tra kết nối.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade400
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final temperature = (weatherData['temperature'] as num?)?.round() ?? 28;
        final locationName = weatherData['location_name'] ?? 'TP. Hồ Chí Minh';
        final aiAdvice =
            weatherData['ai_advice'] as String? ?? 'Không có thông tin gợi ý';
        final sinusScore = weatherData['sinus_score'] as int? ?? 80;
        final sinusStatus = weatherData['sinus_status'] as String? ?? 'Tốt';

        // Temperature logic mapping
        final String feltTempBadgeText;
        final Color feltTempBadgeBgColor;
        final Color feltTempBadgeTextColor;
        final IconData feltTempBadgeIcon;
        final int feltTemp;
        final String feltTempAdvice;
        final List<String> feltTempLinks;

        if (temperature >= 35) {
          feltTempBadgeText = 'Nắng nóng nguy hiểm';
          feltTempBadgeBgColor = const Color(0xFFF04438);
          feltTempBadgeTextColor = Colors.white;
          feltTempBadgeIcon = Icons.warning_amber_rounded;
          feltTemp = temperature + 4;
          feltTempAdvice =
              'Báo động: Nguy cơ cao gây sốc nhiệt hoặc đột quỵ. Bạn cần bổ sung nước bù điện giải và tìm nơi hạ nhiệt ngay.';
          feltTempLinks = [
            'Hướng dẫn xử trí Sốc nhiệt',
            'Hướng dẫn xử trí Đột quỵ',
            'Tìm trạm giải nhiệt gần bạn ngay',
          ];
        } else if (temperature >= 30) {
          feltTempBadgeText = 'Trời nắng gắt';
          feltTempBadgeBgColor = const Color(0xFFFA8C16);
          feltTempBadgeTextColor = Colors.white;
          feltTempBadgeIcon = Icons.wb_sunny_outlined;
          feltTemp = temperature + 2;
          feltTempAdvice =
              'Cảnh báo: Bạn nên hạn chế làm việc ngoài trời quá 45 phút. Đeo kính râm và mũ rộng vành để tránh tác hại tia UV.';
          feltTempLinks = [
            'Tác hại của tia UV đối với cơ thể',
            'Top các sản phẩm kem chống nắng',
          ];
        } else if (temperature >= 20) {
          feltTempBadgeText = 'Thời tiết dịu mát';
          feltTempBadgeBgColor = const Color(0xFF51B848);
          feltTempBadgeTextColor = Colors.white;
          feltTempBadgeIcon = Icons.check_circle_outline;
          feltTemp = temperature;
          feltTempAdvice =
              'Thời tiết lý tưởng cho sức khỏe. Hãy tham gia hoạt động ngoài trời nhẹ nhàng.';
          feltTempLinks = [];
        } else {
          feltTempBadgeText = 'Trời trở lạnh';
          feltTempBadgeBgColor = const Color(0xFF1250DC);
          feltTempBadgeTextColor = Colors.white;
          feltTempBadgeIcon = Icons.ac_unit_outlined;
          feltTemp = temperature - 2;
          feltTempAdvice =
              'Thời tiết này làm tăng nguy cơ đột quỵ ở người cao tuổi. Giữ ấm vùng cổ và tránh tập thể dục quá sớm vào buổi sáng.';
          feltTempLinks = [
            'Tìm hiểu về Đột quỵ',
            'Hướng dẫn xử trí đột quỵ',
            '10 cách phòng bệnh hô hấp ở trẻ em',
          ];
        }

        final Color feltTempCardBgColor;
        if (temperature >= 35) {
          feltTempCardBgColor =
              isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFEAE5);
        } else if (temperature >= 30) {
          feltTempCardBgColor =
              isDark ? const Color(0xFF2C2417) : const Color(0xFFFFF9E6);
        } else if (temperature >= 20) {
          feltTempCardBgColor =
              isDark ? const Color(0xFF142D24) : const Color(0xFFE6FAF6);
        } else {
          feltTempCardBgColor =
              isDark ? const Color(0xFF1B263F) : const Color(0xFFEAF0FC);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Health & Weather Overview (TỔNG QUAN SỨC KHỎE) - Moved to top
              Text(
                'TỔNG QUAN SỨC KHỎE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal Scrolling Stats Overview
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildOverviewStatCard(
                      title: 'THỜI TIẾT',
                      value: '$temperature°C',
                      desc: locationName,
                      icon: Icons.wb_sunny_outlined,
                      color: Colors.orange,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildOverviewStatCard(
                      title: 'HÔ HẤP / XOANG',
                      value: '$sinusScore%',
                      desc: sinusStatus,
                      icon: Icons.health_and_safety_outlined,
                      color: AppColors.successColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildOverviewStatCard(
                      title: 'CẢM NHẬN NHIỆT',
                      value: '$feltTemp°C',
                      desc: feltTempBadgeText,
                      icon: feltTempBadgeIcon,
                      color: feltTempBadgeBgColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Detailed Weather & AI Action Advice (Original Revamped)
              // AI Action Advice Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF142A22)
                      : const Color(0xFFE9FBF2),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1A5F44)
                        : AppColors.successColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology,
                            size: 18, color: AppColors.successColor),
                        const SizedBox(width: 6),
                        const Text(
                          'GỢI Ý ĐẶC BIỆT TỪ AI HEALTH 360',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      aiAdvice,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Felt Temp Warning Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: feltTempCardBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: feltTempBadgeBgColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            feltTempBadgeIcon,
                            size: 12,
                            color: feltTempBadgeTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            feltTempBadgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: feltTempBadgeTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nhiệt độ cảm nhận thực tế: $feltTemp°C',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feltTempAdvice,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (feltTempLinks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...feltTempLinks.map((link) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đang mở: $link...'),
                                  backgroundColor: AppColors.brandPrimary,
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.link,
                                  size: 14,
                                  color: AppColors.brandPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  link,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandPrimary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Detailed Hourly Forecast Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : AppColors.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dự báo thời tiết $locationName',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final now = DateTime.now();
                        final forecastTime = now.add(Duration(hours: index));
                        final hourString = index == 0
                            ? 'Hiện tại'
                            : '${forecastTime.hour.toString().padLeft(2, '0')}:00';

                        final tempOffset = index == 1
                            ? 1
                            : (index == 2 ? 2 : (index == 3 ? 1 : 0));
                        final tempString = '${temperature + tempOffset}°';

                        IconData icon;
                        if (index == 0 || index == 2) {
                          icon = Icons.wb_sunny_outlined;
                        } else if (index == 1 || index == 3) {
                          icon = Icons.umbrella_outlined;
                        } else {
                          icon = Icons.ac_unit;
                        }

                        return _buildHourlyItem(
                          hourString,
                          icon,
                          tempString,
                          index == 0,
                          isDark,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. To-Do List Today (CẦN LÀM HÔM NAY) - New component from Figma Option 3
              _buildTodoSection(context, isDark),
              const SizedBox(height: 24),

              // 4. Utilities Grid (TIỆN ÍCH AI SỨC KHỎE)
              Text(
                'TIỆN ÍCH AI SỨC KHỎE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
                children: [
                  _buildUtilityCard(
                    context: context,
                    title: 'Phân tích hơi thở',
                    sub: 'Ghi âm & chẩn đoán',
                    icon: Icons.keyboard_voice_outlined,
                    iconBg: const Color(0xFFEBF3FF),
                    iconColor: AppColors.brandPrimary,
                    isDark: isDark,
                    onTap: () => context.push('/audio-analysis'),
                  ),
                  _buildUtilityCard(
                    context: context,
                    title: 'Quét thực phẩm',
                    sub: 'Kiểm tra dị nguyên',
                    icon: Icons.camera_alt_outlined,
                    iconBg: const Color(0xFFE9FBF2),
                    iconColor: AppColors.successColor,
                    isDark: isDark,
                    onTap: () => context.push('/food-checker'),
                  ),
                  _buildUtilityCard(
                    context: context,
                    title: 'Đánh giá giấc ngủ',
                    sub: 'Phân tích ngáy/thở',
                    icon: Icons.bedtime_outlined,
                    iconBg: const Color(0xFFF3E8FF),
                    iconColor: Colors.purple,
                    isDark: isDark,
                    onTap: () => context.push('/sleep-assessment'),
                  ),
                  _buildUtilityCard(
                    context: context,
                    title: 'Hồ sơ lâm sàng',
                    sub: 'Tạo lại khảo sát',
                    icon: Icons.assignment_outlined,
                    iconBg: const Color(0xFFFFF4E6),
                    iconColor: AppColors.warningColor,
                    isDark: isDark,
                    onTap: () => context.push('/onboarding'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Health Knowledge List (KIẾN THỨC SỨC KHỎE) - New horizontal list from Figma
              _buildKnowledgeSection(context, isDark),
              const SizedBox(height: 24),

              // 6. Welcome Banner Card (Figma Inspired)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0F172A), const Color(0xFF1E3A8A)]
                        : [const Color(0xFF1250DC), const Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1250DC)
                          .withValues(alpha: isDark ? 0.15 : 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1),
                          ),
                          child: const Text(
                            '✨ TRỢ LÝ AI MỚI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Khám sức khỏe Hô hấp 360',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(
                            'Phân tích tiếng ho, tiếng thở khi ngủ để phát hiện sớm các dấu hiệu viêm mũi, dị ứng xoang.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => context.push('/audio-analysis'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Kiểm tra ngay',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            const Text(
                              '🤖',
                              style: TextStyle(fontSize: 42),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 7. AI Assistant Chat Banner (Có thắc mắc về sức khỏe?)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFEBF3FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : AppColors.brandPrimary.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Có thắc mắc về sức khỏe?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.brandPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bác sĩ Trợ lý AI sẵn sàng hỗ trợ giải đáp 24/7 về các triệu chứng.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('👨‍⚕️', style: TextStyle(fontSize: 32)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () => context.read<UserSessionCubit>().setTab(1),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bắt đầu trò chuyện với bác sĩ...',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const Icon(
                              Icons.send,
                              size: 14,
                              color: AppColors.brandPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUtilityCard({
    required BuildContext context,
    required String title,
    required String sub,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : AppColors.borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? iconBg.withValues(alpha: 0.1) : iconBg,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStatCard({
    required String title,
    required String value,
    required String desc,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : AppColors.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 14,
                color: color,
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(
      String time, IconData icon, String temp, bool isActive, bool isDark) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.brandPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            icon,
            size: 18,
            color: isActive
                ? Colors.white
                : (isDark ? Colors.grey.shade300 : AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            temp,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // To-Do Section (Cần làm hôm nay)
  Widget _buildTodoSection(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBF3FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFD6E4FF),
          width: 1.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    color:
                        isDark ? Colors.blue.shade300 : const Color(0xFF007AFF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CẦN LÀM HÔM NAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF007AFF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Card 1: Nhập số đo huyết áp
              _buildTodoCard(
                isDark: isDark,
                title: 'Nhập số đo huyết áp',
                subtitle: 'Để bác sĩ theo dõi huyết áp tuần này cho bạn',
                icon: Icons.monitor_heart_rounded,
                iconColor: const Color(0xFFF43F5E),
                iconBg: const Color(0xFFFFEAE5),
                action: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF007AFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      size: 14, color: Colors.white),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Chuyển hướng đến màn hình ghi nhận Huyết Áp...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Card 2: Nhập chỉ số đường huyết
              _buildTodoCard(
                isDark: isDark,
                title: 'Nhập chỉ số đường huyết',
                subtitle: 'Để bác sĩ theo dõi huyết áp tuần này cho bạn',
                icon: Icons.bloodtype_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
                action: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF51B848),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Chuyển hướng đến màn hình ghi nhận Đường Huyết...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          // Mascot robot peeking on top right
          Positioned(
            top: -24,
            right: -8,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mascot robot face
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget action,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? iconBg.withValues(alpha: 0.15) : iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            action,
          ],
        ),
      ),
    );
  }

  // Health Knowledge Section (Kiến thức sức khỏe)
  Widget _buildKnowledgeSection(BuildContext context, bool isDark) {
    final articles = [
      {
        'title': 'Nguy cơ gây đột quỵ ở người tăng huyết áp',
        'imgUrl':
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400&q=80',
        'badge': 'VIDEO',
        'badgeColor': const Color(0xFFFA8C16), // Orange
        'badgeIcon': Icons.play_circle_outline,
      },
      {
        'title': 'Vì sao cắt giảm muối nhưng huyết áp vẫn cao?',
        'imgUrl':
            'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=400&q=80',
        'badge': 'Infographic',
        'badgeColor': const Color(0xFF51B848), // Green
        'badgeIcon': Icons.image_outlined,
      },
      {
        'title': 'Phương pháp kiểm soát cơn hen cấp tính tại nhà',
        'imgUrl':
            'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?w=400&q=80',
        'badge': 'Podcast',
        'badgeColor': const Color(0xFF9333EA), // Purple
        'badgeIcon': Icons.mic_none_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KIẾN THỨC SỨC KHỎE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<UserSessionCubit>()
                    .setTab(3); // Go to handbook tab
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem thêm',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.blue.shade300
                          : AppColors.brandPrimary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 14,
                    color:
                        isDark ? Colors.blue.shade300 : AppColors.brandPrimary,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final art = articles[index];
              return Container(
                width: 155,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : AppColors.borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Article Image with Badge overlay
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                art['imgUrl'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image,
                                        color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            // Badge (e.g. VIDEO)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: art['badgeColor'] as Color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      art['badgeIcon'] as IconData,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      art['badge'] as String,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Title Text
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            art['title'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
