import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../../app/theme/app_theme.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isRecording;
  final bool isPlaying;
  final double playbackProgress;
  final AudioRecorder? recorder;

  const WaveformVisualizer({
    super.key,
    required this.isRecording,
    this.isPlaying = false,
    this.playbackProgress = 0.0,
    this.recorder,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer> {
  Timer? _amplitudeTimer;
  final List<double> _amplitudes = List.generate(30, (index) => 0.05);

  final List<double> _playbackWave = [
    0.2, 0.3, 0.5, 0.4, 0.6, 0.8, 0.7, 0.5, 0.6, 0.8,
    0.9, 0.7, 0.5, 0.4, 0.6, 0.7, 0.8, 0.5, 0.4, 0.3,
    0.4, 0.5, 0.6, 0.5, 0.7, 0.6, 0.4, 0.3, 0.2, 0.1
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isRecording) {
      _startPolling();
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startPolling();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) async {
      if (widget.isRecording && widget.recorder != null) {
        try {
          final amp = await widget.recorder!.getAmplitude();
          double dB = amp.current;
          if (dB < -60) dB = -60;
          if (dB > 0) dB = 0;
          double normalized = (dB + 60) / 60; // 0.0 to 1.0
          // Add a tiny bit of random jitter or minimum height so it's always alive
          normalized = max(0.08, normalized);
          if (mounted) {
            setState(() {
              _amplitudes.removeAt(0);
              _amplitudes.add(normalized);
            });
          }
        } catch (_) {}
      }
    });
  }

  void _stopPolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    if (mounted) {
      setState(() {
        _amplitudes.fillRange(0, _amplitudes.length, 0.05);
      });
    }
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary;
    final inactiveColor = isDark ? const Color(0xFF1E293B) : AppColors.borderColor;

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
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 70),
                    width: 4.5,
                    height: max(4.0, height),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              )
            : (widget.isPlaying || widget.playbackProgress > 0)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_playbackWave.length, (index) {
                      final double progressLimit = index / _playbackWave.length;
                      final bool isPlayed = progressLimit <= widget.playbackProgress;
                      final double height = _playbackWave[index] * 70.0;
                      return Container(
                        width: 4.5,
                        height: max(4.0, height),
                        decoration: BoxDecoration(
                          color: isPlayed ? primaryColor : inactiveColor,
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
                                  primaryColor.withValues(alpha: 0.8),
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
}
