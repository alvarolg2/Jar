// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'HOZON - JAR';

  @override
  String get loading => 'Loading...';

  @override
  String get pallets => 'pallets';

  @override
  String get withOutName => 'No Name';

  @override
  String get withOutProduct => 'No Product';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get error => 'Error';

  @override
  String get gotIt => 'Got it';

  @override
  String get all => 'All';

  @override
  String get product => 'Product';

  @override
  String get batch => 'Batch';

  @override
  String get requiredField => '* Required';

  @override
  String get tooltipDefectiveButton => 'Show defective pallets';

  @override
  String get tooltipAddWarehouseButton => 'Add warehouse';

  @override
  String get tooltipAddPallets => 'Add pallets';

  @override
  String get tooltipSubstractPallets => 'Remove pallets';

  @override
  String get tooltipDefectivePallets => 'Mark pallets as defective';

  @override
  String get tooltipDateCreationBatch => 'Lot creation date';

  @override
  String get tooltipTruckLoads => '(Number of full trucks, loose pallets)';

  @override
  String get moreOptions => 'More options';

  @override
  String get filterByProduct => 'Filter by product';

  @override
  String get addWarehouse => 'Add Warehouse';

  @override
  String get editWarehouse => 'Edit Warehouse';

  @override
  String get nameWarehouse => 'Warehouse Name';

  @override
  String get myWarehouses => 'My Warehouses';

  @override
  String get noWarehouses => 'No warehouses';

  @override
  String get noWarehousesMessage =>
      'Add your first warehouse using the \'+\' button above.';

  @override
  String get addReception => 'Add Reception';

  @override
  String get productName => 'Product Name';

  @override
  String get productDescription => 'Product Description';

  @override
  String get scanDocument => 'Scan Document';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get defaultNumberPallets => '26';

  @override
  String palletsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'PALLETS',
      one: 'PALLET',
    );
    return '$_temp0';
  }

  @override
  String get palletsDefective => 'Defective Pallets';

  @override
  String get defectiveLot => 'DEFECTIVE LOT';

  @override
  String get numberOfPallets => 'Number of pallets';

  @override
  String get confirmPallets => 'Confirm Pallets';

  @override
  String get inPallets => 'Pallet Entry';

  @override
  String get palletExit => 'Pallet Exit';

  @override
  String get discountPallets => 'Discount pallets';

  @override
  String lotLabel(String lotName) {
    return 'Batch: $lotName';
  }

  @override
  String noPalletsForProduct(String productName) {
    return 'No pallets found for product \"$productName\"';
  }

  @override
  String get noPalletsToShow => 'No pallets to show.';

  @override
  String get validateProduct => 'Please enter a product';

  @override
  String get validateBatch => 'Please enter a batch';

  @override
  String get validatePallets => 'Please enter a number of pallets';

  @override
  String get validatePalletsNumber => 'The number must be greater than zero';

  @override
  String get palletsGreaterThanZero =>
      'The number of pallets must be greater than zero.';

  @override
  String get productNameRequired => 'Product name cannot be empty.';

  @override
  String get lotNameRequired => 'Batch name cannot be empty.';

  @override
  String get snackbarDefective =>
      'The entered number is greater than the number of available pallets.';

  @override
  String get scanError => 'Scan Error';

  @override
  String scanErrorDescription(String error) {
    return 'Could not process the document. Error: $error';
  }

  @override
  String get saveError => 'Save Error';

  @override
  String saveErrorDescription(String error) {
    return 'An error occurred while saving the data. Error: $error';
  }

  @override
  String get importDB => 'Import DB';

  @override
  String get exportDB => 'Export DB';

  @override
  String get generatePDFReport => 'Generate PDF Report';

  @override
  String get version => 'Version';

  @override
  String get versionUnknown => 'Unknown version';

  @override
  String dbBackupSubject(String date) {
    return 'Database Backup - JAR App - $date';
  }

  @override
  String get dbBackupBody =>
      'Attached is the \"warehouse_transport.db\" database.';

  @override
  String get exportError => 'Export Error';

  @override
  String exportErrorDescription(String error) {
    return 'Could not export the database. Detail: $error';
  }

  @override
  String get importConfirm => 'Confirm Import';

  @override
  String get importConfirmMessage =>
      'Are you sure you want to import this file? All current data will be erased and replaced by the data in the selected file. This action cannot be undone.';

  @override
  String get importConfirmYes => 'Yes, Import';

  @override
  String get importComplete => 'Import Complete';

  @override
  String get importCompleteMessage =>
      'The database has been imported successfully. The application will restart to load the new data.';

  @override
  String get importError => 'Import Error';

  @override
  String importErrorDescription(String error) {
    return 'Could not import the database. Make sure it is a valid file. Detail: $error';
  }

  @override
  String get importNotSqlite =>
      'The selected file is not a valid SQLite database.';

  @override
  String get importCorrupted => 'The database file is corrupted or damaged.';

  @override
  String get importSchemaMismatch =>
      'The database schema is incompatible with this version of the app.';

  @override
  String get importBackupRestored =>
      'Import failed. Your previous data has been restored.';

  @override
  String get importBackupFailed =>
      'Import failed and backup could not be restored. Please reinstall the app.';

  @override
  String reportSubject(String date) {
    return 'Warehouse Report - $date';
  }

  @override
  String get reportBody =>
      'Attached is the report of the current status of the warehouses.';

  @override
  String get reportEmptyTitle => 'Empty Report';

  @override
  String get reportEmptyMessage =>
      'There are no pallets in the warehouses to generate a report.';

  @override
  String get pdfError => 'PDF Generation Error';

  @override
  String pdfErrorDescription(String error) {
    return 'An error occurred while creating the report. Detail: $error';
  }

  @override
  String get reportStandardInventory => 'Standard Inventory';

  @override
  String reportTotalStandard(int count) {
    return 'Total Standard Pallets: $count';
  }

  @override
  String get reportNoStandardPallets =>
      'No standard pallets in this warehouse.';

  @override
  String get reportDefectiveInventory => 'Defective Inventory';

  @override
  String reportTotalDefective(int count) {
    return 'Total Defective Pallets: $count';
  }

  @override
  String get reportNoDefectivePallets =>
      'No defective pallets in this warehouse.';

  @override
  String get reportTitle => 'Inventory Report';

  @override
  String reportGenerated(String date) {
    return 'Generated: $date';
  }

  @override
  String reportPage(int pageNumber, int totalPages) {
    return 'Page $pageNumber of $totalPages';
  }

  @override
  String get reportPalletCount => 'Pallet Count';

  @override
  String get dropdownProductText => 'Select a product';

  @override
  String get analysisTitle => 'Analysis & Statistics';

  @override
  String get globalInventory => 'Global Inventory';

  @override
  String get inStock => 'In Stock';

  @override
  String get dispatched => 'Dispatched';

  @override
  String dispatchedLast30Days(int count) {
    return '$count in 30 days';
  }

  @override
  String get defective => 'Defective';

  @override
  String get currentStockDesc => 'Current stock';

  @override
  String get currentDefectiveDesc => 'Current defective';

  @override
  String get warehouseDistribution => 'Warehouse Distribution';

  @override
  String get unknown => 'Unknown';

  @override
  String palletsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pallets',
      one: '$count pallet',
    );
    return '$_temp0';
  }

  @override
  String get movementTrends30Days => 'Movement Trends (Last 30 Days)';

  @override
  String get movementLegend => 'Green: In, Orange: Out';

  @override
  String get top5Products => 'Top 5 Products';

  @override
  String get noDescription => 'No description';

  @override
  String get noData => 'No Data';

  @override
  String get noDate => 'No date';

  @override
  String get pdfTotal => 'Total';

  @override
  String get defectRate => 'Defect Rate';

  @override
  String get defectRateDesc => '% defective last 30 days';

  @override
  String get rotationRatio => 'Rotation Ratio';

  @override
  String get rotationRatioDesc => 'Shipped last 30 days / current stock';

  @override
  String get activeProducts => 'Active Products';

  @override
  String get keyPerformanceIndicators => 'Key Performance Indicators';

  @override
  String get warehouseOccupancy => 'Warehouse Occupancy';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get movementIn => 'Entry';

  @override
  String get movementOut => 'Exit';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get warehouse => 'Warehouse';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';
}
