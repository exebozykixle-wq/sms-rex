// ⚠️ IMPORTANT: Yeh file aapko khud generate karni hogi!
//
// Steps:
// 1. Terminal mein yeh install karo:
//    dart pub global activate flutterfire_cli
//
// 2. Firebase project se connect karo:
//    flutterfire configure
//
// 3. Yeh command automatically:
//    - Firebase project select karega
//    - Is file ko sahi values se replace karega
//    - google-services.json bhi copy karega
//
// Tab tak ke liye placeholder hai neeche:

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  // ⬇️ Yeh values flutterfire configure chalane ke baad auto-fill ho jayengi
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',               // <-- Firebase se milega
    appId: 'YOUR_APP_ID',                 // <-- Firebase se milega
    messagingSenderId: 'YOUR_SENDER_ID',  // <-- Firebase se milega
    projectId: 'YOUR_PROJECT_ID',         // <-- Firebase se milega
    storageBucket: 'YOUR_BUCKET',         // <-- Firebase se milega
  );
}
