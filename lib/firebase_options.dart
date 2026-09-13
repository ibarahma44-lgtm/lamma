import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyClfFavfTDy7zQKeAUwMsYlyo-htoAlUys",
    authDomain: "lamma-aq0sqq.firebaseapp.com",
    projectId: "lamma-aq0sqq",
    storageBucket: "lamma-aq0sqq-knv7x",
    messagingSenderId: "353038847473",
    appId: "1:353038847473:web:3d5b79f1bea6c2ccfac850",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPl5uAbVa7Rb1G7Nb4Jhxw7M1tKwCwaks',
    appId: '1:353038847473:android:737baaeb87da8e1dfac850',
    messagingSenderId: '353038847473',
    projectId: 'lamma-aq0sqq',
    storageBucket: 'lamma-aq0sqq-knv7x',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyClfFavfTDy7zQKeAUwMsYlyo-htoAlUys",
    appId: "1:353038847473:ios:737baaeb87da8e1dfac850",
    messagingSenderId: "353038847473",
    projectId: "lamma-aq0sqq",
    storageBucket: "lamma-aq0sqq-knv7x",
    iosClientId: "353038847473-ios.apps.googleusercontent.com",
    iosBundleId: "com.lamma.app",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyClfFavfTDy7zQKeAUwMsYlyo-htoAlUys",
    appId: "1:353038847473:ios:737baaeb87da8e1dfac850",
    messagingSenderId: "353038847473",
    projectId: "lamma-aq0sqq",
    storageBucket: "lamma-aq0sqq-knv7x",
    iosClientId: "353038847473-macos.apps.googleusercontent.com",
    iosBundleId: "com.lamma.app",
  );
}
