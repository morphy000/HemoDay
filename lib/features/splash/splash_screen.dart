import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/logging/app_logger.dart';
import '../auth/bloc/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.log('Splash shown');
    
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
    
    // Проверяем авторизацию через 2 секунды
    Timer(const Duration(milliseconds: 2000), () {
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() {
    final authState = context.read<AuthCubit>().state;
    
    if (authState.isAuthenticated) {
      // Пользователь уже авторизован - идем на главный экран
      AppLogger.log('User already authenticated, going to home');
      Navigator.of(context).pushReplacementNamed(AppRoutePath.home);
    } else {
      // Пользователь не авторизован - идем на экран авторизации
      AppLogger.log('User not authenticated, going to auth');
      Navigator.of(context).pushReplacementNamed(AppRoutePath.auth);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.bloodtype,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                                           Column(
                           children: [
                             const Text(
                               'HemoDay',
                               style: TextStyle(
                                 fontSize: 32,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white,
                                 letterSpacing: 2,
                               ),
                             ),
                             const SizedBox(height: 8),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                               decoration: BoxDecoration(
                                 color: Colors.orange.withOpacity(0.8),
                                 borderRadius: BorderRadius.circular(12),
                                 border: Border.all(color: Colors.white.withOpacity(0.3)),
                               ),
                               child: const Text(
                                 'DEMO ВЕРСИЯ',
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontSize: 12,
                                   fontWeight: FontWeight.bold,
                                   letterSpacing: 1,
                                 ),
                               ),
                             ),
                           ],
                         ),
                  const SizedBox(height: 8),
                  Text(
                    'Отслеживание здоровья',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
