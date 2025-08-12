import 'package:flutter/material.dart';
import 'package:jar/app/app.bottomsheets.dart';
import 'package:jar/app/app.dialogs.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'ui/common/database_helper.dart';
import 'package:flutter/services.dart'; // Importa el paquete services

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  await databaseHelper.database;
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de los widgets
  SystemChrome.setPreferredOrientations([
    // Establece las orientaciones permitidas
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
