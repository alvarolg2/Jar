import 'package:flutter/services.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/utils/movement_data_processor.dart';
import 'package:jar/utils/weekly_movement_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportBuilder {
  final AppLocalizations l10n;

  PdfReportBuilder(this.l10n);

  final PdfColor brandPrimary = PdfColor.fromHex("#0D253F");
  final PdfColor brandAccent = PdfColor.fromHex("#26A69A");
  final PdfColor brandDefective = PdfColor.fromHex("#D32F2F");
  final PdfColor lightGrey = PdfColor.fromHex("#F5F7FA");

  Future<pw.Document> createDocument() async {
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();
    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      ),
    );
  }

  Future<pw.ImageProvider> loadLogo() async {
    final logoData = await rootBundle.load('assets/icon/icon.png');
    return pw.MemoryImage(logoData.buffer.asUint8List());
  }

  pw.Widget buildHeader(pw.Context context, pw.ImageProvider logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      margin: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.SizedBox(
            height: 40,
            width: 40,
            child: pw.Image(logoImage),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(l10n.reportTitle,
                  style: pw.TextStyle(
                      color: brandPrimary,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  l10n.reportGenerated(
                      DateTime.now().toLocal().toString().split(' ')[0]),
                  style: const pw.TextStyle(
                      color: PdfColors.grey600, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        l10n.reportPage(context.pageNumber, context.pagesCount),
        style: pw.TextStyle(
          color: PdfColor(
              brandPrimary.red, brandPrimary.green, brandPrimary.blue, 0.7),
          fontSize: 9,
        ),
      ),
    );
  }

  pw.Widget buildStatCard(String title, String value, PdfColor color,
      PdfColor textColor,
      {String? subtitle}) {
    return pw.Expanded(
      child: pw.Container(
        height: 70,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
            pw.SizedBox(height: 4),
            pw.Text(title,
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center),
            if (subtitle != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(subtitle,
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey500),
                  textAlign: pw.TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget buildKpiBadge(String label, String value, PdfColor color,
      {String? description}) {
    return pw.Expanded(
      child: pw.Container(
        height: 70,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700),
                textAlign: pw.TextAlign.center),
            if (description != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(description,
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey500),
                  textAlign: pw.TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget buildSectionHeader(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(5), topRight: pw.Radius.circular(5)),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white)),
    );
  }

  pw.Widget buildOccupancyBars(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(child: pw.Text(l10n.noData)),
      );
    }

    final rows = data.map((item) {
      final name = item['warehouseName']?.toString() ?? l10n.unknown;
      final percentage = (item['percentage'] as num?)?.toDouble() ?? 0.0;

      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 70,
              child: pw.Text(name,
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold),
                  overflow: pw.TextOverflow.clip),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Container(
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: percentage.clamp(0.0, 100.0).toInt(),
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: brandPrimary,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (percentage < 100)
                      pw.Expanded(
                        flex: (100 - percentage.clamp(0.0, 100.0)).toInt(),
                        child: pw.Container(),
                      ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.SizedBox(
              width: 40,
              child: pw.Text('${percentage.toStringAsFixed(0)}%',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.right),
            ),
          ],
        ),
      );
    }).toList();

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(children: rows),
    );
  }

  pw.Widget buildRecentActivityTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(child: pw.Text(l10n.noData)),
      );
    }

    final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8);
    const cellStyle = pw.TextStyle(fontSize: 8);
    const cellPadding = pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5);

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: brandPrimary),
      children: [
        pw.Padding(
            padding: cellPadding, child: pw.Text(l10n.date, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(l10n.type, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(l10n.product, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(l10n.warehouse, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(l10n.reportPalletCount, style: headerStyle)),
      ],
    );

    final dataRows = data.map((item) {
      final dateStr = item['date'] != null
          ? MovementDataProcessor.formatDateLabel(item['date'].toString())
          : l10n.noDate;
      final type = item['type']?.toString() ?? 'in';
      final isEntry = type == 'in';
      final palletCount = (item['palletCount'] as num?)?.toInt() ?? 0;

      return pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.white),
        children: [
          pw.Padding(
              padding: cellPadding, child: pw.Text(dateStr, style: cellStyle)),
          pw.Padding(
            padding: cellPadding,
            child: pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: pw.BoxDecoration(
                color: isEntry ? PdfColors.green : PdfColors.orange,
                borderRadius: pw.BorderRadius.circular(2),
              ),
              child: pw.Text(
                isEntry ? l10n.movementIn : l10n.movementOut,
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.white),
              ),
            ),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text(item['productName'] ?? l10n.unknown,
                style: cellStyle, overflow: pw.TextOverflow.clip),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text(item['warehouseName'] ?? l10n.unknown,
                style: cellStyle, overflow: pw.TextOverflow.clip),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text('$palletCount',
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
          ),
        ],
      );
    }).toList();

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1.5),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2),
          4: pw.FlexColumnWidth(1),
        },
        children: [headerRow, ...dataRows],
      ),
    );
  }

  pw.Widget buildPdfChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(child: pw.Text(l10n.noData)),
      );
    }

    final weekly = WeeklyMovementData.fromRawData(data,
        getMonthLabel: (month) {
          final months = [
            l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
            l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
            l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
          ];
          return months[month - 1];
        });

    final chartHeight = 120.0;

    List<pw.Widget> barGroups = [];
    for (int i = 0; i < weekly.weeklyIn.length; i++) {
      final hIn = weekly.maxWeekly > 0
          ? (weekly.weeklyIn[i] / weekly.maxWeekly) * chartHeight
          : 0.0;
      final hOut = weekly.maxWeekly > 0
          ? (weekly.weeklyOut[i] / weekly.maxWeekly) * chartHeight
          : 0.0;

      barGroups.add(
        pw.Expanded(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      if (weekly.weeklyIn[i] > 0)
                        pw.Text(
                          '${weekly.weeklyIn[i]}',
                          style: const pw.TextStyle(
                              fontSize: 6, color: PdfColors.green),
                        ),
                      pw.Container(
                        width: 10,
                        height: hIn,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green,
                          borderRadius: const pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(2),
                              topRight: pw.Radius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 3),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      if (weekly.weeklyOut[i] > 0)
                        pw.Text(
                          '${weekly.weeklyOut[i]}',
                          style: const pw.TextStyle(
                              fontSize: 6, color: PdfColors.orange),
                        ),
                      pw.Container(
                        width: 10,
                        height: hOut,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.orange,
                          borderRadius: const pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(2),
                              topRight: pw.Radius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(weekly.weekLabels[i],
                  style:
                      const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
            ],
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(l10n.movementTrends30Days,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            children: [
              pw.Container(
                height: chartHeight + 24,
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
                    bottom:
                        pw.BorderSide(color: PdfColors.grey400, width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: barGroups,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(width: 10, height: 8, color: PdfColors.green),
                  pw.SizedBox(width: 4),
                  pw.Text('${l10n.movementIn} (${weekly.totalIn})',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(width: 20),
                  pw.Container(width: 10, height: 8, color: PdfColors.orange),
                  pw.SizedBox(width: 4),
                  pw.Text('${l10n.movementOut} (${weekly.totalOut})',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(width: 20),
                  pw.Container(
                      width: 10,
                      height: 8,
                      color: weekly.netBalance >= 0
                          ? PdfColors.green
                          : PdfColors.red),
                  pw.SizedBox(width: 4),
                  pw.Text('Balance (${weekly.netBalance})',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget buildSummaryStatItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color)),
        pw.SizedBox(height: 2),
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center),
      ],
    );
  }

  pw.Widget buildWarehouseTable(
      List<dynamic> items, PdfColor headerColor, PdfColor zebraColor) {
    final headers = [l10n.product, l10n.batch, l10n.reportPalletCount];

    final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10);
    const cellStyle = pw.TextStyle(fontSize: 10);
    const cellPadding = pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8);

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: headerColor),
      children: headers.map((header) {
        return pw.Padding(
          padding: cellPadding,
          child: pw.Text(
            header,
            style: headerStyle,
            textAlign: header == l10n.reportPalletCount
                ? pw.TextAlign.right
                : pw.TextAlign.left,
          ),
        );
      }).toList(),
    );

    final List<pw.TableRow> dataRows = [];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final bool isZebra = index % 2 != 0;

      dataRows.add(
        pw.TableRow(
          decoration: isZebra
              ? pw.BoxDecoration(color: zebraColor)
              : const pw.BoxDecoration(color: PdfColors.white),
          children: [
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(item.productName, style: cellStyle),
            ),
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(item.lotName, style: cellStyle),
            ),
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(
                item.palletCount.toString(),
                style: cellStyle,
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(1.5),
      },
      children: [
        headerRow,
        ...dataRows,
      ],
    );
  }

  pw.Widget buildSummaryTable(
      Map<String, int> itemsByProduct, int total, PdfColor color) {
    final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10);
    const cellStyle = pw.TextStyle(fontSize: 10);
    const cellPadding = pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8);

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: color),
      children: [
        pw.Padding(
          padding: cellPadding,
          child: pw.Text(l10n.product, style: headerStyle),
        ),
        pw.Padding(
          padding: cellPadding,
          child: pw.Text(l10n.reportPalletCount,
              style: headerStyle, textAlign: pw.TextAlign.right),
        ),
      ],
    );

    final sortedEntries = itemsByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<pw.TableRow> dataRows = [];
    for (var index = 0; index < sortedEntries.length; index++) {
      final entry = sortedEntries[index];
      final bool isZebra = index % 2 != 0;

      dataRows.add(
        pw.TableRow(
          decoration: isZebra
              ? pw.BoxDecoration(color: lightGrey)
              : const pw.BoxDecoration(color: PdfColors.white),
          children: [
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(entry.key, style: cellStyle),
            ),
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(
                entry.value.toString(),
                style: cellStyle,
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    dataRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: lightGrey),
        children: [
          pw.Padding(
            padding: cellPadding,
            child: pw.Text(l10n.pdfTotal,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text(
              total.toString(),
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 10),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1.5),
      },
      children: [
        headerRow,
        ...dataRows,
      ],
    );
  }

  String getMonthShort(int month) {
    final months = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
    ];
    return months[month - 1];
  }
}
