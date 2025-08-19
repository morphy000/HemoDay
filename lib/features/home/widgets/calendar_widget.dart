import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/logging/app_logger.dart';
import '../../records/bloc/records_cubit.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> with TickerProviderStateMixin {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String component = 'RBC'; // Default component
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _calendarController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _calendarAnimation;

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
    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _calendarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _calendarController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _calendarController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Заголовок раздела
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Календарь переливаний',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Отслеживайте процедуры по дням',
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

            const SizedBox(height: 20),

            // Календарь
            AnimatedBuilder(
              animation: _calendarAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _calendarAnimation.value,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<RecordsCubit, RecordsState>(
                        builder: (context, state) {
                          final records = state.records;
                          return TableCalendar<TransfusionRecord>(
                            firstDay: DateTime.utc(2010, 1, 1),
                            lastDay: DateTime.utc(2040, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                            onDaySelected: (selected, focused) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                              });
                              AppLogger.log(
                                'Day selected',
                                type: LogEventType.tap,
                                extra: {'day': selected.toIso8601String()},
                              );
                            },
                            onFormatChanged: (f) => setState(() => _format = f),
                            calendarFormat: _format,
                            eventLoader: (day) {
                              return records
                                  .where((record) => isSameDay(record.date, day))
                                  .toList();
                            },
                            calendarBuilders: CalendarBuilders<TransfusionRecord>(
                              markerBuilder: (context, date, events) {
                                if (events.isEmpty) return null;
                                final components = events
                                    .map((e) => e.component)
                                    .toSet()
                                    .take(3)
                                    .toList();
                                return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: components
                                        .map((c) => Container(
                                              width: 6,
                                              height: 6,
                                              margin: const EdgeInsets.symmetric(horizontal: 1),
                                              decoration: BoxDecoration(
                                                color: _getComponentColor(c),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 1),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                );
                              },
                              selectedBuilder: (context, date, _) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              todayBuilder: (context, date, _) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                              formatButtonShowsNext: false,
                            ),
                            calendarStyle: const CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              defaultDecoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Легенда календаря
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Легенда календаря',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _LegendItem(
                          color: Colors.red,
                          label: 'RBC (Эритроциты)',
                        ),
                        _LegendItem(
                          color: Colors.yellow.shade700,
                          label: 'Plasma (Плазма)',
                        ),
                        _LegendItem(
                          color: Colors.orange,
                          label: 'Platelets (Тромбоциты)',
                        ),
                        _LegendItem(
                          color: Colors.purple,
                          label: 'Cryo (Криопреципитат)',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Быстрые действия
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Быстрые действия',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            title: 'RBC',
                            subtitle: 'Эритроциты',
                            icon: Icons.circle,
                            color: Colors.red,
                            onTap: () => _quickAddRecord(context, 'RBC', 250),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            title: 'Plasma',
                            subtitle: 'Плазма',
                            icon: Icons.circle,
                            color: Colors.yellow.shade700,
                            onTap: () => _quickAddRecord(context, 'Plasma', 200),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка добавления
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    AppLogger.log(
                      'Add transfusion tap',
                      type: LogEventType.tap,
                      extra: {'day': _selectedDay?.toIso8601String()},
                    );
                    _showAddRecordDialog(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Добавить переливание',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Список записей за выбранный день
            BlocBuilder<RecordsCubit, RecordsState>(
              builder: (context, state) {
                final dayRecords = state.records.where((r) =>
                  isSameDay(r.date, _selectedDay ?? _focusedDay)
                ).toList();

                if (dayRecords.isEmpty) {
                  return Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Нет записей на этот день',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Нажмите кнопку выше, чтобы добавить',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Записи за ${_selectedDay?.day ?? _focusedDay.day}.${_selectedDay?.month ?? _focusedDay.month}.${_selectedDay?.year ?? _focusedDay.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dayRecords.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getComponentColor(record.component).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.bloodtype,
                                color: _getComponentColor(record.component),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '${record.component} - ${record.volumeMl} мл',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Дата: ${record.date.day}.${record.date.month}.${record.date.year}',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (record.notes.isNotEmpty)
                                  Icon(
                                    Icons.note,
                                    color: AppColors.secondary,
                                    size: 16,
                                  ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.accent,
                                ),
                              ],
                            ),
                            children: [
                              if (record.notes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.secondary.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.note_outlined,
                                          color: AppColors.secondary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            record.notes,
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),

            // Дополнительное пространство внизу для избежания переполнения
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

  String _getRecordCountText(int count) {
    if (count == 1) return 'запись';
    if (count >= 2 && count <= 4) return 'записи';
    return 'записей';
  }

  void _showAddRecordDialog(BuildContext context) {
    final TextEditingController volume = TextEditingController();
    final TextEditingController notes = TextEditingController();
    String component = 'RBC';
    final _formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок с иконкой
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_circle,
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
                          'Новая запись',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Добавьте информацию о переливании',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Форма
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Поле объема
                    TextFormField(
                      controller: volume,
                      decoration: InputDecoration(
                        labelText: 'Объем (мл)',
                        hintText: 'Введите объем',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.water_drop,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите объем';
                        }
                        final vol = int.tryParse(value);
                        if (vol == null || vol <= 0) {
                          return 'Введите корректный объем';
                        }
                        if (vol > 5000) {
                          return 'Объем не может превышать 5000 мл';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Выбор компонента
                    DropdownButtonFormField<String>(
                      value: component,
                      decoration: InputDecoration(
                        labelText: 'Компонент крови',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.bloodtype,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'RBC',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.red, size: 16),
                              const SizedBox(width: 12),
                              const Text('Эритроциты (RBC)'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Plasma',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.yellow, size: 16),
                              const SizedBox(width: 12),
                              const Text('Плазма'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Platelets',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.orange, size: 16),
                              const SizedBox(width: 12),
                              const Text('Тромбоциты'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Cryo',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.purple, size: 16),
                              const SizedBox(width: 12),
                              const Text('Криопреципитат'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) => component = value ?? component,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите компонент';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Поле для заметок
                    TextFormField(
                      controller: notes,
                      decoration: InputDecoration(
                        labelText: 'Заметки (необязательно)',
                        hintText: 'Дополнительная информация',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.note,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      maxLines: 3,
                      maxLength: 200,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              AppLogger.log(
                                'Record saved',
                                type: LogEventType.submit,
                                extra: {
                                  'volume': volume.text,
                                  'component': component,
                                  'notes': notes.text,
                                },
                              );
                              final int vol = int.tryParse(volume.text) ?? 0;
                              if (vol > 0) {
                                context.read<RecordsCubit>().addRecord(
                                  date: _selectedDay ?? _focusedDay,
                                  volumeMl: vol,
                                  component: component,
                                  notes: notes.text,
                                );
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Запись успешно сохранена',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.accent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Сохранить',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _quickAddRecord(BuildContext context, String component, int volume) {
    final TextEditingController notes = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок с иконкой
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_circle,
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
                          'Новая запись',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Добавьте информацию о переливании',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Форма
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Поле объема
                    TextFormField(
                      controller: TextEditingController(text: volume.toString()),
                      decoration: InputDecoration(
                        labelText: 'Объем (мл)',
                        hintText: 'Введите объем',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.water_drop,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите объем';
                        }
                        final vol = int.tryParse(value);
                        if (vol == null || vol <= 0) {
                          return 'Введите корректный объем';
                        }
                        if (vol > 5000) {
                          return 'Объем не может превышать 5000 мл';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Выбор компонента
                    DropdownButtonFormField<String>(
                      value: component,
                      decoration: InputDecoration(
                        labelText: 'Компонент крови',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.bloodtype,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'RBC',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.red, size: 16),
                              const SizedBox(width: 12),
                              const Text('Эритроциты (RBC)'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Plasma',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.yellow, size: 16),
                              const SizedBox(width: 12),
                              const Text('Плазма'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Platelets',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.orange, size: 16),
                              const SizedBox(width: 12),
                              const Text('Тромбоциты'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Cryo',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.purple, size: 16),
                              const SizedBox(width: 12),
                              const Text('Криопреципитат'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) => component = value ?? component,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите компонент';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Поле для заметок
                    TextFormField(
                      controller: notes,
                      decoration: InputDecoration(
                        labelText: 'Заметки (необязательно)',
                        hintText: 'Дополнительная информация',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.note,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      maxLines: 3,
                      maxLength: 200,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              AppLogger.log(
                                'Record saved',
                                type: LogEventType.submit,
                                extra: {
                                  'volume': volume.toString(),
                                  'component': component,
                                  'notes': notes.text,
                                },
                              );
                              final int vol = int.tryParse(volume.toString()) ?? 0;
                              if (vol > 0) {
                                context.read<RecordsCubit>().addRecord(
                                  date: DateTime.now(), // Quick add uses current day
                                  volumeMl: vol,
                                  component: component,
                                  notes: notes.text,
                                );
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Запись успешно сохранена',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.accent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Сохранить',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
