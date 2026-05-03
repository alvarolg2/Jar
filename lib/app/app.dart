import 'package:jar/services/locale_service.dart';
import 'package:jar/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:jar/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:jar/ui/views/create_received/create_received_view.dart';
import 'package:jar/ui/views/home/home_view.dart';
import 'package:jar/ui/views/startup/startup_view.dart';
import 'package:jar/ui/views/analysis/analysis_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:jar/services/warehouse_data_service.dart';
import 'package:jar/services/update_service.dart';
import 'package:jar/services/filter_service.dart';
import 'package:jar/services/label_parser_service.dart';
import 'package:jar/services/ai_label_parser_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: AnalysisView),
    MaterialRoute(page: CreateReceivedView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: WarehouseDataService),
    LazySingleton(classType: UpdateService),
    LazySingleton(classType: FilterService),
    LazySingleton(classType: LocaleService),
    LazySingleton(classType: LabelParserService),
    LazySingleton(classType: AiLabelParserService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
