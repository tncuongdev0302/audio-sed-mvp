import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/user_session/presentation/cubit/user_session_cubit.dart';
import '../../../../core/user_session/presentation/cubit/user_session_state.dart';

class AIHealth360AppBar extends StatefulWidget {
  const AIHealth360AppBar({super.key});

  @override
  State<AIHealth360AppBar> createState() => _AIHealth360AppBarState();
}

class _AIHealth360AppBarState extends State<AIHealth360AppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<UserSessionCubit, UserSessionState>(
      builder: (context, state) {
        final userName = state.userContext?['name'] ?? 'Tuấn';
        final isNight = state.timeOfDay == 'night';

        // 1. Day / Night Gradients
        final headerGradient = isNight
            ? const LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                  Color(0xFF311042)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFF1ABCFE),
                  Color(0xFF0284C7),
                  Color(0xFF0369A1)
                ],
                stops: [0.0, 0.6, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              );

        return Container(
          decoration: BoxDecoration(
            gradient: headerGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Custom Navigation Row (Welcome Text + Fsell & Avatar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Welcome text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào $userName!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1.5),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isNight
                                ? 'Chúc bạn tối ngủ ngon giấc!'
                                : 'Chúc bạn ngày mới khỏe mạnh!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Fsell points & Profile Avatar (shifted left to avoid mascot overlap)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDB022), // Gold Fsell
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.coins} Fsell',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Critical Alert Banner (Highlighted & glowing)
                if (state.userContext?['alerts'] != null &&
                    (state.userContext?['alerts'] as List).isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3B1E1E)
                            : const Color(0xFFFFF1F2),
                        border: Border.all(
                            color: const Color(0xFFF43F5E), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFF43F5E).withValues(alpha: 0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_rounded,
                            size: 20,
                            color: Color(0xFFF43F5E),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              (state.userContext?['alerts'] as List)[0]
                                      ['body'] ??
                                  'Cảnh báo sức khỏe',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF43F5E),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom Border Separator
                Container(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.black.withValues(alpha: 0.05),
                  height: 1.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 2. Custom Peeking Mascot Widget
class MascotPeekingWidget extends StatelessWidget {
  final bool isDark;
  const MascotPeekingWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 120,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Blue robot body
          Positioned(
            bottom: -25,
            child: Container(
              width: 80,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Container(
                    width: 32,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Blue robot head
          Positioned(
            bottom: 16,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Face plate
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left eye (winking)
                        Positioned(
                          left: 8,
                          top: 20,
                          child: Container(
                            width: 12,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        // Right eye (open and shining)
                        Positioned(
                          right: 8,
                          top: 14,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFF007AFF),
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: const Alignment(0.3, -0.3),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Pink cheeks
                        Positioned(
                          left: 6,
                          bottom: 10,
                          child: Container(
                            width: 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  Colors.pink.shade200.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 10,
                          child: Container(
                            width: 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  Colors.pink.shade200.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Cute smile
                        Positioned(
                          bottom: 12,
                          child: Icon(
                            Icons.sentiment_satisfied_alt,
                            size: 13,
                            color:
                                const Color(0xFF007AFF).withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // White headband antenna
                  Positioned(
                    top: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
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
}
