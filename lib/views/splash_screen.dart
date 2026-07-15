import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading and check auth state
    Future.delayed(const Duration(seconds: 2), () {
      // For now, just go to login
      // We will replace this with real auth check
      // context.goNamed('login');
      // Using context.go won't work in initState directly without PostFrameCallback if not careful, 
      // but GoRouter handles it well if we do it properly or just use Future.microtask.
      // We'll update this once AuthProvider is ready.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.recycling, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'EcoPoint',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Waste Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
