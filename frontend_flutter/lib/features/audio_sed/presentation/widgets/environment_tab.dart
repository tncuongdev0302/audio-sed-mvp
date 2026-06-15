import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';
import 'dashboard_shared_widgets.dart';

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
        final temperature = (weatherData?['temperature'] as num?)?.round() ?? 28;
        final humidity = (weatherData?['humidity'] as num?)?.round() ?? 45;
        final pm25 = (weatherData?['pm25'] as num?)?.round() ?? 160;
        final locationName = weatherData?['location_name'] ?? 'TP. Hồ Chí Minh';
        final windSpeed = (weatherData?['wind_speed'] as num?)?.toDouble() ?? 3.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardProfileRow(coins: coins, symptomProfile: symptomProfile),
              const SizedBox(height: 12),
              const CriticalAlertBanner(),
              const SizedBox(height: 12),
              
              // Sinus Health Score Ring Card
              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF131C2E) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
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
                              score: 0.85,
                              color: const Color(0xFF2ECC71),
                              trackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                            ),
                            child: const SizedBox(
                              width: 64,
                              height: 64,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '85%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlueDark,
                                      ),
                                    ),
                                    Text(
                                      'TỐT',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2ECC71),
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
                      const Expanded(
                        child: Text(
                          'Dựa trên hồ sơ bệnh lý của bạn, các chỉ số ngoại cảnh hôm nay rất lý tưởng. Nguy cơ tái phát đợt cấp ở mức thấp.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
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
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
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
                      color: const Color(0xFF0C1A30).withOpacity(0.05),
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
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: pm25 > 150
                                  ? const Color(0xFFFEE2E2)
                                  : (pm25 > 50
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFD1FAE5)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pm25 > 150
                                  ? '⚠️ Kích ứng xoang cao'
                                  : (pm25 > 50 ? 'Chất lượng trung bình' : 'An toàn'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: pm25 > 150
                                    ? const Color(0xFFEF4444)
                                    : (pm25 > 50
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF10B981)),
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
                          color: isDark ? Colors.white : AppColors.primaryBlue,
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
                              'Độ ẩm',
                              '$humidity%',
                              humidity > 70 || humidity < 50 ? 'Hanh khô' : 'Dễ chịu',
                              isDark ? const Color(0xFF2C2417) : const Color(0xFFFFFBEB),
                              isDark ? const Color(0xFF6B450C) : const Color(0xFFFDE68A),
                              isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309),
                              Icons.water_drop_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCol(
                              'Gió',
                              '$windSpeed m/s',
                              'Gió nhẹ',
                              isDark ? const Color(0xFF142D24) : const Color(0xFFECFDF5),
                              isDark ? const Color(0xFF1A5F44) : const Color(0xFFA7F3D0),
                              isDark ? const Color(0xFF10B981) : const Color(0xFF047857),
                              Icons.air,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCol(
                              'PM2.5',
                              '$pm25',
                              pm25 > 150 ? 'Nguy hại' : (pm25 > 50 ? 'Trung bình' : 'Tốt'),
                              isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFEF2F2),
                              isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5),
                              isDark ? const Color(0xFFEF4444) : const Color(0xFFB91C1C),
                              Icons.masks_outlined,
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
                              color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 12),

          // AI Action Advice Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2A24) : const Color(0xFFE8F8F5),
              border: Border.all(color: isDark ? const Color(0xFF225B42) : const Color(0xFFA3E4D7)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'AI khuyên dùng: Nên bật máy tạo độ ẩm trong phòng kín và dùng xịt mũi biển sâu trước khi ra ngoài.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF52C49A) : const Color(0xFF117A65),
                height: 1.3,
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
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
            : Colors.transparent,
        border: Border.all(
          color: isActive ? AppColors.primaryBlue : Colors.transparent,
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
              color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            icon,
            size: 16,
            color: isActive ? AppColors.primaryBlue : (isDark ? Colors.grey.shade300 : const Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            temp,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, String status, Color bg, Color border, Color textCol, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: textCol),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: textCol, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textCol),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textCol),
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
