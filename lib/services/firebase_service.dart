import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_performance/firebase_performance.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  late FirebaseAuth _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebasePerformance? _performance;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize core Firebase first with options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _auth = FirebaseAuth.instance;
    _isInitialized = true;
  }

  // Lazy load Firestore when needed
  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  // Lazy load Storage when needed
  FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  // Lazy load Performance when needed
  FirebasePerformance get performance {
    _performance ??= FirebasePerformance.instance;
    return _performance!;
  }

  // Get auth instance
  FirebaseAuth get auth {
    if (!_isInitialized) {
      throw Exception(
          'FirebaseService not initialized. Call initialize() first.');
    }
    return _auth;
  }
}
