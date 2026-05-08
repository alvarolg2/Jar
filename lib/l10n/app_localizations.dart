import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'HOZON - JAR'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @pallets.
  ///
  /// In es, this message translates to:
  /// **'palés'**
  String get pallets;

  /// No description provided for @withOutName.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get withOutName;

  /// No description provided for @withOutProduct.
  ///
  /// In es, this message translates to:
  /// **'Sin producto'**
  String get withOutProduct;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get saving;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @gotIt.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get gotIt;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @product.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get product;

  /// No description provided for @batch.
  ///
  /// In es, this message translates to:
  /// **'Lote'**
  String get batch;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'* Requerido'**
  String get requiredField;

  /// No description provided for @tooltipDefectiveButton.
  ///
  /// In es, this message translates to:
  /// **'Mostrar palés defectuosos'**
  String get tooltipDefectiveButton;

  /// No description provided for @tooltipAddWarehouseButton.
  ///
  /// In es, this message translates to:
  /// **'Añadir almacén'**
  String get tooltipAddWarehouseButton;

  /// No description provided for @tooltipAddPallets.
  ///
  /// In es, this message translates to:
  /// **'Añadir palés'**
  String get tooltipAddPallets;

  /// No description provided for @tooltipSubstractPallets.
  ///
  /// In es, this message translates to:
  /// **'Sacar palés'**
  String get tooltipSubstractPallets;

  /// No description provided for @tooltipDefectivePallets.
  ///
  /// In es, this message translates to:
  /// **'Marcar palés como defectuosos'**
  String get tooltipDefectivePallets;

  /// No description provided for @tooltipDateCreationBatch.
  ///
  /// In es, this message translates to:
  /// **'Fecha de creación del lote'**
  String get tooltipDateCreationBatch;

  /// No description provided for @tooltipTruckLoads.
  ///
  /// In es, this message translates to:
  /// **'(Número de camiones completos, palés sueltos)'**
  String get tooltipTruckLoads;

  /// No description provided for @moreOptions.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get moreOptions;

  /// No description provided for @filterByProduct.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por producto'**
  String get filterByProduct;

  /// No description provided for @addWarehouse.
  ///
  /// In es, this message translates to:
  /// **'Añadir almacén'**
  String get addWarehouse;

  /// No description provided for @editWarehouse.
  ///
  /// In es, this message translates to:
  /// **'Editar almacén'**
  String get editWarehouse;

  /// No description provided for @nameWarehouse.
  ///
  /// In es, this message translates to:
  /// **'Nombre almacén'**
  String get nameWarehouse;

  /// No description provided for @myWarehouses.
  ///
  /// In es, this message translates to:
  /// **'Mis Almacenes'**
  String get myWarehouses;

  /// No description provided for @noWarehouses.
  ///
  /// In es, this message translates to:
  /// **'No hay almacenes'**
  String get noWarehouses;

  /// No description provided for @noWarehousesMessage.
  ///
  /// In es, this message translates to:
  /// **'Añade tu primer almacén usando el botón \'+\' de arriba.'**
  String get noWarehousesMessage;

  /// No description provided for @addReception.
  ///
  /// In es, this message translates to:
  /// **'Añadir recepción'**
  String get addReception;

  /// No description provided for @productName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto'**
  String get productName;

  /// No description provided for @productDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción del producto'**
  String get productDescription;

  /// No description provided for @scanDocument.
  ///
  /// In es, this message translates to:
  /// **'Escanear documento'**
  String get scanDocument;

  /// No description provided for @resetFilters.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar filtros'**
  String get resetFilters;

  /// No description provided for @defaultNumberPallets.
  ///
  /// In es, this message translates to:
  /// **'26'**
  String get defaultNumberPallets;

  /// El título para la sección de palés, en singular o plural
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{PALÉ} other{PALÉS}}'**
  String palletsTitle(int count);

  /// No description provided for @palletsDefective.
  ///
  /// In es, this message translates to:
  /// **'Palés defectuosos'**
  String get palletsDefective;

  /// No description provided for @defectiveLot.
  ///
  /// In es, this message translates to:
  /// **'LOTE DEFECTUOSO'**
  String get defectiveLot;

  /// No description provided for @numberOfPallets.
  ///
  /// In es, this message translates to:
  /// **'Número de palés'**
  String get numberOfPallets;

  /// No description provided for @confirmPallets.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Palés'**
  String get confirmPallets;

  /// No description provided for @inPallets.
  ///
  /// In es, this message translates to:
  /// **'Entrada de Palés'**
  String get inPallets;

  /// No description provided for @palletExit.
  ///
  /// In es, this message translates to:
  /// **'Salida de Palés'**
  String get palletExit;

  /// No description provided for @discountPallets.
  ///
  /// In es, this message translates to:
  /// **'Descontar palés'**
  String get discountPallets;

  /// Etiqueta para mostrar el nombre de un lote
  ///
  /// In es, this message translates to:
  /// **'Lote: {lotName}'**
  String lotLabel(String lotName);

  /// Mensaje cuando no hay palets para un producto filtrado
  ///
  /// In es, this message translates to:
  /// **'No hay palets para el producto \"{productName}\"'**
  String noPalletsForProduct(String productName);

  /// No description provided for @noPalletsToShow.
  ///
  /// In es, this message translates to:
  /// **'No hay palets que mostrar.'**
  String get noPalletsToShow;

  /// No description provided for @validateProduct.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingrese un producto'**
  String get validateProduct;

  /// No description provided for @validateBatch.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingrese un lote'**
  String get validateBatch;

  /// No description provided for @validatePallets.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingrese un número de palés'**
  String get validatePallets;

  /// No description provided for @validatePalletsNumber.
  ///
  /// In es, this message translates to:
  /// **'El número debe ser mayor que cero'**
  String get validatePalletsNumber;

  /// No description provided for @palletsGreaterThanZero.
  ///
  /// In es, this message translates to:
  /// **'El número de palets debe ser mayor que cero.'**
  String get palletsGreaterThanZero;

  /// No description provided for @productNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre del producto no puede estar vacío.'**
  String get productNameRequired;

  /// No description provided for @lotNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre del lote no puede estar vacío.'**
  String get lotNameRequired;

  /// No description provided for @snackbarDefective.
  ///
  /// In es, this message translates to:
  /// **'El número introducido es mayor que el número de palés disponibles.'**
  String get snackbarDefective;

  /// No description provided for @scanError.
  ///
  /// In es, this message translates to:
  /// **'Error de Escaneo'**
  String get scanError;

  /// No description provided for @scanErrorDescription.
  ///
  /// In es, this message translates to:
  /// **'No se pudo procesar el documento. Error: {error}'**
  String scanErrorDescription(String error);

  /// No description provided for @saveError.
  ///
  /// In es, this message translates to:
  /// **'Error al Guardar'**
  String get saveError;

  /// No description provided for @saveErrorDescription.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un problema al guardar los datos. Error: {error}'**
  String saveErrorDescription(String error);

  /// No description provided for @importDB.
  ///
  /// In es, this message translates to:
  /// **'Importar BD'**
  String get importDB;

  /// No description provided for @exportDB.
  ///
  /// In es, this message translates to:
  /// **'Exportar BD'**
  String get exportDB;

  /// No description provided for @generatePDFReport.
  ///
  /// In es, this message translates to:
  /// **'Generar Informe PDF'**
  String get generatePDFReport;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @versionUnknown.
  ///
  /// In es, this message translates to:
  /// **'Versión desconocida'**
  String get versionUnknown;

  /// No description provided for @dbBackupSubject.
  ///
  /// In es, this message translates to:
  /// **'Backup Base de Datos - JAR App - {date}'**
  String dbBackupSubject(String date);

  /// No description provided for @dbBackupBody.
  ///
  /// In es, this message translates to:
  /// **'Adjunto se encuentra la base de datos \"warehouse_transport.db\".'**
  String get dbBackupBody;

  /// No description provided for @exportError.
  ///
  /// In es, this message translates to:
  /// **'Error al Exportar'**
  String get exportError;

  /// No description provided for @exportErrorDescription.
  ///
  /// In es, this message translates to:
  /// **'No se pudo exportar la base de datos. Detalle: {error}'**
  String exportErrorDescription(String error);

  /// No description provided for @importConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Importación'**
  String get importConfirm;

  /// No description provided for @importConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres importar este archivo? Todos los datos actuales se borrarán y serán reemplazados por los del archivo seleccionado. Esta acción no se puede deshacer.'**
  String get importConfirmMessage;

  /// No description provided for @importConfirmYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, Importar'**
  String get importConfirmYes;

  /// No description provided for @importComplete.
  ///
  /// In es, this message translates to:
  /// **'Importación Completa'**
  String get importComplete;

  /// No description provided for @importCompleteMessage.
  ///
  /// In es, this message translates to:
  /// **'La base de datos se ha importado correctamente. La aplicación se reiniciará para cargar los nuevos datos.'**
  String get importCompleteMessage;

  /// No description provided for @importError.
  ///
  /// In es, this message translates to:
  /// **'Error al Importar'**
  String get importError;

  /// No description provided for @importErrorDescription.
  ///
  /// In es, this message translates to:
  /// **'No se pudo importar la base de datos. Asegúrate de que es un archivo válido. Detalle: {error}'**
  String importErrorDescription(String error);

  /// No description provided for @importNotSqlite.
  ///
  /// In es, this message translates to:
  /// **'El archivo seleccionado no es una base de datos SQLite válida.'**
  String get importNotSqlite;

  /// No description provided for @importCorrupted.
  ///
  /// In es, this message translates to:
  /// **'El archivo de base de datos está corrupto o dañado.'**
  String get importCorrupted;

  /// No description provided for @importSchemaMismatch.
  ///
  /// In es, this message translates to:
  /// **'El esquema de la base de datos es incompatible con esta versión de la app.'**
  String get importSchemaMismatch;

  /// No description provided for @importBackupRestored.
  ///
  /// In es, this message translates to:
  /// **'Error al importar. Tus datos anteriores han sido restaurados.'**
  String get importBackupRestored;

  /// No description provided for @importBackupFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al importar y no se pudo restaurar la copia de seguridad. Reinstala la app.'**
  String get importBackupFailed;

  /// No description provided for @reportSubject.
  ///
  /// In es, this message translates to:
  /// **'Reporte de Almacenes - {date}'**
  String reportSubject(String date);

  /// No description provided for @reportBody.
  ///
  /// In es, this message translates to:
  /// **'Adjunto se encuentra el reporte del estado actual de los almacenes.'**
  String get reportBody;

  /// No description provided for @reportEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Informe Vacío'**
  String get reportEmptyTitle;

  /// No description provided for @reportEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'No hay palets en los almacenes para generar un informe.'**
  String get reportEmptyMessage;

  /// No description provided for @pdfError.
  ///
  /// In es, this message translates to:
  /// **'Error al Generar PDF'**
  String get pdfError;

  /// No description provided for @pdfErrorDescription.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un problema al crear el informe. Detalle: {error}'**
  String pdfErrorDescription(String error);

  /// No description provided for @reportStandardInventory.
  ///
  /// In es, this message translates to:
  /// **'Inventario Estándar'**
  String get reportStandardInventory;

  /// No description provided for @reportTotalStandard.
  ///
  /// In es, this message translates to:
  /// **'Total Palets Estándar: {count}'**
  String reportTotalStandard(int count);

  /// No description provided for @reportNoStandardPallets.
  ///
  /// In es, this message translates to:
  /// **'No hay palets estándar en este almacén.'**
  String get reportNoStandardPallets;

  /// No description provided for @reportDefectiveInventory.
  ///
  /// In es, this message translates to:
  /// **'Inventario Defectuoso'**
  String get reportDefectiveInventory;

  /// No description provided for @reportTotalDefective.
  ///
  /// In es, this message translates to:
  /// **'Total Palets Defectuosos: {count}'**
  String reportTotalDefective(int count);

  /// No description provided for @reportNoDefectivePallets.
  ///
  /// In es, this message translates to:
  /// **'No hay palets defectuosos en este almacén.'**
  String get reportNoDefectivePallets;

  /// No description provided for @reportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reporte de Inventario'**
  String get reportTitle;

  /// No description provided for @reportGenerated.
  ///
  /// In es, this message translates to:
  /// **'Generado: {date}'**
  String reportGenerated(String date);

  /// No description provided for @reportPage.
  ///
  /// In es, this message translates to:
  /// **'Página {pageNumber} de {totalPages}'**
  String reportPage(int pageNumber, int totalPages);

  /// No description provided for @reportPalletCount.
  ///
  /// In es, this message translates to:
  /// **'Nº Palets'**
  String get reportPalletCount;

  /// No description provided for @dropdownProductText.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un producto'**
  String get dropdownProductText;

  /// No description provided for @analysisTitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis y Estadísticas'**
  String get analysisTitle;

  /// No description provided for @globalInventory.
  ///
  /// In es, this message translates to:
  /// **'Inventario Global'**
  String get globalInventory;

  /// No description provided for @inStock.
  ///
  /// In es, this message translates to:
  /// **'En Stock'**
  String get inStock;

  /// No description provided for @dispatched.
  ///
  /// In es, this message translates to:
  /// **'Expedido'**
  String get dispatched;

  /// No description provided for @dispatchedLast30Days.
  ///
  /// In es, this message translates to:
  /// **'{count} en 30 días'**
  String dispatchedLast30Days(int count);

  /// No description provided for @defective.
  ///
  /// In es, this message translates to:
  /// **'Defectuoso'**
  String get defective;

  /// No description provided for @currentStockDesc.
  ///
  /// In es, this message translates to:
  /// **'Stock actual'**
  String get currentStockDesc;

  /// No description provided for @currentDefectiveDesc.
  ///
  /// In es, this message translates to:
  /// **'Defectuosos actuales'**
  String get currentDefectiveDesc;

  /// No description provided for @warehouseDistribution.
  ///
  /// In es, this message translates to:
  /// **'Distribución por Almacén'**
  String get warehouseDistribution;

  /// No description provided for @unknown.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknown;

  /// No description provided for @palletsCountLabel.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} palé} other{{count} palés}}'**
  String palletsCountLabel(int count);

  /// No description provided for @movementTrends30Days.
  ///
  /// In es, this message translates to:
  /// **'Tendencias de Movimiento (Últimos 30 Días)'**
  String get movementTrends30Days;

  /// No description provided for @movementLegend.
  ///
  /// In es, this message translates to:
  /// **'Verde: Entrada, Naranja: Salida'**
  String get movementLegend;

  /// No description provided for @top5Products.
  ///
  /// In es, this message translates to:
  /// **'Top 5 Productos'**
  String get top5Products;

  /// No description provided for @noDescription.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción'**
  String get noDescription;

  /// No description provided for @noData.
  ///
  /// In es, this message translates to:
  /// **'Sin Datos'**
  String get noData;

  /// No description provided for @noDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get noDate;

  /// No description provided for @pdfTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get pdfTotal;

  /// No description provided for @defectRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa de Defectos'**
  String get defectRate;

  /// No description provided for @defectRateDesc.
  ///
  /// In es, this message translates to:
  /// **'% defectuosos últimos 30 días'**
  String get defectRateDesc;

  /// No description provided for @rotationRatio.
  ///
  /// In es, this message translates to:
  /// **'Ratio de Rotación'**
  String get rotationRatio;

  /// No description provided for @rotationRatioDesc.
  ///
  /// In es, this message translates to:
  /// **'Expedidos últimos 30 días / stock actual'**
  String get rotationRatioDesc;

  /// No description provided for @activeProducts.
  ///
  /// In es, this message translates to:
  /// **'Productos Activos'**
  String get activeProducts;

  /// No description provided for @keyPerformanceIndicators.
  ///
  /// In es, this message translates to:
  /// **'Indicadores Clave'**
  String get keyPerformanceIndicators;

  /// No description provided for @warehouseOccupancy.
  ///
  /// In es, this message translates to:
  /// **'Ocupación por Almacén'**
  String get warehouseOccupancy;

  /// No description provided for @recentActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad Reciente'**
  String get recentActivity;

  /// No description provided for @movementIn.
  ///
  /// In es, this message translates to:
  /// **'Entrada'**
  String get movementIn;

  /// No description provided for @movementOut.
  ///
  /// In es, this message translates to:
  /// **'Salida'**
  String get movementOut;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @type.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @warehouse.
  ///
  /// In es, this message translates to:
  /// **'Almacén'**
  String get warehouse;

  /// No description provided for @monthJan.
  ///
  /// In es, this message translates to:
  /// **'Ene'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In es, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In es, this message translates to:
  /// **'Abr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In es, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In es, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In es, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In es, this message translates to:
  /// **'Ago'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In es, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In es, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In es, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In es, this message translates to:
  /// **'Dic'**
  String get monthDec;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
