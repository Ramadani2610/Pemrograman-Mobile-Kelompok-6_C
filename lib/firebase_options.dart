// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // =================================================================
  // BAGIAN WEB (Isi dengan data dari Layar "Config" di Website Firebase)
  // =================================================================
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcdKIDCCblHuPlqFaAAY5Eyhfee12fLzk',
    appId: '1:694348068686:web:42038c3f03fe5de83c901f',
    messagingSenderId: '694348068686',
    projectId: 'spare-app-unhas', // Sesuaikan jika di web beda
    authDomain: 'spare-app-unhas.firebaseapp.com', // Sesuaikan
    storageBucket: 'spare-app-unhas.firebasestorage.app', // Sesuaikan
    // measurementId tidak wajib, boleh dihapus kalau error
  );

  // =================================================================
  // BAGIAN ANDROID (Biarkan Dummy dulu tidak apa-apa untuk Chrome)
  // Karena di Android kita sudah pakai google-services.json
  // =================================================================
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcdKIDCCblHuPlqFaAAY5Eyhfee12fLzk',
    appId: '1:694348068686:android:bde844c53623e0353c901f',
    messagingSenderId: '694348068686',
    projectId: 'spare-app-unhas',
    databaseURL: 'https://spareapp-unhas-dev.firebaseio.com',
    storageBucket: 'spareapp-unhas-dev.appspot.com',
  );
}
