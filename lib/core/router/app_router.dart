import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';

class AppRoutePath {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutePath.splash:
        return _material(const SplashScreen());
      case AppRoutePath.auth:
        return _material(const AuthScreen());
      case AppRoutePath.onboarding:
        return _material(const OnboardingScreen());
      case AppRoutePath.home:
        return _material(const HomeScreen());
      default:
        return _material(const SplashScreen());
    }
  }

  static MaterialPageRoute _material(Widget child) =>
      MaterialPageRoute(builder: (_) => child);
}
