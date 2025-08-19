import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/logging/app_logger.dart';

class TransfusionRecord extends Equatable {
  final String id;
  final DateTime date;
  final int volumeMl;
  final String component;
  final String notes;

  const TransfusionRecord({
    required this.id,
    required this.date,
    required this.volumeMl,
    required this.component,
    this.notes = '',
  });

  TransfusionRecord copyWith({
    String? id,
    DateTime? date,
    int? volumeMl,
    String? component,
    String? notes,
  }) {
    return TransfusionRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      volumeMl: volumeMl ?? this.volumeMl,
      component: component ?? this.component,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'volumeMl': volumeMl,
      'component': component,
      'notes': notes,
    };
  }

  factory TransfusionRecord.fromMap(Map<String, dynamic> map) {
    return TransfusionRecord(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      volumeMl: map['volumeMl']?.toInt() ?? 0,
      component: map['component'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, date, volumeMl, component, notes];
}

class RecordsState extends Equatable {
  final List<TransfusionRecord> records;

  const RecordsState({this.records = const []});

  RecordsState copyWith({List<TransfusionRecord>? records}) {
    return RecordsState(records: records ?? this.records);
  }

  Map<String, dynamic> toMap() {
    return {
      'records': records.map((x) => x.toMap()).toList(),
    };
  }

  factory RecordsState.fromMap(Map<String, dynamic> map) {
    return RecordsState(
      records: List<TransfusionRecord>.from(
        map['records']?.map((x) => TransfusionRecord.fromMap(x)) ?? [],
      ),
    );
  }

  @override
  List<Object?> get props => [records];
}

class RecordsCubit extends HydratedCubit<RecordsState> {
  RecordsCubit() : super(const RecordsState());

  void addRecord({
    required DateTime date,
    required int volumeMl,
    required String component,
    String notes = '',
  }) {
    AppLogger.log(
      'Record added',
      type: LogEventType.submit,
      extra: {
        'date': date.toIso8601String(),
        'volumeMl': volumeMl,
        'component': component,
        'notes': notes,
      },
    );

    final record = TransfusionRecord(
      id: const Uuid().v4(),
      date: date,
      volumeMl: volumeMl,
      component: component,
      notes: notes,
    );

    final updatedRecords = [...state.records, record];
    emit(RecordsState(records: updatedRecords));
  }

  void clearAllRecords() {
    AppLogger.log('All records cleared', type: LogEventType.tap);
    emit(const RecordsState());
  }

  @override
  RecordsState? fromJson(Map<String, dynamic> json) => RecordsState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(RecordsState state) => state.toMap();
}
