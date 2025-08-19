import 'package:flutter/material.dart';
import 'app_logger.dart';

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.log(
      'Route push',
      type: LogEventType.navigate,
      extra: {
        'route': route.settings.name,
        'from': previousRoute?.settings.name,
      },
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.log(
      'Route pop',
      type: LogEventType.navigate,
      extra: {'route': route.settings.name, 'to': previousRoute?.settings.name},
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.log(
      'Route replace',
      type: LogEventType.navigate,
      extra: {'new': newRoute?.settings.name, 'old': oldRoute?.settings.name},
    );
  }
}
