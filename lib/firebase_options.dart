import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options.
/// 
/// To get your Firebase configuration:
/// 1. Go to Firebase Console (https://console.firebase.google.com)
/// 2. Select your project
/// 3. Go to Project Settings
/// 4. Download the google-services.json (Android) and GoogleService-Info.plist (iOS)
/// 5. Run: `flutterfire configure`
/// 
/// This will automatically generate the correct firebase_options.dart file

  const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyARAWqdo8qu5n3Ebx4G4IyVOguYKrZd_a0',
    appId: '1:196764354205:web:c72edb7bdc47758f7fb674',
    messagingSenderId: '196764354205',
    projectId: 'migynaeblogs',
    authDomain: 'migynaeblogs.firebaseapp.com',
    storageBucket: 'migynaeblogs.firebasestorage.app',
    measurementId: 'G-CLV5BEQ1TS',
  );

class DefaultFirebaseOptions {

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1NNA4-6VMR8AYNVyYzOTmcNx3pYYoCKs',
    appId: '1:196764354205:android:c2b8f0f7ebd4b1437fb674',
    messagingSenderId: '196764354205',
    projectId: 'migynaeblogs',
    storageBucket: 'migynaeblogs.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAACx2VW_Db5tqZG-zbf5OsQ4cyKcZcPeU',
    appId: '1:196764354205:ios:813f0f4515ccb6f07fb674',
    messagingSenderId: '196764354205',
    projectId: 'migynaeblogs',
    storageBucket: 'migynaeblogs.firebasestorage.app',
    iosBundleId: 'com.example.migynaeblogs',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAACx2VW_Db5tqZG-zbf5OsQ4cyKcZcPeU',
    appId: '1:196764354205:ios:813f0f4515ccb6f07fb674',
    messagingSenderId: '196764354205',
    projectId: 'migynaeblogs',
    storageBucket: 'migynaeblogs.firebasestorage.app',
    iosBundleId: 'com.example.migynaeblogs',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyARAWqdo8qu5n3Ebx4G4IyVOguYKrZd_a0',
    appId: '1:196764354205:web:ca24470a4c4adda87fb674',
    messagingSenderId: '196764354205',
    projectId: 'migynaeblogs',
    authDomain: 'migynaeblogs.firebaseapp.com',
    storageBucket: 'migynaeblogs.firebasestorage.app',
    measurementId: 'G-1HV8WG7FR0',
  );

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}