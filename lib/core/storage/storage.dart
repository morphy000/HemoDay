import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

class StorageInit {
  static Future<HydratedStorage> build() async {
    if (kIsWeb) {
      return HydratedStorage.build(storageDirectory: HydratedStorageDirectory.web);
    }
    final supportDir = await getApplicationSupportDirectory();
    return HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(supportDir.path),
    );
  }
}
