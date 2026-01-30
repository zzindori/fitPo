import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/preset_provider.dart';
import '../../domain/providers/image_picker_provider.dart';
import '../../domain/providers/analysis_provider.dart';
import '../../domain/providers/history_provider.dart';
import 'result_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isCameraError = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _isCameraError = true);
        }
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _isCameraError = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isCameraError = true);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetsProvider);
    final selectedPresetId = ref.watch(selectedPresetProvider);
    final analysisState = ref.watch(analysisProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: analysisState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('분석 중...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Stack(
              children: [
                Positioned.fill(child: _buildCameraSurface()),
                Positioned(
                  top: 0,
                  left: 12,
                  right: 12,
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: presetsAsync.when(
                        data: (presets) {
                          final selectedPreset = presets.firstWhere(
                            (p) => p.id == selectedPresetId,
                            orElse: () => presets.first,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: selectedPresetId,
                                dropdownColor: Colors.black87,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.35),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: presets.map((preset) {
                                  return DropdownMenuItem(
                                    value: preset.id,
                                    child: Text(preset.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                            .read(
                                              selectedPresetProvider.notifier,
                                            )
                                            .state =
                                        value;
                                  }
                                },
                              ),
                              const SizedBox(height: 6),
                              Text(
                                selectedPreset.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => const Text(
                          '프리셋 로딩 실패',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 촬영 버튼 (큰 원형, 정가운데)
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCapturing
                                  ? Colors.grey[600]
                                  : Colors.grey[300],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _isCapturing
                                  ? null
                                  : () => _captureAndAnalyze(context),
                              icon: Icon(
                                _isCapturing
                                    ? Icons.hourglass_empty
                                    : Icons.camera_alt,
                                color: Colors.black87,
                                size: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          // 갤러리 버튼 (작은 원형, 왼쪽)
                          Positioned(
                            left: MediaQuery.of(context).size.width / 2 - 110,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                                border: Border.all(
                                  color: Colors.white70,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () => _handleGallery(context),
                                icon: const Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCameraSurface() {
    if (_isCameraError) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.grey[800]!],
          ),
        ),
        child: const Center(
          child: Text(
            '카메라를 불러올 수 없습니다',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (!_isCameraReady || _cameraController == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.grey[800]!],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    dynamic result,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(result.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${result.totalScore}점',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndAnalyze(BuildContext context) async {
    if (!_isCameraReady || _cameraController == null || _isCapturing) {
      return;
    }

    try {
      setState(() => _isCapturing = true);
      final image = await _cameraController!.takePicture();
      if (!mounted) return;
      final imageFile = File(image.path);
      _analyzeImage(context, ref, imageFile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('촬영 실패: $e')));
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _handleGallery(BuildContext context) async {
    final notifier = ref.read(imagePickerNotifierProvider.notifier);
    final imageFile = await notifier.pickFromGallery();

    if (imageFile != null && context.mounted) {
      _analyzeImage(context, ref, imageFile);
    }
  }

  Future<void> _analyzeImage(
    BuildContext context,
    WidgetRef ref,
    File imageFile,
  ) async {
    final presetId = ref.read(selectedPresetProvider);
    final analysisNotifier = ref.read(analysisProvider.notifier);

    await analysisNotifier.analyze(imageFile: imageFile, presetId: presetId);

    final state = ref.read(analysisProvider);

    if (state.error != null) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('분석 실패'),
            content: Text(state.error!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _analyzeImage(context, ref, imageFile);
                },
                child: const Text('재시도'),
              ),
            ],
          ),
        );
      }
    } else if (state.result != null) {
      if (context.mounted) {
        // 히스토리 갱신
        ref.read(historyProvider.notifier).loadHistory();

        // 결과 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(result: state.result!),
          ),
        );
      }
    }
  }
}
