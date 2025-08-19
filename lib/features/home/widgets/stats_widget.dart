import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/logging/app_logger.dart';
import '../../records/bloc/records_cubit.dart';

class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок раздела
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.warningGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Статистика здоровья',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Анализ показателей и динамики',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Основные показатели
              Expanded(
                child: BlocBuilder<RecordsCubit, RecordsState>(
                  builder: (context, state) {
                    final totalRecords = state.records.length;
                    final thisYear = DateTime.now().year;
                    final thisYearRecords = state.records
                        .where((r) => r.date.year == thisYear)
                        .length;
                    final thisMonth = DateTime.now().month;
                    final thisMonthRecords = state.records
                        .where((r) => r.date.month == thisMonth && r.date.year == thisYear)
                        .length;

                    final lastRecord = state.records.isNotEmpty
                        ? state.records.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
                        : null;

                    // Статистика по компонентам
                    final componentStats = <String, int>{};
                    for (final record in state.records) {
                      componentStats[record.component] = (componentStats[record.component] ?? 0) + 1;
                    }

                    // Данные для графика
                    final monthlyData = List.generate(12, (index) {
                      final month = index + 1;
                      return state.records
                          .where((r) => r.date.month == month && r.date.year == thisYear)
                          .length;
                    });

                    return ListView(
                      children: [
                        // Общая статистика
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Общая статистика',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        title: 'Всего переливаний',
                                        value: totalRecords.toString(),
                                        icon: Icons.bloodtype,
                                        color: AppColors.primary,
                                        animationDelay: 0,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _StatCard(
                                        title: 'За этот год',
                                        value: thisYearRecords.toString(),
                                        icon: Icons.calendar_today,
                                        color: AppColors.accent,
                                        animationDelay: 100,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        title: 'За этот месяц',
                                        value: thisMonthRecords.toString(),
                                        icon: Icons.trending_up,
                                        color: AppColors.secondary,
                                        animationDelay: 200,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _StatCard(
                                        title: 'Средний объем',
                                        value: totalRecords > 0
                                            ? '${(state.records.fold(0, (sum, r) => sum + r.volumeMl) / totalRecords).round()} мл'
                                            : '0 мл',
                                        icon: Icons.water_drop,
                                        color: AppColors.warning,
                                        animationDelay: 300,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // График по месяцам
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.show_chart,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Динамика по месяцам',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 200,
                                  child: AnimatedBuilder(
                                    animation: _chartAnimation,
                                    builder: (context, child) {
                                      return LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: true,
                                            horizontalInterval: 1,
                                            verticalInterval: 1,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: AppColors.border,
                                                strokeWidth: 1,
                                              );
                                            },
                                            getDrawingVerticalLine: (value) {
                                              return FlLine(
                                                color: AppColors.border,
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(showTitles: false),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(showTitles: false),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 30,
                                                interval: 1,
                                                getTitlesWidget: (value, meta) {
                                                  const months = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'];
                                                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                                                    return Text(
                                                      months[value.toInt()],
                                                      style: TextStyle(
                                                        color: AppColors.textSecondary,
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 1,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                      color: AppColors.textSecondary,
                                                      fontSize: 12,
                                                    ),
                                                  );
                                                },
                                                reservedSize: 40,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          minX: 0,
                                          maxX: 11,
                                          minY: 0,
                                          maxY: monthlyData.isEmpty ? 5 : (monthlyData.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: monthlyData.asMap().entries.map((entry) {
                                                return FlSpot(
                                                  entry.key.toDouble(),
                                                  (entry.value * _chartAnimation.value).toDouble(),
                                                );
                                              }).toList(),
                                              isCurved: true,
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.primaryLight,
                                                ],
                                              ),
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent, barData, index) {
                                                  return FlDotCirclePainter(
                                                    radius: 4,
                                                    color: AppColors.primary,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  );
                                                },
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primary.withOpacity(0.3),
                                                    AppColors.primary.withOpacity(0.1),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Статистика по компонентам
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pie_chart,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'По компонентам крови',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (componentStats.isNotEmpty) ...[
                                  ...componentStats.entries.map((entry) {
                                    final percentage = totalRecords > 0
                                        ? ((entry.value / totalRecords) * 100).round()
                                        : 0;
                                    return _ComponentStatCard(
                                      component: entry.key,
                                      count: entry.value,
                                      percentage: percentage,
                                      total: totalRecords,
                                    );
                                  }).toList(),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: AppColors.textLight,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Нет данных для анализа',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Последние процедуры
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Последние процедуры',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (lastRecord != null) ...[
                                  _LastRecordCard(record: lastRecord),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: AppColors.textLight,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Нет записей о переливаниях',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Быстрые действия
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flash_on,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Быстрые действия',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ActionButton(
                                        title: 'Добавить запись',
                                        icon: Icons.add,
                                        onTap: () {
                                          AppLogger.log('Quick add record', type: LogEventType.tap);
                                          // TODO: Переключиться на календарь
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _ActionButton(
                                        title: 'Экспорт данных',
                                        icon: Icons.download,
                                        onTap: () {
                                          AppLogger.log('Export data', type: LogEventType.tap);
                                          // TODO: Экспорт в PDF/Excel
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int animationDelay;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.animationDelay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + widget.animationDelay),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(widget.icon, color: widget.color, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ComponentStatCard extends StatelessWidget {
  final String component;
  final int count;
  final int percentage;
  final int total;

  const _ComponentStatCard({
    required this.component,
    required this.count,
    required this.percentage,
    required this.total,
  });

  Color _getComponentColor(String component) {
    switch (component) {
      case 'RBC':
        return Colors.red;
      case 'Plasma':
        return Colors.yellow.shade700;
      case 'Platelets':
        return Colors.orange;
      case 'Cryo':
        return Colors.purple;
      default:
        return AppColors.accent;
    }
  }

  String _getComponentName(String component) {
    switch (component) {
      case 'RBC':
        return 'Эритроциты';
      case 'Plasma':
        return 'Плазма';
      case 'Platelets':
        return 'Тромбоциты';
      case 'Cryo':
        return 'Криопреципитат';
      default:
        return component;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getComponentColor(component);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.bloodtype,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getComponentName(component),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$count из $total процедур',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastRecordCard extends StatelessWidget {
  final dynamic record; // TransfusionRecord

  const _LastRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bloodtype,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.component} - ${record.volumeMl} мл',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Дата: ${record.date.day}.${record.date.month}.${record.date.year}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.accent,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
