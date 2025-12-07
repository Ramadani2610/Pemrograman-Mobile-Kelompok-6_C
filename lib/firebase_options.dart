import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'spareapp-unhas-dev',
    authDomain: 'spareapp-unhas-dev.firebaseapp.com',
    databaseURL: 'https://spareapp-unhas-dev.firebaseio.com',
    storageBucket: 'spareapp-unhas-dev.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'spareapp-unhas-dev',
    databaseURL: 'https://spareapp-unhas-dev.firebaseio.com',
    storageBucket: 'spareapp-unhas-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'spareapp-unhas-dev',
    databaseURL: 'https://spareapp-unhas-dev.firebaseio.com',
    storageBucket: 'spareapp-unhas-dev.appspot.com',
    iosClientId:
        '000000000000-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosBundleId: 'com.example.spareappUnhas',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:000000000000:macos:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'spareapp-unhas-dev',
    databaseURL: 'https://spareapp-unhas-dev.firebaseio.com',
    storageBucket: 'spareapp-unhas-dev.appspot.com',
    iosClientId:
        '000000000000-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosBundleId: 'com.example.spareappUnhas',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:000000000000:windows:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'spareapp-unhas-dev',
    databaseURL: 'https://spareapp-unhas-dev.firebaseio.com',
    storageBucket: 'spareapp-unhas-dev.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:000000000000:linux:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'spareapp-unhas-dev',
    databaseURL: 'https://spareapp-unhas-dev.firebaseio.com',
    storageBucket: 'spareapp-unhas-dev.appspot.com',
  );
}
