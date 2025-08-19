import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore_for_file: unnecessary_import
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'app.dart';
import 'core/storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageInit.build();
  HydratedBloc.storage = storage;
  Bloc.observer = SimpleBlocObserver();
  runApp(const HemoDayApp());
}
