import 'package:jar/l10n/app_localizations.dart';

String formatDateLabel(String dateStr, AppLocalizations l10n) {
  try {
    final date = DateTime.parse(dateStr);
    final months = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  } catch (_) {
    return dateStr;
  }
}
