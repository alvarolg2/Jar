// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'HOZON - JAR';

  @override
  String get loading => 'Cargando...';

  @override
  String get pallets => 'palés';

  @override
  String get withOutName => 'Sin nombre';

  @override
  String get withOutProduct => 'Sin producto';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Borrar';

  @override
  String get add => 'Añadir';

  @override
  String get save => 'Guardar';

  @override
  String get saving => 'Guardando...';

  @override
  String get error => 'Error';

  @override
  String get gotIt => 'Entendido';

  @override
  String get all => 'Todos';

  @override
  String get product => 'Producto';

  @override
  String get batch => 'Lote';

  @override
  String get requiredField => '* Requerido';

  @override
  String get tooltipDefectiveButton => 'Mostrar palés defectuosos';

  @override
  String get tooltipAddWarehouseButton => 'Añadir almacén';

  @override
  String get tooltipAddPallets => 'Añadir palés';

  @override
  String get tooltipSubstractPallets => 'Sacar palés';

  @override
  String get tooltipDefectivePallets => 'Marcar palés como defectuosos';

  @override
  String get tooltipDateCreationBatch => 'Fecha de creación del lote';

  @override
  String get tooltipTruckLoads =>
      '(Número de camiones completos, palés sueltos)';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get filterByProduct => 'Filtrar por producto';

  @override
  String get addWarehouse => 'Añadir almacén';

  @override
  String get editWarehouse => 'Editar almacén';

  @override
  String get nameWarehouse => 'Nombre almacén';

  @override
  String get myWarehouses => 'Mis Almacenes';

  @override
  String get noWarehouses => 'No hay almacenes';

  @override
  String get noWarehousesMessage =>
      'Añade tu primer almacén usando el botón \'+\' de arriba.';

  @override
  String get addReception => 'Añadir recepción';

  @override
  String get productName => 'Nombre del producto';

  @override
  String get productDescription => 'Descripción del producto';

  @override
  String get scanDocument => 'Escanear documento';

  @override
  String get resetFilters => 'Reiniciar filtros';

  @override
  String get defaultNumberPallets => '26';

  @override
  String get palletsTitle => 'PALÉS';

  @override
  String get palletsDefective => 'Palés defectuosos';

  @override
  String get defectiveLot => 'LOTE DEFECTUOSO';

  @override
  String get numberOfPallets => 'Número de palés';

  @override
  String get confirmPallets => 'Confirmar Palés';

  @override
  String get inPallets => 'Entrada de Palés';

  @override
  String get palletExit => 'Salida de Palés';

  @override
  String get discountPallets => 'Descontar palés';

  @override
  String lotLabel(String lotName) {
    return 'Lote: $lotName';
  }

  @override
  String noPalletsForProduct(String productName) {
    return 'No hay palets para el producto \"$productName\"';
  }

  @override
  String get noPalletsToShow => 'No hay palets que mostrar.';

  @override
  String get validateProduct => 'Por favor ingrese un producto';

  @override
  String get validateBatch => 'Por favor ingrese un lote';

  @override
  String get validatePallets => 'Por favor ingrese un número de palés';

  @override
  String get validatePalletsNumber => 'El número debe ser mayor que cero';

  @override
  String get palletsGreaterThanZero =>
      'El número de palets debe ser mayor que cero.';

  @override
  String get productNameRequired =>
      'El nombre del producto no puede estar vacío.';

  @override
  String get lotNameRequired => 'El nombre del lote no puede estar vacío.';

  @override
  String get snackbarDefective =>
      'El número introducido es mayor que el número de palés disponibles.';

  @override
  String get scanError => 'Error de Escaneo';

  @override
  String scanErrorDescription(String error) {
    return 'No se pudo procesar el documento. Error: $error';
  }

  @override
  String get saveError => 'Error al Guardar';

  @override
  String saveErrorDescription(String error) {
    return 'Ocurrió un problema al guardar los datos. Error: $error';
  }

  @override
  String get importDB => 'Importar BD';

  @override
  String get exportDB => 'Exportar BD';

  @override
  String get generatePDFReport => 'Generar Informe PDF';

  @override
  String get version => 'Versión';

  @override
  String get versionUnknown => 'Versión desconocida';

  @override
  String dbBackupSubject(String date) {
    return 'Backup Base de Datos - JAR App - $date';
  }

  @override
  String get dbBackupBody =>
      'Adjunto se encuentra la base de datos \"warehouse_transport.db\".';

  @override
  String get exportError => 'Error al Exportar';

  @override
  String exportErrorDescription(String error) {
    return 'No se pudo exportar la base de datos. Detalle: $error';
  }

  @override
  String get importConfirm => 'Confirmar Importación';

  @override
  String get importConfirmMessage =>
      '¿Estás seguro de que quieres importar este archivo? Todos los datos actuales se borrarán y serán reemplazados por los del archivo seleccionado. Esta acción no se puede deshacer.';

  @override
  String get importConfirmYes => 'Sí, Importar';

  @override
  String get importComplete => 'Importación Completa';

  @override
  String get importCompleteMessage =>
      'La base de datos se ha importado correctamente. La aplicación se reiniciará para cargar los nuevos datos.';

  @override
  String get importError => 'Error al Importar';

  @override
  String importErrorDescription(String error) {
    return 'No se pudo importar la base de datos. Asegúrate de que es un archivo válido. Detalle: $error';
  }

  @override
  String reportSubject(String date) {
    return 'Reporte de Almacenes - $date';
  }

  @override
  String get reportBody =>
      'Adjunto se encuentra el reporte del estado actual de los almacenes.';

  @override
  String get reportEmptyTitle => 'Informe Vacío';

  @override
  String get reportEmptyMessage =>
      'No hay palets en los almacenes para generar un informe.';

  @override
  String get pdfError => 'Error al Generar PDF';

  @override
  String pdfErrorDescription(String error) {
    return 'Ocurrió un problema al crear el informe. Detalle: $error';
  }

  @override
  String get reportStandardInventory => 'Inventario Estándar';

  @override
  String reportTotalStandard(int count) {
    return 'Total Palets Estándar: $count';
  }

  @override
  String get reportNoStandardPallets =>
      'No hay palets estándar en este almacén.';

  @override
  String get reportDefectiveInventory => 'Inventario Defectuoso';

  @override
  String reportTotalDefective(int count) {
    return 'Total Palets Defectuosos: $count';
  }

  @override
  String get reportNoDefectivePallets =>
      'No hay palets defectuosos en este almacén.';

  @override
  String get reportTitle => 'Reporte de Inventario';

  @override
  String reportGenerated(String date) {
    return 'Generado: $date';
  }

  @override
  String reportPage(int pageNumber, int totalPages) {
    return 'Página $pageNumber de $totalPages';
  }

  @override
  String get reportPalletCount => 'Nº Palets';

  @override
  String get dropdownProductText => 'Selecciona un producto';
}
