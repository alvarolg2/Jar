// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'HOZON - JAR';

  @override
  String get loading => 'Chargement...';

  @override
  String get pallets => 'palettes';

  @override
  String get withOutName => 'Sans nom';

  @override
  String get withOutProduct => 'Sans produit';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get add => 'Ajouter';

  @override
  String get save => 'Enregistrer';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get error => 'Erreur';

  @override
  String get gotIt => 'Compris';

  @override
  String get all => 'Tous';

  @override
  String get product => 'Produit';

  @override
  String get batch => 'Lot';

  @override
  String get requiredField => '* Requis';

  @override
  String get tooltipDefectiveButton => 'Afficher les palettes défectueuses';

  @override
  String get tooltipAddWarehouseButton => 'Ajouter un entrepôt';

  @override
  String get tooltipAddPallets => 'Ajouter des palettes';

  @override
  String get tooltipSubstractPallets => 'Sortir des palettes';

  @override
  String get tooltipDefectivePallets => 'Marquer comme défectueux';

  @override
  String get tooltipDateCreationBatch => 'Date de création du lot';

  @override
  String get tooltipTruckLoads =>
      '(Nombre de camions complets, palettes restantes)';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get filterByProduct => 'Filtrer par produit';

  @override
  String get addWarehouse => 'Ajouter un entrepôt';

  @override
  String get editWarehouse => 'Modifier l\'entrepôt';

  @override
  String get nameWarehouse => 'Nom de l\'entrepôt';

  @override
  String get myWarehouses => 'Mes Entrepôts';

  @override
  String get noWarehouses => 'Aucun entrepôt';

  @override
  String get noWarehousesMessage =>
      'Ajoutez votre premier entrepôt en utilisant le bouton \'+\' ci-dessus.';

  @override
  String get addReception => 'Ajouter une réception';

  @override
  String get productName => 'Nom du produit';

  @override
  String get productDescription => 'Description du produit';

  @override
  String get scanDocument => 'Scanner un document';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get defaultNumberPallets => '26';

  @override
  String palletsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'PALETTES',
      one: 'PALETTE',
    );
    return '$_temp0';
  }

  @override
  String get palletsDefective => 'Palettes défectueuses';

  @override
  String get defectiveLot => 'LOT DÉFECTUEUX';

  @override
  String get numberOfPallets => 'Nombre de palettes';

  @override
  String get confirmPallets => 'Confirmer les palettes';

  @override
  String get inPallets => 'Entrée de palettes';

  @override
  String get palletExit => 'Sortie de palettes';

  @override
  String get discountPallets => 'Décompter les palettes';

  @override
  String lotLabel(String lotName) {
    return 'Lot : $lotName';
  }

  @override
  String noPalletsForProduct(String productName) {
    return 'Aucune palette trouvée pour le produit \"$productName\"';
  }

  @override
  String get noPalletsToShow => 'Aucune palette à afficher.';

  @override
  String get validateProduct => 'Veuillez saisir un produit';

  @override
  String get validateBatch => 'Veuillez saisir un lot';

  @override
  String get validatePallets => 'Veuillez saisir un nombre de palettes';

  @override
  String get validatePalletsNumber => 'Le nombre doit être supérieur à zéro';

  @override
  String get palletsGreaterThanZero =>
      'Le nombre de palettes doit être supérieur à zéro.';

  @override
  String get productNameRequired => 'Le nom du produit ne peut pas être vide.';

  @override
  String get lotNameRequired => 'Le nom du lot ne peut pas être vide.';

  @override
  String get snackbarDefective =>
      'Le nombre saisi est supérieur au nombre de palettes disponibles.';

  @override
  String get scanError => 'Erreur de numérisation';

  @override
  String scanErrorDescription(String error) {
    return 'Impossible de traiter le document. Erreur : $error';
  }

  @override
  String get saveError => 'Erreur d\'enregistrement';

  @override
  String saveErrorDescription(String error) {
    return 'Une erreur est survenue lors de l\'enregistrement des données. Erreur : $error';
  }

  @override
  String get importDB => 'Importer BDD';

  @override
  String get exportDB => 'Exporter BDD';

  @override
  String get generatePDFReport => 'Générer Rapport PDF';

  @override
  String get version => 'Version';

  @override
  String get versionUnknown => 'Version inconnue';

  @override
  String dbBackupSubject(String date) {
    return 'Sauvegarde BDD - JAR App - $date';
  }

  @override
  String get dbBackupBody =>
      'Ci-joint la base de données \"warehouse_transport.db\".';

  @override
  String get exportError => 'Erreur d\'exportation';

  @override
  String exportErrorDescription(String error) {
    return 'Impossible d\'exporter la base de données. Détail : $error';
  }

  @override
  String get importConfirm => 'Confirmer l\'importation';

  @override
  String get importConfirmMessage =>
      'Êtes-vous sûr de vouloir importer ce fichier ? Toutes les données actuelles seront effacées et remplacées par les données du fichier sélectionné. Cette action est irréversible.';

  @override
  String get importConfirmYes => 'Oui, importer';

  @override
  String get importComplete => 'Importation terminée';

  @override
  String get importCompleteMessage =>
      'La base de données a été importée avec succès. L\'application va redémarrer pour charger les nouvelles données.';

  @override
  String get importError => 'Erreur d\'importation';

  @override
  String importErrorDescription(String error) {
    return 'Impossible d\'importer la base de données. Assurez-vous qu\'il s\'agit d\'un fichier valide. Détail : $error';
  }

  @override
  String get importNotSqlite =>
      'Le fichier sélectionné n\'est pas une base de données SQLite valide.';

  @override
  String get importCorrupted =>
      'Le fichier de base de données est corrompu ou endommagé.';

  @override
  String get importSchemaMismatch =>
      'Le schéma de la base de données est incompatible avec cette version de l\'application.';

  @override
  String get importBackupRestored =>
      'Échec de l\'importation. Vos données précédentes ont été restaurées.';

  @override
  String get importBackupFailed =>
      'Échec de l\'importation et la sauvegarde n\'a pas pu être restaurée. Veuillez réinstaller l\'application.';

  @override
  String reportSubject(String date) {
    return 'Rapport d\'entrepôt - $date';
  }

  @override
  String get reportBody =>
      'Ci-joint le rapport sur l\'état actuel des entrepôts.';

  @override
  String get reportEmptyTitle => 'Rapport vide';

  @override
  String get reportEmptyMessage =>
      'Il n\'y a aucune palette dans les entrepôts pour générer un rapport.';

  @override
  String get pdfError => 'Erreur PDF';

  @override
  String pdfErrorDescription(String error) {
    return 'Une erreur est survenue lors de la création du rapport. Détail : $error';
  }

  @override
  String get reportStandardInventory => 'Inventaire Standard';

  @override
  String reportTotalStandard(int count) {
    return 'Total Palettes Standard : $count';
  }

  @override
  String get reportNoStandardPallets =>
      'Aucune palette standard dans cet entrepôt.';

  @override
  String get reportDefectiveInventory => 'Inventaire Défectueux';

  @override
  String reportTotalDefective(int count) {
    return 'Total Palettes Défectueuses : $count';
  }

  @override
  String get reportNoDefectivePallets =>
      'Aucune palette défectueuse dans cet entrepôt.';

  @override
  String get reportTitle => 'Rapport d\'inventaire';

  @override
  String reportGenerated(String date) {
    return 'Généré le : $date';
  }

  @override
  String reportPage(int pageNumber, int totalPages) {
    return 'Page $pageNumber sur $totalPages';
  }

  @override
  String get reportPalletCount => 'Nb Palettes';

  @override
  String get dropdownProductText => 'Sélectionner un produit';

  @override
  String get analysisTitle => 'Analyse et Statistiques';

  @override
  String get globalInventory => 'Inventaire Global';

  @override
  String get inStock => 'En Stock';

  @override
  String get dispatched => 'Expédié';

  @override
  String dispatchedLast30Days(int count) {
    return '$count en 30 jours';
  }

  @override
  String get defective => 'Défectueux';

  @override
  String get currentStockDesc => 'Stock actuel';

  @override
  String get currentDefectiveDesc => 'Défectueux actuels';

  @override
  String get warehouseDistribution => 'Répartition par entrepôt';

  @override
  String get unknown => 'Inconnu';

  @override
  String palletsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palettes',
      one: '$count palette',
    );
    return '$_temp0';
  }

  @override
  String get movementTrends30Days => 'Tendances de mouvement';

  @override
  String get movementLegend => 'Vert : Entrée, Orange : Sortie';

  @override
  String get top5Products => 'Tous les produits';

  @override
  String get noDescription => 'Aucune description';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get noDate => 'Pas de date';

  @override
  String get pdfTotal => 'Total';

  @override
  String get defectRate => 'Taux de défauts';

  @override
  String get defectRateDesc => '% défectueux 30 derniers jours';

  @override
  String get rotationRatio => 'Ratio de rotation';

  @override
  String get rotationRatioDesc => 'Expédiés 30 derniers jours / stock actuel';

  @override
  String get activeProducts => 'Produits actifs';

  @override
  String get keyPerformanceIndicators => 'Indicateurs Clés';

  @override
  String get warehouseOccupancy => 'Occupation par entrepôt';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get movementIn => 'Entrée';

  @override
  String get movementOut => 'Sortie';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get warehouse => 'Entrepôt';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Fév';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Avr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aoû';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Déc';
}
