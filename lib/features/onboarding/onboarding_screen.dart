import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/logging/app_logger.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  final List<_Slide> _slides = const [
    _Slide(
      title: 'Отслеживайте переливания',
      text: 'Удобный календарь и история процедур для контроля вашего здоровья.',
      icon: Icons.calendar_month,
      color: AppColors.primary,
    ),
    _Slide(
      title: 'Храните документы',
      text: 'Загружайте выписки и анализы офлайн для быстрого доступа.',
      icon: Icons.folder_open,
      color: AppColors.secondary,
    ),
    _Slide(
      title: 'Статистика и здоровье',
      text: 'Наблюдайте динамику показателей и ведите дневник здоровья.',
      icon: Icons.trending_up,
      color: AppColors.accent,
    ),
    _Slide(
      title: 'Готово к синхронизации',
      text: 'Безопасная архитектура для будущего облачного хранения данных.',
      icon: Icons.cloud_sync,
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Индикатор прогресса
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) => _Dot(active: i == _index)),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Слайды
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    _fadeController.reset();
                    _fadeController.forward();
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, i) => _OnboardingSlide(slide: _slides[i]),
                ),
              ),
              
              // Кнопки
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          AppLogger.log('Onboarding skipped', type: LogEventType.tap);
                          Navigator.of(context).pushReplacementNamed(AppRoutePath.home);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Пропустить'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_index < _slides.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          } else {
                            Navigator.of(context).pushReplacementNamed(AppRoutePath.home);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_index < _slides.length - 1 ? 'Далее' : 'Начать'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _Slide slide;
  const _OnboardingSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка с градиентом
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  slide.color,
                  slide.color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: slide.color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Заголовок
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Описание
          Text(
            slide.text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 8,
      height: active ? 12 : 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Slide {
  final String title;
  final String text;
  final IconData icon;
  final Color color;
  
  const _Slide({
    required this.title,
    required this.text,
    required this.icon,
    required this.color,
  });
}
