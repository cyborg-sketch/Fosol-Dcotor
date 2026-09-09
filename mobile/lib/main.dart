import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/offline/offline_cache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineCache.init();
  runApp(const ProviderScope(child: FasolDoctorApp()));
}
