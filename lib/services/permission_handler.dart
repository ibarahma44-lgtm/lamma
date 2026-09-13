import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PermissionHandler {
  static Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true; // Web doesn't need storage permission

    if (await Permission.storage.request().isGranted) {
      return true;
    }

    // For Android 13 and above, we need to request photos permission
    if (await Permission.photos.request().isGranted) {
      return true;
    }

    // For Android 10 and above, we need to request media permission
    if (await Permission.mediaLibrary.request().isGranted) {
      return true;
    }

    return false;
  }

  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true; // Web doesn't need camera permission

    if (await Permission.camera.request().isGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> requestPhotosPermission() async {
    if (kIsWeb) return true; // Web doesn't need photos permission

    if (await Permission.photos.request().isGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> requestAllMediaPermissions() async {
    if (kIsWeb) return true;

    // Request all necessary permissions
    final storageStatus = await Permission.storage.request();
    final photosStatus = await Permission.photos.request();
    final mediaStatus = await Permission.mediaLibrary.request();

    return storageStatus.isGranted ||
        photosStatus.isGranted ||
        mediaStatus.isGranted;
  }
}
