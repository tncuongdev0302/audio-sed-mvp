import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isRecording;

  const WaveformVisualizer({
    super.key,
    required this.isRecording,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _amplitudes = List.generate(20, (index) => 0.15);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (widget.isRecording) {
          setState(() {
            for (int i = 0; i < _amplitudes.length; i++) {
              _amplitudes[i] = 0.15 + _random.nextDouble() * 0.75;
            }
          });
        }
      });

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
      setState(() {
        for (int i = 0; i < _amplitudes.length; i++) {
          _amplitudes[i] = 0.08;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: widget.isRecording
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_amplitudes.length, (index) {
                  final double height = _amplitudes[index] * 70.0;
                  final Color color = _getColorForIndex(index, _amplitudes.length, isDark);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 4.5,
                    height: max(4.0, height),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white12,
                              Colors.white24,
                              (isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary).withValues(alpha: 0.8),
                              Colors.white24,
                              Colors.white12,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Color _getColorForIndex(int index, int total, bool isDark) {
    if (index < 12) {
      return isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary;
    } else {
      return isDark ? const Color(0xFF1E293B) : AppColors.brandPrimaryLight;
    }
  }
}
