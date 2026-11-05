import 'dart:io';

import 'package:image_picker/image_picker.dart' as picker;

/// Contract for selecting images via the gallery or the device camera.
abstract class ImagePickerService {
  Future<File?> pickFromGallery();
  Future<File?> pickFromCamera();
}

/// Standard production implementation using the official `image_picker` package.
class DefaultImagePickerService implements ImagePickerService {
  DefaultImagePickerService({picker.ImagePicker? pickerInstance})
    : _picker = pickerInstance ?? picker.ImagePicker();

  final picker.ImagePicker _picker;

  @override
  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(source: picker.ImageSource.gallery);
    if (xFile == null) return null;
    return File(xFile.path);
  }

  @override
  Future<File?> pickFromCamera() async {
    final xFile = await _picker.pickImage(source: picker.ImageSource.camera);
    if (xFile == null) return null;
    return File(xFile.path);
  }
}
