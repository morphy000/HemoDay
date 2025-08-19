import 'dart:developer' as dev;

enum LogEventType { tap, submit, navigate, error, info }

class AppLogger {
  static void log(
    String message, {
    LogEventType type = LogEventType.info,
    Map<String, Object?> extra = const {},
  }) {
    final now = DateTime.now().toIso8601String();
    dev.log(
      '[HemoDay][$now][${type.name}] $message ${extra.isEmpty ? '' : extra.toString()}',
    );
  }
}
