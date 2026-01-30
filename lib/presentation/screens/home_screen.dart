import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/preset_provider.dart';
import '../../domain/providers/image_picker_provider.dart';
import '../../domain/providers/analysis_provider.dart';
import '../../domain/providers/history_provider.dart';
import 'result_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetsProvider);
    final selectedPresetId = ref.watch(selectedPresetProvider);
    final analysisState = ref.watch(analysisProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('패션 평가'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('앱 정보'),
                  content: const Text(
                    '냉정하고 솔직한 패션 코디 평가 앱\n\n'
                    '사진 한 장으로 즉시 분석합니다.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 프리셋 선택
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '평가 기준 선택',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          presetsAsync.when(
                            data: (presets) {
                              final selectedPreset = presets.firstWhere(
                                (p) => p.id == selectedPresetId,
                                orElse: () => presets.first,
                              );
                              return Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    initialValue: selectedPresetId,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
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
                                                  selectedPresetProvider
                                                      .notifier,
                                                )
                                                .state =
                                            value;
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    selectedPreset.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => const Text('프리셋 로딩 실패'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 촬영/갤러리 버튼
                  _buildActionButtons(context, ref),
                  const SizedBox(height: 32),

                  // 최근 히스토리
                  if (history.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '최근 분석',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(historyProvider.notifier).clearAll();
                          },
                          child: const Text('전체 삭제'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final result = history[index];
                          return _buildHistoryItem(context, ref, result);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _handleCamera(context, ref),
          icon: const Icon(Icons.camera_alt, size: 28),
          label: const Text('카메라로 촬영', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _handleGallery(context, ref),
          icon: const Icon(Icons.photo_library, size: 28),
          label: const Text('갤러리에서 선택', style: TextStyle(fontSize: 18)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            side: const BorderSide(color: Colors.black, width: 2),
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
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

  Future<void> _handleCamera(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(imagePickerNotifierProvider.notifier);
    final imageFile = await notifier.pickFromCamera();

    if (imageFile != null && context.mounted) {
      _analyzeImage(context, ref, imageFile);
    }
  }

  Future<void> _handleGallery(BuildContext context, WidgetRef ref) async {
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
