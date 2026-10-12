import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'utils/app_settings.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Launch the app even if the local API is unavailable.
  try {
    await DatabaseService.instance.init().timeout(
      const Duration(seconds: 10),
    );
  } catch (e) {
    debugPrint('Breeze API initialization failed: $e');
  }

  runApp(const BreezeApp());
}

class BreezeApp extends StatelessWidget {
  const BreezeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateBuilder(
      builder: (context, settings) {
        return MaterialApp(
          title: 'Breeze - Smart Weather Forecast',
          debugShowCheckedModeBanner: false,
          themeMode:
              settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: BreezeColors.primary,
            ),
            scaffoldBackgroundColor: BreezeColors.background,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: BreezeColors.primary,
              brightness: Brightness.dark,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}