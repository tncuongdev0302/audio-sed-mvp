import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/user_session/presentation/cubit/user_session_cubit.dart';
import '../../../../core/user_session/presentation/cubit/user_session_state.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../../missions/presentation/pages/missions_page.dart';
import '../../../missions/presentation/pages/weekly_summary_page.dart';
import '../../../handbook/presentation/pages/handbook_page.dart';
import '../widgets/ai_health_360_app_bar.dart';

class MainLayoutPage extends StatelessWidget {
  const MainLayoutPage({super.key});

  String _getSymptomProfile(Map<String, bool> symptoms) {
    if (symptoms.isEmpty) return 'Chưa có hồ sơ';
    List<String> active = [];
    if (symptoms['nose_weather'] == true) active.add('Dị ứng thời tiết');
    if (symptoms['nose_food'] == true) active.add('Viêm mũi dị ứng');
    if (symptoms['throat_cough'] == true) active.add('Viêm họng hạt');
    if (symptoms['throat_snore'] == true) active.add('Ngủ ngáy');
    if (active.isEmpty) return 'Bình thường';
    return active.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return BlocConsumer<UserSessionCubit, UserSessionState>(
      listenWhen: (previous, current) =>
          current.errorMsg != null && previous.errorMsg != current.errorMsg,
      listener: (context, state) {
        if (state.errorMsg != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMsg!),
              backgroundColor: AppColors.errorColor,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<UserSessionCubit>().clearError();
        }
      },
      builder: (context, state) {
        final int currentIndex = state.currentTab;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          body: Column(
            children: [
              const AIHealth360AppBar(),
              Expanded(
                child: IndexedStack(
                  index: currentIndex,
                  children: [
                    HomePage(
                        coins: state.coins,
                        symptomProfile: _getSymptomProfile(state.symptoms)),
                    AIAssistantPage(
                        coins: state.coins,
                        symptomProfile: _getSymptomProfile(state.symptoms)),
                    MissionsPage(state: state),
                    HandbookPage(
                        coins: state.coins,
                        symptomProfile: _getSymptomProfile(state.symptoms)),
                    const WeeklySummaryPage(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context: context,
                      index: 0,
                      currentIndex: currentIndex,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Trang chủ',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 1,
                      currentIndex: currentIndex,
                      icon: Icons.smart_toy_outlined,
                      activeIcon: Icons.smart_toy,
                      label: 'Trợ lý AI',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 2,
                      currentIndex: currentIndex,
                      icon: Icons.task_alt,
                      activeIcon: Icons.task_alt,
                      label: 'Nhiệm vụ',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 3,
                      currentIndex: currentIndex,
                      icon: Icons.menu_book_outlined,
                      activeIcon: Icons.menu_book,
                      label: 'Cẩm nang',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 4,
                      currentIndex: currentIndex,
                      icon: Icons.history,
                      activeIcon: Icons.history,
                      label: 'Báo cáo',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
    required Color primaryColor,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected
        ? primaryColor
        : (isDark ? Colors.grey.shade400 : AppColors.textTertiary);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.read<UserSessionCubit>().setTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
