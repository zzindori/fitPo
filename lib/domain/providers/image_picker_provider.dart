import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// ImagePicker 인스턴스 Provider
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

/// 선택된 이미지 Provider
final selectedImageProvider = StateProvider<File?>((ref) => null);

/// 이미지 선택 액션 Provider
class ImagePickerNotifier extends StateNotifier<AsyncValue<File?>> {
  final ImagePicker _picker;

  ImagePickerNotifier(this._picker) : super(const AsyncValue.data(null));

  /// 갤러리에서 이미지 선택
  Future<File?> pickFromGallery() async {
    state = const AsyncValue.loading();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        state = AsyncValue.data(file);
        return file;
      } else {
        state = const AsyncValue.data(null);
        return null;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// 카메라로 촬영
  Future<File?> pickFromCamera() async {
    state = const AsyncValue.loading();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        state = AsyncValue.data(file);
        return file;
      } else {
        state = const AsyncValue.data(null);
        return null;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final imagePickerNotifierProvider =
    StateNotifierProvider<ImagePickerNotifier, AsyncValue<File?>>((ref) {
      final picker = ref.watch(imagePickerProvider);
      return ImagePickerNotifier(picker);
    });
