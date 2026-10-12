import 'package:flutter/material.dart';

import '../utils/app_settings.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isStarting = false;
  String? _error;

  Future<void> _startApp() async {
    setState(() {
      _isStarting = true;
      _error = null;
    });

    try {
      await AppSettings.instance.initialize();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            AppSettings.instance.errorMessage ?? 'Unable to initialize Breeze.';
        _isStarting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF55A7FF),
              Color(0xFF2878E5),
              Color(0xFF1659B7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_rounded,
                color: Colors.white,
                size: 90,
              ),
              const SizedBox(height: 12),
              const Text(
                'Breeze',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Smart Weather Forecast',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 28),
              if (_isStarting) ...[
                const CircularProgressIndicator(color: Colors.white),
              ] else if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _startApp,
                  child: const Text('Retry'),
                ),
              ] else ...[
                FilledButton(
                  onPressed: _startApp,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: BreezeColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}