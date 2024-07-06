// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:jar/ui/bottom_sheets/defective/defective_sheet.dart';
import 'package:jar/ui/bottom_sheets/pallet/pallet_sheet.dart';
import 'package:jar/ui/bottom_sheets/pallet_in/pallet_in_sheet.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/notice/notice_sheet.dart';

enum BottomSheetType { notice, pallet, pallet_in, defective}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.notice: (context, request, completer) =>
        NoticeSheet(request: request, completer: completer),
    BottomSheetType.pallet: (context, request, completer) =>
        PalletsSheet(request: request, completer: completer),
    BottomSheetType.pallet_in: (context, request, completer) =>
        PalletsInSheet(request: request, completer: completer),
    BottomSheetType.defective: (context, request, completer) =>
        DefectiveSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}
