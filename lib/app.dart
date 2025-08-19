import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore_for_file: unnecessary_import
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'features/records/bloc/records_cubit.dart';
import 'features/profile/bloc/profile_cubit.dart';
import 'features/documents/bloc/documents_cubit.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/route_observer.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.log('Bloc event: ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.log('Bloc change: ${bloc.runtimeType} -> $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.log(
      'Bloc error: ${bloc.runtimeType} -> $error',
      type: LogEventType.error,
    );
    super.onError(bloc, error, stackTrace);
  }
}

class HemoDayApp extends StatelessWidget {
  const HemoDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => RecordsCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => DocumentsCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HemoDay',
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        initialRoute: AppRoutePath.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        navigatorObservers: [AppRouteObserver()],
      ),
    );
  }
}
