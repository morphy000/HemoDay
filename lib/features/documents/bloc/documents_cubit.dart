import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/logging/app_logger.dart';

class DocumentItem extends Equatable {
  final String id;
  final String path;
  final String name;
  final String extractedText;
  final String note;
  final DateTime uploadDate;

  const DocumentItem({
    required this.id,
    required this.path,
    required this.name,
    this.extractedText = '',
    this.note = '',
    required this.uploadDate,
  });

  DocumentItem copyWith({
    String? id,
    String? path,
    String? name,
    String? extractedText,
    String? note,
    DateTime? uploadDate,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      extractedText: extractedText ?? this.extractedText,
      note: note ?? this.note,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'extractedText': extractedText,
      'note': note,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }

  factory DocumentItem.fromMap(Map<String, dynamic> map) {
    return DocumentItem(
      id: map['id'] ?? '',
      path: map['path'] ?? '',
      name: map['name'] ?? '',
      extractedText: map['extractedText'] ?? '',
      note: map['note'] ?? '',
      uploadDate: DateTime.parse(map['uploadDate']),
    );
  }

  @override
  List<Object?> get props => [id, path, name, extractedText, note, uploadDate];
}

class DocumentsState extends Equatable {
  final List<DocumentItem> items;

  const DocumentsState({this.items = const []});

  DocumentsState copyWith({List<DocumentItem>? items}) {
    return DocumentsState(items: items ?? this.items);
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory DocumentsState.fromMap(Map<String, dynamic> map) {
    return DocumentsState(
      items: List<DocumentItem>.from(
        map['items']?.map((x) => DocumentItem.fromMap(x)) ?? [],
      ),
    );
  }

  @override
  List<Object?> get props => [items];
}

class DocumentsCubit extends HydratedCubit<DocumentsState> {
  DocumentsCubit() : super(const DocumentsState());

  void add(String path, String name, String extractedText, String note) {
    AppLogger.log(
      'Document added',
      type: LogEventType.submit,
      extra: {
        'name': name,
        'path': path,
        'extractedText': extractedText,
        'note': note,
      },
    );

    final item = DocumentItem(
      id: const Uuid().v4(),
      path: path,
      name: name,
      extractedText: extractedText,
      note: note,
      uploadDate: DateTime.now(),
    );

    final updatedItems = [...state.items, item];
    emit(DocumentsState(items: updatedItems));
  }

  void remove(String id) {
    AppLogger.log(
      'Document removed',
      type: LogEventType.tap,
      extra: {'id': id},
    );

    final updatedItems = state.items.where((item) => item.id != id).toList();
    emit(DocumentsState(items: updatedItems));
  }

  void clearAllDocuments() {
    AppLogger.log('All documents cleared', type: LogEventType.tap);
    emit(const DocumentsState());
  }

  @override
  DocumentsState? fromJson(Map<String, dynamic> json) => DocumentsState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(DocumentsState state) => state.toMap();
}
