import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '/firebase_options.dart';

Future<void> initFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      print('Firebase already initialized with ${Firebase.apps.length} app(s)');
      print('Default app name: ${Firebase.app().name}');
      return;
    }

    print('Initializing Firebase for ${kIsWeb ? 'web' : 'mobile'} platform...');

    final options = kIsWeb
        ? DefaultFirebaseOptions.web
        : DefaultFirebaseOptions.currentPlatform;

    print('Using Firebase options:');
    print('Project ID: ${options.projectId}');
    print('Storage Bucket: ${options.storageBucket}');

    final app = await Firebase.initializeApp(options: options);
    print('Firebase initialized successfully:');
    print('App name: ${app.name}');
    print('Project ID: ${app.options.projectId}');
    print('Storage Bucket: ${app.options.storageBucket}');
  } catch (e, stackTrace) {
    print('Error initializing Firebase:');
    print('Error: $e');
    print('Stack trace:');
    print(stackTrace);
    rethrow;
  }
}
