import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../cubit/audio_sed_cubit.dart';
import '../cubit/audio_sed_state.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/wave_visualizer.dart';
import '../../../../core/user_session/presentation/cubit/user_session_cubit.dart';

class AudioAnalysisDetailPage extends StatefulWidget {
  const AudioAnalysisDetailPage({super.key});

  @override
  State<AudioAnalysisDetailPage> createState() =>
      _AudioAnalysisDetailPageState();
}

class _AudioAnalysisDetailPageState extends State<AudioAnalysisDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  double get _playbackProgress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AudioSedCubit, AudioSedState>(
      builder: (context, state) {
        final isRecording = state is AudioSedRecording;
        final isAnalyzing = state is AudioSedAnalyzing;
        final hasResults = state is AudioSedAnalysisSuccess;

        String statusText = 'Sẵn sàng';
        int seconds = 0;
        if (isRecording) {
          seconds = state.elapsedSeconds;
          statusText = '00:0$seconds / 00:05';
        } else if (isAnalyzing) {
          statusText = '00:05 / Đang phân tích...';
        } else if (hasResults) {
          statusText = 'Ghi âm thành công | 00:05 / 00:05';
        }

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1ABCFE), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
            ),
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'PHÂN TÍCH ÂM THANH',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 12, right: 12, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Waveform Card
                Card(
                  elevation: 0,
                  color: isDark
                      ? AppColors.darkColorScheme.surface
                      : AppColors.bgSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkColorScheme.outline
                          : AppColors.borderColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ghi âm và phân tích âm thanh',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Waveform Visualizer Area
                        Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF4F7F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: WaveformVisualizer(
                            isRecording: isRecording,
                            isPlaying: _isPlaying,
                            playbackProgress: _playbackProgress,
                            recorder:
                                context.read<AudioSedCubit>().audioRecorder,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (!isRecording && !isAnalyzing && !hasResults) ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Ấn nút Microphone bên dưới để bắt đầu ghi âm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ] else if (isRecording || isAnalyzing) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isRecording) ...[
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _pulseController.value,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.errorColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                statusText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ] else if (hasResults) ...[
                          Column(
                            children: [
                              Text(
                                statusText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // BtnCancel
                                  OutlinedButton(
                                    onPressed: () async {
                                      await _audioPlayer.stop();
                                      if (mounted) {
                                        setState(() {
                                          _isPlaying = false;
                                          _position = Duration.zero;
                                          _duration = Duration.zero;
                                        });
                                      }
                                      if (context.mounted) {
                                        context.read<AudioSedCubit>().reset();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      backgroundColor: isDark
                                          ? AppColors.darkColorScheme.surface
                                          : AppColors.bgSurface,
                                      side: const BorderSide(
                                          color: AppColors.borderColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text(
                                      'Hủy',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // BtnPlay
                                  ElevatedButton(
                                    onPressed: () async {
                                      final path = state.recordingPath;
                                      if (path != null) {
                                        if (_isPlaying) {
                                          await _audioPlayer.pause();
                                        } else {
                                          await _audioPlayer
                                              .play(DeviceFileSource(path));
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Không tìm thấy tệp tin ghi âm!'),
                                            backgroundColor:
                                                AppColors.errorColor,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.brandPrimaryLight,
                                      foregroundColor: AppColors.brandPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    child: Text(
                                      _isPlaying ? 'Tạm dừng' : 'Nghe lại',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brandPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // BtnAnalyze
                                  ElevatedButton(
                                    onPressed: () {
                                      final path = state.recordingPath;
                                      if (path != null) {
                                        context
                                            .read<AudioSedCubit>()
                                            .analyzeAudioPath(path);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Không tìm thấy đường dẫn ghi âm!'),
                                            backgroundColor:
                                                AppColors.errorColor,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandPrimary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text(
                                      'Phân tích',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // AI Analysis Report Card
                if (hasResults) ...[
                  const SizedBox(height: 12),
                  _buildReportCard(context, state, isDark),
                ],

                if (state is AudioSedError) ...[
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: isDark
                        ? const Color(0xFF2D1A1A)
                        : const Color(0xFFFDE7E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.errorColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.errorColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lỗi phân tích âm thanh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.errorColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.message,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: isAnalyzing
                ? null
                : () {
                    if (isRecording) {
                      context.read<AudioSedCubit>().stopRecordingAndAnalyze();
                    } else {
                      context.read<AudioSedCubit>().startRecording();
                    }
                  },
            backgroundColor:
                isRecording ? AppColors.errorColor : AppColors.brandPrimary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    size: 24,
                  ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildReportCard(
      BuildContext context, AudioSedAnalysisSuccess state, bool isDark) {
    // Dynamically complete task if applicable
    context.read<UserSessionCubit>().completeTask('night_task_1', 20);

    final result = state.result;

    // Helper functions for mapping colors
    Color getRiskColor(String level) {
      switch (level.toUpperCase()) {
        case 'CAO':
          return AppColors.errorColor;
        case 'TRUNG BÌNH':
          return AppColors.warningColor;
        default:
          return AppColors.successColor;
      }
    }

    Color getRiskBg(String level) {
      switch (level.toUpperCase()) {
        case 'CAO':
          return const Color(0xFFFDE7E8);
        case 'TRUNG BÌNH':
          return const Color(0xFFFEF4E6);
        default:
          return const Color(0xFFEAF6EA);
      }
    }

    Color getObstructionColor(String level) {
      switch (level.toLowerCase()) {
        case 'cao':
          return AppColors.errorColor;
        case 'trung bình':
          return AppColors.warningColor;
        default:
          return AppColors.successColor;
      }
    }

    Color getObstructionBg(String level) {
      switch (level.toLowerCase()) {
        case 'cao':
          return const Color(0xFFFDE7E8);
        case 'trung bình':
          return const Color(0xFFFEF4E6);
        default:
          return const Color(0xFFEAF6EA);
      }
    }

    final sinusRisk = result.sinusRisk;
    final obstruction = result.obstruction;
    final checklist = result.treatmentChecklist ?? [];
    final adviceText = result.expertAdvice;

    final hasSinusRisk = sinusRisk != null && sinusRisk.label.isNotEmpty;
    final hasObstruction = obstruction != null && obstruction.level.isNotEmpty;
    final hasChecklist = checklist.isNotEmpty;
    final hasAdviceText = adviceText != null &&
        adviceText.isNotEmpty &&
        adviceText != 'Không có thông tin khuyên dùng.';

    final events = result.events;
    final hasEvents = events.isNotEmpty;
    final hasCough = result.hasCough;
    final coughTypeAnalysis = result.coughTypeAnalysis;
    final hasCoughType = coughTypeAnalysis != null && coughTypeAnalysis.coughType.isNotEmpty;

    final hasAnyData = hasSinusRisk ||
        hasObstruction ||
        hasChecklist ||
        hasAdviceText ||
        hasEvents ||
        hasCoughType;

    // If there is absolutely no report data at all, show informative card
    if (!hasAnyData) {
      return Card(
        elevation: 0,
        color: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? AppColors.darkColorScheme.outline
                : AppColors.borderColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Báo Cáo Phân Tích Âm Thanh',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_outlined,
                      color: AppColors.warningColor,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Không tìm thấy dữ liệu phân tích',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hệ thống không tìm thấy tiếng ho, tiếng thở khò khè hay tiếng ngáy trong tệp ghi âm này. Vui lòng thử lại với bản ghi âm có âm thanh rõ ràng hơn.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade400
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? AppColors.darkColorScheme.outline
              : AppColors.borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Báo Cáo Phân Tích Âm Thanh',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Warning banner if hasCough is true
            if (hasCough) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D1A1A) : const Color(0xFFFDE7E8),
                  border: Border.all(color: AppColors.errorColor, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.errorColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Phát hiện tiếng ho trong ghi âm',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Cough Type classification if available
            if (hasCoughType) ...[
              Builder(builder: (context) {
                final analysis = coughTypeAnalysis;
                final typeName = analysis.coughTypeVi.isNotEmpty ? analysis.coughTypeVi : analysis.coughType;
                final confidencePct = (analysis.confidence * 100).toStringAsFixed(1);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : const Color(0xFFDCFCE7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phân loại tiếng ho:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Độ tin cậy: $confidencePct%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        typeName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Sound events timeline list if available
            if (hasEvents) ...[
              Text(
                'Âm thanh phát hiện được:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...events.map((event) {
                final eventName = event.classNameVi.isNotEmpty ? event.classNameVi : event.className;
                final confidencePct = (event.confidence * 100).toStringAsFixed(1);
                final duration = result.durationSec;
                
                // Custom colors for different event classes
                Color eventColor;
                IconData eventIcon;
                switch (event.className.toLowerCase()) {
                  case 'cough':
                    eventColor = AppColors.errorColor;
                    eventIcon = Icons.warning_amber_rounded;
                    break;
                  case 'wheeze':
                    eventColor = AppColors.warningColor;
                    eventIcon = Icons.air;
                    break;
                  case 'snoring':
                    eventColor = Colors.purple;
                    eventIcon = Icons.nights_stay_outlined;
                    break;
                  case 'breathing':
                    eventColor = AppColors.successColor;
                    eventIcon = Icons.bubble_chart_outlined;
                    break;
                  default:
                    eventColor = AppColors.brandPrimary;
                    eventIcon = Icons.volume_up_outlined;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(eventIcon, color: eventColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  eventName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Độ tin cậy: $confidencePct%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${event.start.toStringAsFixed(2)}s',
                              style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final totalWidth = constraints.maxWidth;
                                  final startPct = duration > 0 ? (event.start / duration) : 0.0;
                                  final endPct = duration > 0 ? (event.end / duration) : 0.0;
                                  final left = startPct * totalWidth;
                                  final width = (endPct - startPct) * totalWidth;
                                  
                                  return Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: left.clamp(0.0, totalWidth),
                                          width: width.clamp(0.0, totalWidth - left),
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: eventColor,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${event.end.toStringAsFixed(2)}s',
                              style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Mucus Risk Alert Box (Dynamic colors and border) - only show if exists
            if (hasSinusRisk) ...[
              Builder(builder: (context) {
                final riskLevel = sinusRisk.level;
                final riskLabel = sinusRisk.label;
                final riskColor = getRiskColor(riskLevel);
                final riskBg = getRiskBg(riskLevel);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: riskBg,
                    border: Border.all(color: riskColor, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: riskColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                riskLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: riskColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Cảnh báo',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Obstruction Row - only show if exists
            if (hasObstruction) ...[
              Builder(builder: (context) {
                final obstructionLevel = obstruction.level;
                final obstructionColor = getObstructionColor(obstructionLevel);
                final obstructionBg = getObstructionBg(obstructionLevel);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkColorScheme.primaryContainer
                        : AppColors.bgBase,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tắc nghẽn hô hấp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: obstructionBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          obstructionLevel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: obstructionColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Treatment Checklist - only show if exists
            if (hasChecklist) ...[
              Text(
                'Hướng dẫn xử trí khuyến dùng:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? Colors.grey.shade300 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...checklist.map((item) {
                final color = item.type == 'success'
                    ? AppColors.successColor
                    : AppColors.textTertiary;
                return _buildChecklistRow(item.text, color, isDark);
              }),
              const SizedBox(height: 12),
            ],

            // Recommendation - only show if exists
            if (hasAdviceText) ...[
              Text(
                adviceText,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Metadata: duration and inference time
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thời lượng: ${result.durationSec.toStringAsFixed(2)}s',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  'Thời gian xử lý: ${result.inferenceTimeMs.toStringAsFixed(1)}ms',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistRow(String text, Color iconColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
