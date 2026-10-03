import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/movie_controller.dart';
import 'core/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(MovieController(), permanent: true);
  runApp(const CineWaveApp());
}

class CineWaveApp extends StatelessWidget {
  const CineWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CineWave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(),
    );
  }
}
