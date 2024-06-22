 
 
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
        return windows;
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
    apiKey: 'AIzaSyAU-xWfBorSACbWIg9wnp3hYEhZlRglGcE',
    appId: '1:771481032401:web:dae96756c2f5b9aae8d7f0',
    messagingSenderId: '771481032401',
    projectId: 'projectuas-worldle',
    authDomain: 'projectuas-worldle.firebaseapp.com',
    storageBucket: 'projectuas-worldle.appspot.com',
    measurementId: 'G-TDYJ7SZMNF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBitdx8rvvlvcvMIX2ioOGBQbLmj_vg6MQ',
    appId: '1:771481032401:android:c0c81da7c6c93704e8d7f0',
    messagingSenderId: '771481032401',
    projectId: 'projectuas-worldle',
    storageBucket: 'projectuas-worldle.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNrfUSbJkbaKJVa42tK1XH8bBEgFd12gI',
    appId: '1:771481032401:ios:fd320b0f39308b8fe8d7f0',
    messagingSenderId: '771481032401',
    projectId: 'projectuas-worldle',
    storageBucket: 'projectuas-worldle.appspot.com',
    iosBundleId: 'com.example.worldleGame',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNrfUSbJkbaKJVa42tK1XH8bBEgFd12gI',
    appId: '1:771481032401:ios:fd320b0f39308b8fe8d7f0',
    messagingSenderId: '771481032401',
    projectId: 'projectuas-worldle',
    storageBucket: 'projectuas-worldle.appspot.com',
    iosBundleId: 'com.example.worldleGame',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAU-xWfBorSACbWIg9wnp3hYEhZlRglGcE',
    appId: '1:771481032401:web:01d6001711a7391ae8d7f0',
    messagingSenderId: '771481032401',
    projectId: 'projectuas-worldle',
    authDomain: 'projectuas-worldle.firebaseapp.com',
    storageBucket: 'projectuas-worldle.appspot.com',
    measurementId: 'G-3503JXJ5FG',
  );
}
