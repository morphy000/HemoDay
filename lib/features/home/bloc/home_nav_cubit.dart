import 'package:hydrated_bloc/hydrated_bloc.dart';

class HomeNavCubit extends HydratedCubit<int> {
  HomeNavCubit() : super(0);

  void setIndex(int index) => emit(index);

  @override
  int? fromJson(Map<String, dynamic> json) => json['index'] as int?;

  @override
  Map<String, dynamic>? toJson(int state) => {'index': state};
}
