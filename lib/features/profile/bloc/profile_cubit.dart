import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../core/logging/app_logger.dart';

class ProfileState extends Equatable {
  final String name;
  final int? age;
  final String? sex;
  final String? bloodGroup;
  final String? diagnosis;

  const ProfileState({
    this.name = '',
    this.age,
    this.sex,
    this.bloodGroup,
    this.diagnosis,
  });

  ProfileState copyWith({
    String? name,
    int? age,
    String? sex,
    String? bloodGroup,
    String? diagnosis,
  }) {
    return ProfileState(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      diagnosis: diagnosis ?? this.diagnosis,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'bloodGroup': bloodGroup,
      'diagnosis': diagnosis,
    };
  }

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      name: map['name'] ?? '',
      age: map['age']?.toInt(),
      sex: map['sex'],
      bloodGroup: map['bloodGroup'],
      diagnosis: map['diagnosis'],
    );
  }

  @override
  List<Object?> get props => [name, age, sex, bloodGroup, diagnosis];
}

class ProfileCubit extends HydratedCubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  void save({
    String? name,
    int? age,
    String? sex,
    String? bloodGroup,
    String? diagnosis,
  }) {
    AppLogger.log(
      'Profile saved',
      type: LogEventType.submit,
      extra: {
        'name': name,
        'age': age,
        'sex': sex,
        'bloodGroup': bloodGroup,
        'diagnosis': diagnosis,
      },
    );

    emit(state.copyWith(
      name: name,
      age: age,
      sex: sex,
      bloodGroup: bloodGroup,
      diagnosis: diagnosis,
    ));
  }

  void clearProfile() {
    AppLogger.log('Profile cleared', type: LogEventType.tap);
    emit(const ProfileState());
  }

  void clearAllData() {
    AppLogger.log('All app data cleared', type: LogEventType.tap);
    emit(const ProfileState());
  }

  @override
  ProfileState? fromJson(Map<String, dynamic> json) => ProfileState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(ProfileState state) => state.toMap();
}
