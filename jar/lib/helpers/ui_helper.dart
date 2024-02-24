import 'package:intl/intl.dart';

class DateFormatter {
  /// Formatea un objeto DateTime en una cadena con formato agradable.
  ///
  /// - `date`: El objeto DateTime a formatear.
  /// - `format`: El patrón de formato a utilizar. Por defecto es 'dd/MM/yyyy'.
  ///
  /// Retorna una cadena con la fecha formateada.
  static String format(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }
}
