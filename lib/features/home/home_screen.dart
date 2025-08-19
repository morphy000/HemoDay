import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'bloc/home_nav_cubit.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/profile_widget.dart';
import 'widgets/documents_widget.dart';
import 'widgets/stats_widget.dart';
import '../../core/logging/app_logger.dart';
import '../records/bloc/records_cubit.dart';
import '../profile/bloc/profile_cubit.dart';
import '../documents/bloc/documents_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeNavCubit()),
        BlocProvider(create: (_) => RecordsCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => DocumentsCubit()),
      ],
      child: BlocBuilder<HomeNavCubit, int>(
        builder: (context, index) {
          final widgets = const [
            CalendarWidget(),
            ProfileWidget(),
            DocumentsWidget(),
            StatsWidget(),
          ];
          
          final titles = const [
            'Календарь',
            'Профиль',
            'Документы',
            'Статистика',
          ];
          
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
              child: Column(
                children: [
                  // Красивый заголовок
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.bloodtype,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                                                           Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             const Text(
                                               'HemoDay',
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 20,
                                                 fontWeight: FontWeight.bold,
                                               ),
                                             ),
                                             Container(
                                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                               decoration: BoxDecoration(
                                                 color: Colors.orange.withOpacity(0.8),
                                                 borderRadius: BorderRadius.circular(8),
                                               ),
                                               child: const Text(
                                                 'DEMO',
                                                 style: TextStyle(
                                                   color: Colors.white,
                                                   fontSize: 10,
                                                   fontWeight: FontWeight.bold,
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                  Text(
                                    titles[index],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Контент
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: widgets[index],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavIcon(index: 0, currentIndex: index, icon: Icons.calendar_month, label: 'Календарь'),
                      _NavIcon(index: 1, currentIndex: index, icon: Icons.person, label: 'Профиль'),
                      _NavIcon(index: 2, currentIndex: index, icon: Icons.folder, label: 'Документы'),
                      _NavIcon(index: 3, currentIndex: index, icon: Icons.equalizer, label: 'Статистика'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  
  const _NavIcon({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = index == currentIndex;
    return GestureDetector(
      onTap: () {
        AppLogger.log(
          'Bottom nav tap',
          type: LogEventType.tap,
          extra: {'index': index},
        );
        context.read<HomeNavCubit>().setIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? AppColors.primary : AppColors.textLight,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
