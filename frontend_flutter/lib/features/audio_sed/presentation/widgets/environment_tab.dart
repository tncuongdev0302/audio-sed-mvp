import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';


class EnvironmentTab extends StatelessWidget {
  final int coins;
  final String symptomProfile;

  const EnvironmentTab({
    super.key,
    required this.coins,
    required this.symptomProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<Health360Cubit, Health360State>(
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
                    state.errorMsg ?? 'Không có thông tin thời tiết & sức khỏe xoang từ API. Vui lòng kiểm tra kết nối.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final temperature = (weatherData['temperature'] as num?)?.round() ?? 28;
        final humidity = (weatherData['humidity'] as num?)?.round() ?? 45;
        final pm25 = (weatherData['pm25'] as num?)?.round() ?? 160;
        final locationName = weatherData['location_name'] ?? 'TP. Hồ Chí Minh';
        final windSpeed = (weatherData['wind_speed'] as num?)?.toDouble() ?? 3.0;

        final sinusScore = weatherData['sinus_score'] as int? ?? 0;
        final sinusStatus = weatherData['sinus_status'] as String? ?? 'Chưa cập nhật';
        final sinusDescription = weatherData['sinus_description'] as String? ?? 'Không có thông tin';
        final aiAdvice = weatherData['ai_advice'] as String? ?? 'Không có thông tin gợi ý';

        Color statusColor = AppColors.successColor;
        if (sinusScore < 60) {
          statusColor = AppColors.errorColor;
        } else if (sinusScore < 80) {
          statusColor = AppColors.warningColor;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // AI Action Advice Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF142A22) : const Color(0xFFE9FBF2),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1A5F44) : AppColors.successColor.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 GỢI Ý ĐẶC BIỆT TỪ TRỢ LÝ AICARE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successColor,
                      ),
                    ),
                    const SizedBox(height: 6),
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
              
              // Sinus Health Score Ring Card
              Card(
                elevation: 0,
                color: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? AppColors.darkColorScheme.outline : AppColors.borderColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPaint(
                            size: const Size(64, 64),
                            painter: ScoreRingPainter(
                              score: sinusScore / 100.0,
                              color: statusColor,
                              trackColor: isDark ? AppColors.darkColorScheme.outline : AppColors.borderColor,
                            ),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      sinusScore > 0 ? '$sinusScore%' : '--%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      sinusStatus,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '👃',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          sinusDescription,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Redesigned Weather Dashboard Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkColorScheme.outline : AppColors.borderColor,
                    width: 1,
                  ),
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFF0F9FF), Color(0xFFFFFDF5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0C1A30).withValues(alpha: 0.05),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Location & Alert Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locationName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: pm25 > 150
                                  ? const Color(0xFFFDE7E8)
                                  : (pm25 > 50
                                      ? const Color(0xFFFFF3E6)
                                      : const Color(0xFFE9FBF2)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pm25 > 150
                                  ? '⚠️ Kích ứng xoang cao'
                                  : (pm25 > 50 ? 'Chất lượng trung bình' : 'An sau'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: pm25 > 150
                                    ? AppColors.errorColor
                                    : (pm25 > 50
                                        ? AppColors.warningColor
                                        : AppColors.successColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Temperature display
                      Text(
                        '$temperature°C',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hourly forecast
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          final now = DateTime.now();
                          final forecastTime = now.add(Duration(hours: index));
                          final hourString = '${forecastTime.hour}:00';
                          
                          // Determine a temperature variation
                          final tempOffset = index == 1 ? 1 : (index == 2 ? 2 : (index == 3 ? 1 : 0));
                          final tempString = '${temperature + tempOffset}°';
                          
                          // Determine an icon based on hour and index
                          IconData icon;
                          final hour = forecastTime.hour;
                          final isNight = hour >= 18 || hour < 6;
                          if (index == 0) {
                            icon = isNight ? Icons.nights_stay : Icons.wb_sunny_outlined;
                          } else {
                            icon = isNight ? Icons.cloud_queue : Icons.cloud_queue;
                          }
                          
                          return _buildHourlyItem(
                            hourString,
                            icon,
                            tempString,
                            index == 0, // active for the current hour
                            isDark,
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      // Weather metrics grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCol(
                              label: 'Độ ẩm',
                              value: '$humidity%',
                              badgeText: humidity > 70 || humidity < 50 ? 'Hanh khô' : 'Dễ chịu',
                              bg: isDark ? const Color(0xFF2C2417) : const Color(0xFFFFFBEB),
                              badgeBg: isDark ? const Color(0xFF452B0C) : const Color(0xFFFFF3E6),
                              badgeTextCol: AppColors.warningColor,
                              icon: Icons.water_drop_outlined,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCol(
                              label: 'Gió',
                              value: '$windSpeed m/s',
                              badgeText: 'Dịu nhẹ',
                              bg: isDark ? const Color(0xFF142D24) : const Color(0xFFECFDF5),
                              badgeBg: isDark ? const Color(0xFF1B4D3E) : const Color(0xFFE9FBF2),
                              badgeTextCol: AppColors.successColor,
                              icon: Icons.air,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCol(
                              label: 'PM2.5',
                              value: '$pm25',
                              badgeText: pm25 > 150 ? 'Nguy hại' : (pm25 > 50 ? 'Trung bình' : 'Tốt'),
                              bg: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFEF2F2),
                              badgeBg: pm25 > 150
                                  ? (isDark ? const Color(0xFF5E1D1D) : const Color(0xFFFDE7E8))
                                  : (pm25 > 50 ? const Color(0xFF452B0C) : const Color(0xFFE9FBF2)),
                              badgeTextCol: pm25 > 150 ? AppColors.errorColor : (pm25 > 50 ? AppColors.warningColor : AppColors.successColor),
                              icon: Icons.masks_outlined,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Cảm nhận text bottom row
                      Row(
                        children: [
                          Text(
                            'Cảm nhận: ${temperature + 4}°C',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourlyItem(String time, IconData icon, String temp, bool isActive, bool isDark) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? const Color(0xFF1E293B) : AppColors.brandPrimaryLight)
            : Colors.transparent,
        border: Border.all(
          color: isActive ? AppColors.brandPrimary : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? AppColors.brandPrimary
                  : (isDark ? Colors.grey.shade400 : AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            icon,
            size: 16,
            color: isActive
                ? AppColors.brandPrimary
                : (isDark ? Colors.grey.shade300 : AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            temp,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? AppColors.brandPrimary
                  : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({
    required String label,
    required String value,
    required String badgeText,
    required Color bg,
    required Color badgeBg,
    required Color badgeTextCol,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: isDark ? Colors.grey.shade300 : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: badgeTextCol,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;
  final Color trackColor;

  ScoreRingPainter({
    required this.score,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 4;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * score,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
