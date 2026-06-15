import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';


class MissionsTab extends StatelessWidget {
  final Health360State state;

  const MissionsTab({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate completed count
    final nwDone = state.completedTasks['morn_task_1'] == true;
    final tcDone = state.completedTasks['night_task_1'] == true; // Ghi âm
    final nfDone = state.completedTasks['noon_task_1'] == true; // Quét ảnh
    
    int completedCount = 0;
    if (nwDone) completedCount++;
    if (tcDone) completedCount++;
    if (nfDone) completedCount++;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // Missions Tracker Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tiến trình nhiệm vụ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hoàn thành nhiệm vụ nhận Lxu',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: isDark ? Colors.grey.shade400 : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9FBF2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$completedCount/3 Nhiệm vụ',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: completedCount / 3.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Missions List
          // Mission 1: Kiểm tra chỉ số độ ẩm hôm nay
          _buildMissionRow(
            context: context,
            icon: '☁️',
            title: 'Kiểm tra chỉ số độ ẩm hôm nay',
            rewardCoins: 10,
            isCompleted: nwDone,
            onAction: () {
              context.read<Health360Cubit>().completeTask('morn_task_1', 10);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chúc mừng bạn đã hoàn thành nhiệm vụ và nhận +10 Lxu!'),
                  backgroundColor: AppColors.brandPrimary,
                ),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          // Mission 2: Ghi âm và phân tích âm thanh
          _buildMissionRow(
            context: context,
            icon: '🎙️',
            title: 'Ghi âm và phân tích âm thanh',
            rewardCoins: 20,
            isCompleted: tcDone,
            onAction: () => context.push('/audio-analysis'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          // Mission 3: Quét ảnh bữa ăn chống viêm
          _buildMissionRow(
            context: context,
            icon: '📸',
            title: 'Quét ảnh bữa ăn chống viêm',
            rewardCoins: 15,
            isCompleted: nfDone,
            onAction: () => context.push('/food-checker'),
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Loyalty Title
          Text(
            'ĐỔI QUÀ LOYALTY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Quick Rewards Marketplace
          Row(
            children: [
              Expanded(
                child: _buildRewardCard(
                  context: context,
                  icon: '😷',
                  title: 'Khẩu trang N95 kháng khuẩn',
                  cost: 50,
                  stockStatus: 'Còn 5',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRewardCard(
                  context: context,
                  icon: '🧴',
                  title: 'Xịt mũi nước biển sâu Xisat',
                  cost: 120,
                  hotStatus: 'Bán chảy',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionRow({
    required BuildContext context,
    required String icon,
    required String title,
    required int rewardCoins,
    required bool isCompleted,
    required VoidCallback onAction,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.darkColorScheme.outline : AppColors.borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
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
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '💎 +$rewardCoins Lxu',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            isCompleted
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9FBF2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Hoàn thành',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successColor,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Thực hiện',
                      style: TextStyle(
                        fontSize: 9, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard({
    required BuildContext context,
    required String icon,
    required String title,
    required int cost,
    required bool isDark,
    String? stockStatus,
    String? hotStatus,
  }) {
    return Card(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkColorScheme.primaryContainer : AppColors.bgBase,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkColorScheme.primaryContainer : AppColors.brandPrimaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$cost Lxu',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
                if (stockStatus != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    stockStatus,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                if (hotStatus != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE7E8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hotStatus,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  if (state.coins < cost) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Số dư Lxu của bạn không đủ!'),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                    return;
                  }
                  final success = await context.read<Health360Cubit>().redeemVoucher(title, cost);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đổi quà thành công: $title!'),
                        backgroundColor: AppColors.successColor,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Đổi quà',
                  style: TextStyle(
                    fontSize: 10,
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
  }

}
