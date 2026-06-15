import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../cubit/audio_sed_cubit.dart';
import '../cubit/audio_sed_state.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/wave_visualizer.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';

class AudioAnalysisDetailPage extends StatefulWidget {
  const AudioAnalysisDetailPage({super.key});

  @override
  State<AudioAnalysisDetailPage> createState() => _AudioAnalysisDetailPageState();
}

class _AudioAnalysisDetailPageState extends State<AudioAnalysisDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

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
          backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0C1220) : AppColors.brandPrimary,
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
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Waveform Card
                Card(
                  elevation: 0,
                  color: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppColors.darkColorScheme.outline : AppColors.borderColor,
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
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Waveform Visualizer Area
                        Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F7F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: WaveformVisualizer(
                            isRecording: isRecording || isAnalyzing,
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
                                      if (context.mounted) {
                                        context.read<AudioSedCubit>().reset();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      backgroundColor: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
                                      side: const BorderSide(color: AppColors.borderColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                          await _audioPlayer.play(DeviceFileSource(path));
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Không tìm thấy tệp tin ghi âm!'),
                                            backgroundColor: AppColors.errorColor,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandPrimaryLight,
                                      foregroundColor: AppColors.brandPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Bản thu âm đã được phân tích thành công!'),
                                          backgroundColor: AppColors.successColor,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandPrimary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: isAnalyzing
                ? null
                : () {
                    if (isRecording) {
                      context.read<AudioSedCubit>().stopRecordingAndAnalyze('v1');
                    } else {
                      context.read<AudioSedCubit>().startRecording('v1');
                    }
                  },
            backgroundColor: isRecording ? AppColors.errorColor : AppColors.brandPrimary,
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
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildReportCard(BuildContext context, AudioSedAnalysisSuccess state, bool isDark) {
    // Dynamically complete task if applicable
    context.read<Health360Cubit>().completeTask('night_task_1', 20);

    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkColorScheme.surface : AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkColorScheme.outline : AppColors.borderColor,
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

            // Mucus Risk Alert Box (Red border and red background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE7E8),
                border: Border.all(color: AppColors.errorColor, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        '⚠️',
                        style: TextStyle(fontSize: 12, color: AppColors.errorColor),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Nguy cơ ứ đọng dịch xoang sau: 88% (CAO)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor,
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
            ),
            const SizedBox(height: 12),

            // Obstruction Row (Yellow warning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkColorScheme.primaryContainer : AppColors.bgBase,
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF4E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Trung bình',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Treatment Checklist
            Text(
              'Hướng dẫn xử trí khuyến dùng:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _buildChecklistRow('Rửa mũi bằng nước muối sinh lý ấm (Ưu tiên)', AppColors.successColor, isDark),
            _buildChecklistRow('Súc họng bằng dung dịch sát khuẩn miệng', AppColors.successColor, isDark),
            _buildChecklistRow('Uống nhiều nước ấm và hạn chế ngồi điều hòa lạnh', AppColors.textTertiary, isDark),
            const SizedBox(height: 12),

            // Recommendation
            Text(
              'Lời khuyên của chuyên gia: Phân tích tần số âm cho thấy tiếng ho có độ đục âm vòm họng cao (dấu hiệu dịch tích tụ xoang sàng sau). Hãy thực hiện rửa mũi và xịt kháng viêm. Nếu tình trạng nghẹt mũi và ho kéo dài trên 3 ngày, vui lòng kết nối ngay với bác sĩ để nhận tư vấn phác đồ điều trị.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                height: 1.4,
              ),
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
