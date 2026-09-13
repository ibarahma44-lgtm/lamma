import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermissions() async {
    if (!kIsWeb) {
      // Request storage permission for Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          // Handle the case where user denied the permission
          print('Storage permission denied');
        }
      }
    }
  }
}
