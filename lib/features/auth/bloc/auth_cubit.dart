import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../core/logging/app_logger.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final String? email;

  const AuthState({required this.isAuthenticated, this.email});

  AuthState copyWith({bool? isAuthenticated, String? email}) => AuthState(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    email: email ?? this.email,
  );

  Map<String, dynamic> toMap() => {
    'isAuthenticated': isAuthenticated,
    'email': email,
  };
  factory AuthState.fromMap(Map<String, dynamic> map) => AuthState(
    isAuthenticated: map['isAuthenticated'] as bool? ?? false,
    email: map['email'] as String?,
  );

  @override
  List<Object?> get props => [isAuthenticated, email];
}

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(const AuthState(isAuthenticated: false));

  void login(String email, String password) async {
    AppLogger.log(
      'Auth attempt',
      type: LogEventType.submit,
      extra: {'email': email},
    );
    // Mock auth: accept any non-empty values
    if (email.isNotEmpty && password.isNotEmpty) {
      emit(AuthState(isAuthenticated: true, email: email));
    }
  }

  void skip() {
    AppLogger.log('Auth skipped', type: LogEventType.tap);
    emit(const AuthState(isAuthenticated: true, email: null));
  }

  void logout() {
    AppLogger.log('Logout', type: LogEventType.tap);
    emit(const AuthState(isAuthenticated: false));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(AuthState state) => state.toMap();
}
