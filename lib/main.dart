// lib/main.dart

import 'package:flutter/material.dart';
import 'package:jar/app/app.bottomsheets.dart';
import 'package:jar/app/app.dialogs.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:provider/provider.dart'; 
import 'package:jar/services/locale_service.dart';
import 'package:jar/ui/common/app_theme.dart';
import 'package:stacked_services/stacked_services.dart';
import 'ui/common/database_helper.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  // Esta línea es crucial, carga el idioma guardado ANTES de iniciar la app
  await locator<LocaleService>().init(); 
  setupDialogUi();
  setupBottomSheetUi();
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  await databaseHelper.database;
  
  SystemChrome.setPreferredOrientations([
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
    final localeService = locator<LocaleService>();

    return ChangeNotifierProvider.value(
      value: localeService,
      child: Consumer<LocaleService>(
        builder: (context, language, child) {
          // 4. AHORA MATERIALAPP SE RECONSTRUIRÁ CON CADA CAMBIO
          return MaterialApp(
            // 5. USA EL LOCALE DEL SERVICIO
            locale: language.currentLocale, 
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.startupView,
            onGenerateRoute: StackedRouter().onGenerateRoute,
            navigatorKey: StackedService.navigatorKey,
            navigatorObservers: [
              StackedService.routeObserver,
            ],
            theme: getAppThemeData(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}