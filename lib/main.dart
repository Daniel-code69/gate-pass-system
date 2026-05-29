import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';

bool firebaseAvailable = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
  } catch (_) {
    firebaseAvailable = false;
  }

  await Hive.initFlutter();
  final auth = AuthService();
  await auth.seedDemoUsers();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const GatePassApp());
}

class GatePassApp extends StatelessWidget {
  const GatePassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gate Pass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
