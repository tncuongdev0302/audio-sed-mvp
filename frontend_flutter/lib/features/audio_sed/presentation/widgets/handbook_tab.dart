import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';


class HandbookTab extends StatelessWidget {
  final int coins;
  final String symptomProfile;

  const HandbookTab({
    super.key,
    required this.coins,
    required this.symptomProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // Personalized Article Feed
          // Article 1
          _buildArticleCard(
            context: context,
            icon: '🌤️',
            title: 'Cách phòng ngừa viêm xoang trong mùa nắng nóng cực hạn',
            category: 'Thời tiết',
            readTime: '5 phút đọc',
            views: '👁️ 1.2k lượt đọc',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          // Article 2
          _buildArticleCard(
            context: context,
            icon: '🥗',
            title: 'Top 5 thực phẩm kháng viêm tự nhiên cực tốt cho xoang',
            category: 'Dinh dưỡng',
            readTime: '4 phút đọc',
            views: '👁️ 850 lượt đọc',
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Emergency O2O Pharmacist Call Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkColorScheme.primaryContainer : AppColors.brandPrimaryLight,
              border: Border.all(
                color: isDark ? AppColors.darkColorScheme.outline : AppColors.brandPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🧑‍⚕️',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Dược sĩ Long Châu 24/7',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tư vấn miễn phí qua điện thoại',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                          color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang kết nối cuộc gọi đến dược sĩ Long Châu... 📞'),
                        backgroundColor: AppColors.brandPrimary,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Gọi ngay',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildArticleCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String category,
    required String readTime,
    required String views,
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
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đang mở bài viết: "$title"...'),
              backgroundColor: AppColors.brandPrimary,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkColorScheme.primaryContainer : AppColors.bgBase,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkColorScheme.primaryContainer : AppColors.brandPrimaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkColorScheme.primaryContainer : AppColors.bgBase,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            readTime,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.normal,
                              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      views,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
