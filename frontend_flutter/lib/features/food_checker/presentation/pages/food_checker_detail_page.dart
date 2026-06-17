import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/user_session/presentation/cubit/user_session_cubit.dart';
import '../../../../core/user_session/presentation/cubit/user_session_state.dart';
import '../../../../app/theme/app_theme.dart';

class FoodCheckerDetailPage extends StatefulWidget {
  const FoodCheckerDetailPage({super.key});

  @override
  State<FoodCheckerDetailPage> createState() => _FoodCheckerDetailPageState();
}

class _FoodCheckerDetailPageState extends State<FoodCheckerDetailPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;
  XFile? _capturedFile;
  bool _isCaptured = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializingCamera || _isCameraInitialized) return;
    if (!mounted) return;
    setState(() {
      _isInitializingCamera = true;
    });
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final requestStatus = await Permission.camera.request();
        if (!requestStatus.isGranted) {
          if (mounted) {
            setState(() {
              _isInitializingCamera = false;
            });
          }
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        _cameraController = controller;
        await controller.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isInitializingCamera = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isInitializingCamera = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitializingCamera = false;
        });
      }
    }
  }

  void _disposeCamera({bool isDisposing = false}) {
    if (!isDisposing && mounted) {
      setState(() {
        _isCameraInitialized = false;
        _isInitializingCamera = false;
      });
      // Clear scanned food results from Cubit
      context.read<UserSessionCubit>().clearScannedFood();
    }
    if (_cameraController != null) {
      final controller = _cameraController;
      _cameraController = null;
      controller?.dispose();
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        _isTakingPicture) {
      return;
    }
    setState(() {
      _isTakingPicture = true;
    });
    try {
      final file = await _cameraController!.takePicture();
      setState(() {
        _capturedFile = file;
        _isCaptured = true;
        _isTakingPicture = false;
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _capturedFile = XFile(image.path);
          _isCaptured = true;
        });
        context.read<UserSessionCubit>().clearScannedFood();
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
  }

  @override
  void dispose() {
    try {
      context.read<UserSessionCubit>().clearScannedFood();
    } catch (_) {}
    _disposeCamera(isDisposing: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<UserSessionCubit, UserSessionState>(
      builder: (context, state) {
        final hasResults =
            state.scannedFoodResponse != null && !state.isScanning;

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
              'KIỂM TRA ĐỒ ĂN CHỐNG VIÊM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.errorMsg != null) ...[
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
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.errorColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.errorMsg!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Viewfinder Card (Always visible)
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF131C2E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Camera quét đồ ăn thực tế',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.primaryBlueDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: GestureDetector(
                              onTap: (!_isCameraInitialized ||
                                      _isTakingPicture ||
                                      state.isScanning)
                                  ? null
                                  : () {
                                      if (!_isCaptured) {
                                        _takePicture();
                                      }
                                    },
                              child: Stack(
                                children: [
                                  // Camera stream or captured image or loading preview placeholder
                                  _isCaptured && _capturedFile != null
                                      ? Positioned.fill(
                                          child: Image.file(
                                            File(_capturedFile!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : (_isCameraInitialized &&
                                              _cameraController != null
                                          ? Positioned.fill(
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: SizedBox(
                                                  width: _cameraController!
                                                              .value
                                                              .previewSize !=
                                                          null
                                                      ? _cameraController!.value
                                                          .previewSize!.height
                                                      : 100,
                                                  height: _cameraController!
                                                              .value
                                                              .previewSize !=
                                                          null
                                                      ? _cameraController!.value
                                                          .previewSize!.width
                                                      : 100,
                                                  child: CameraPreview(
                                                      _cameraController!),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: isDark
                                                  ? Colors.black26
                                                  : Colors.black87,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 48,
                                                ),
                                              ),
                                            )),
                                  // Laser line overlay
                                  if (state.isScanning) ...[
                                    const LoopingScanningBar(),
                                    const Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 16.0),
                                        child: Text(
                                          '[ Scanning... ]',
                                          style: TextStyle(
                                            color: AppColors.successColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!state.isScanning)
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.brandPrimary,
                                    side: const BorderSide(
                                        color: AppColors.brandPrimary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                  ),
                                  icon:
                                      const Icon(Icons.photo_library, size: 14),
                                  label: const Text(
                                    'CHỌN TỪ THƯ VIỆN',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _pickFromGallery,
                                ),
                                if (_isCaptured) ...[
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandPrimary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.analytics_outlined,
                                        size: 14, color: Colors.white),
                                    label: const Text(
                                      'PHÂN TÍCH',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      final cubit =
                                          context.read<UserSessionCubit>();
                                      final bytes = _capturedFile != null
                                          ? await _capturedFile!.readAsBytes()
                                          : null;
                                      cubit.runScanner(customImageBytes: bytes);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Results Card
                if (hasResults) ...[
                  _buildResultsCard(context, state, isDark),
                ],
                const SizedBox(height: 80), // Spacer for centered FAB
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: state.isScanning
                ? null
                : () {
                    if (_isCaptured) {
                      setState(() {
                        _isCaptured = false;
                        _capturedFile = null;
                      });
                      context.read<UserSessionCubit>().clearScannedFood();
                    } else if (!_isCameraInitialized) {
                      _initializeCamera();
                    } else {
                      _takePicture();
                    }
                  },
            backgroundColor: _isCaptured ? Colors.red : AppColors.brandPrimary,
            shape: const CircleBorder(),
            child: state.isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isCaptured
                        ? Icons.close
                        : (!_isCameraInitialized
                            ? Icons.videocam
                            : Icons.camera_alt),
                    color: Colors.white,
                    size: 24,
                  ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildResultsCard(
      BuildContext context, UserSessionState state, bool isDark) {
    final response = state.scannedFoodResponse!;

    // Parse detected foods
    final List<dynamic> foods = response['foods'] ?? [];

    if (foods.isEmpty) {
      final String message = response['message_vi'] ??
          'Không tìm thấy thông tin thức ăn trên ảnh. Bạn cần kiểm tra lại đã đưa đúng camera vào món ăn chưa.';
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
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Không tìm thấy',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
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

    final List<String> foodNames =
        foods.map((f) => (f['name_vi'] ?? f['name'] ?? '').toString()).toList();
    final String foodName =
        foodNames.isNotEmpty ? foodNames.join(', ') : 'Món Ăn';

    // Parse nutrition
    final Map<String, dynamic> nutrition = response['total_nutrition'] ?? {};
    final num calories = nutrition['Calories'] ?? 0;
    final num fat = nutrition['Fat'] ?? 0;
    final num saturates = nutrition['Saturates'] ?? 0;
    final num sugar = nutrition['Sugar'] ?? 0;
    final num salt = nutrition['Salt'] ?? 0;

    // Parse alerts
    final List<dynamic> alerts = response['risk_alerts'] ?? [];

    String statusLabel = 'An toàn - Chống viêm';
    Color badgeColor = AppColors.successColor;
    Color badgeBg = const Color(0xFFE9FBF2);

    final bool hasDanger = alerts.any((a) => a['severity'] == 'danger');
    final bool hasWarning = alerts.any((a) => a['severity'] == 'warning');

    if (hasDanger) {
      statusLabel = 'Nguy cơ cao';
      badgeColor = AppColors.errorColor;
      badgeBg = const Color(0xFFFDE7E8);
    } else if (hasWarning) {
      statusLabel = 'Cần hạn chế';
      badgeColor = AppColors.warningColor;
      badgeBg = const Color(0xFFFFF3E6);
    }

    final double antiInflamScore = hasDanger ? 3.5 : (hasWarning ? 5.5 : 8.5);
    final String ratingText =
        'Chỉ số chống viêm: $antiInflamScore/10 (${antiInflamScore >= 8.0 ? "Rất tốt" : (antiInflamScore >= 5.0 ? "Trung bình" : "Hạn chế")})';

    // Parse tags from backend
    final List<dynamic> backendTags = response['food_tags'] ?? [];
    final tags = backendTags.map((t) {
      return {
        'text': (t['text'] ?? '').toString(),
        'type': (t['type'] ?? 'neutral').toString(),
      };
    }).toList();

    if (tags.isEmpty) {
      tags.add({'text': 'Thành phần chính - Tốt', 'type': 'success'});
    }

    String adviceText = (response['advice_text'] ??
            'Món ăn không chứa thành phần gây kích ứng, an toàn để sử dụng.')
        .toString();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    foodName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating Highlight Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ratingText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tags Container
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((t) {
                final String text = t['text']!;
                final String type = t['type']!;
                Color bgCol;
                Color textCol;
                if (type == 'success') {
                  bgCol = const Color(0xFFE9FBF2);
                  textCol = AppColors.successColor;
                } else if (type == 'error') {
                  bgCol = const Color(0xFFFDE7E8);
                  textCol = AppColors.errorColor;
                } else {
                  bgCol = isDark
                      ? AppColors.darkColorScheme.primaryContainer
                      : AppColors.bgBase;
                  textCol =
                      isDark ? Colors.grey.shade300 : AppColors.textSecondary;
                }
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgCol,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Nutrition Chips Row
            () {
              final Color chipColor =
                  isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildNutritionChip(
                        'Calo',
                        '${calories.toStringAsFixed(0)} kcal',
                        chipColor,
                        isDark),
                    const SizedBox(width: 6),
                    _buildNutritionChip('Chất béo',
                        '${fat.toStringAsFixed(1)}g', chipColor, isDark),
                    const SizedBox(width: 6),
                    _buildNutritionChip('Béo bão hòa',
                        '${saturates.toStringAsFixed(1)}g', chipColor, isDark),
                    const SizedBox(width: 6),
                    _buildNutritionChip('Đường', '${sugar.toStringAsFixed(1)}g',
                        chipColor, isDark),
                    const SizedBox(width: 6),
                    _buildNutritionChip('Muối', '${salt.toStringAsFixed(2)}g',
                        chipColor, isDark),
                  ],
                ),
              );
            }(),
            const SizedBox(height: 12),

            // Warnings/Alerts Section
            if (alerts.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FBF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.successColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thực phẩm an toàn, không phát hiện nguy cơ kích ứng cho hồ sơ của bạn.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...alerts.map((alert) {
                final String msg = alert['message_vi'] ?? '';
                final String severity = alert['severity'] ?? 'warning';
                final bool isDanger = severity == 'danger';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDanger
                          ? const Color(0xFFFDE7E8)
                          : const Color(0xFFFFF3E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDanger
                              ? Icons.warning_amber_rounded
                              : Icons.notifications_none_outlined,
                          size: 16,
                          color: isDanger
                              ? AppColors.errorColor
                              : AppColors.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            msg,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDanger
                                  ? AppColors.errorColor
                                  : AppColors.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),

            // AI Recommendation text
            Text(
              adviceText,
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

  Widget _buildNutritionChip(
      String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: isDark ? Colors.grey.shade400 : AppColors.textTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class LoopingScanningBar extends StatefulWidget {
  const LoopingScanningBar({super.key});

  @override
  State<LoopingScanningBar> createState() => _LoopingScanningBarState();
}

class _LoopingScanningBarState extends State<LoopingScanningBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, -1.0 + (_animationController.value * 2.0)),
          child: Container(
            width: double.infinity,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.successColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.successColor,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
