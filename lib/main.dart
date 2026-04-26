import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sms_rex/firebase_options.dart';
import 'package:sms_rex/screens/splash_screen.dart';
import 'package:sms_rex/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmsRexApp());
}

class SmsRexApp extends StatelessWidget {
  const SmsRexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS REX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
