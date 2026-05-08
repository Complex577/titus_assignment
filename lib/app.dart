import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';

class VehiclePlateApp extends StatelessWidget {
  const VehiclePlateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (_, settings, __) => MaterialApp(
        title: 'Plate Scanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        home: const HomeScreen(),
      ),
    );
  }
}
