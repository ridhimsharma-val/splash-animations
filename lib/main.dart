import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/gallery_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const OnboardingSplashLabApp());
}

class OnboardingSplashLabApp extends StatelessWidget {
  const OnboardingSplashLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explore Designs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const GalleryScreen(),
    );
  }
}
