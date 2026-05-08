import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/scan_repository.dart';
import 'presentation/viewmodels/camera_viewmodel.dart';
import 'presentation/viewmodels/history_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Wire up dependencies
  final db = DatabaseHelper();
  final repo = ScanRepository(db);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel(repo)),
        ChangeNotifierProvider(create: (_) => CameraViewModel(repo)),
      ],
      child: const VehiclePlateApp(),
    ),
  );

  // Apply orientation lock after the first frame path is unblocked.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
