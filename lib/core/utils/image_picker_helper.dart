import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static Future<bool> _ensurePermission(ImageSource source) async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }

    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return true;

      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    final photos = await Permission.photos.request();
    return photos.isGranted || photos.isLimited;
  }

  static Future<XFile?> pickImage(ImageSource source) async {
    final granted = await _ensurePermission(source);
    if (!granted) return null;

    final picker = ImagePicker();
    return picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
  }
}
