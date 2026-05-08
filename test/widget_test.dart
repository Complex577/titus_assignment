// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:titus_assignment/app.dart';
import 'package:titus_assignment/data/database/database_helper.dart';
import 'package:titus_assignment/data/repositories/scan_repository.dart';
import 'package:titus_assignment/presentation/viewmodels/camera_viewmodel.dart';
import 'package:titus_assignment/presentation/viewmodels/history_viewmodel.dart';
import 'package:titus_assignment/presentation/viewmodels/settings_viewmodel.dart';

void main() {
  testWidgets('app boots and shows splash screen shell', (WidgetTester tester) async {
    final db = DatabaseHelper();
    final repo = ScanRepository(db);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsViewModel()),
          ChangeNotifierProvider(create: (_) => HistoryViewModel(repo)),
          ChangeNotifierProvider(create: (_) => CameraViewModel(repo)),
        ],
        child: const VehiclePlateApp(),
      ),
    );

    expect(find.byType(VehiclePlateApp), findsOneWidget);
  });
}
